require 'json'

Puppet::Type.type(:gitlab_session).provide(:ruby) do

  desc 'Default provider for gitlab_session type'

  # Class variable used to store the private token created by the API
  # after login.
  
  class_variable_set(:@@token, nil)
  
  # The URL of the API.

  class_variable_set(:@@api_url, nil)

  # Confine the provider to only run once the rest-client package is
  # available. Puppet will install the rest-client package during the
  # first run. This confine will return true in subsequent runs.
  
  confine :true => begin
    begin
      require 'rest_client'
      true
    rescue LoadError
      false
    end
  end  

  def create
    class_variable_set(:@@api_url, resource[:api_url])
    params = {
      :login    => resource[:api_login],
      :password => resource[:api_password]
    }
    response = RestClient.post(api_url + '/session', params)
    if response.code == 201
      session = JSON.parse(response)
      class_variable_set(:@@token, session['private_token'])
    end
  end

  def destroy
    class_variable_set(:@@token, nil)
  end

  def exists?
    token != nil
  end

  def token
    class_variable_get(:@@token)
  end

  def api_url
    class_variable_get(:@@api_url)
  end
end
