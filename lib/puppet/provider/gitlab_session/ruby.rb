require 'json'

Puppet::Type.type(:gitlab_session).provide(:ruby) do

  desc 'Default provider for gitlab_session type'

  Puppet::Type.class_variable_set(:@@gitlab_token, nil)
  Puppet::Type.class_variable_set(:@@gitlab_api_url, nil)

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
    api_url = resource[:api_url]
    params = {
      :login    => resource[:api_login],
      :password => resource[:api_password]
    }
    response = RestClient.post(api_url + '/session', params)
    if response.code == 201
      session = JSON.parse(response)
      token = session['private_token']
    end
  end

  def destroy
    token = nil
  end

  def exists?
    token != nil
  end

  def token
    Puppet::Type.class_variable_get(:@@gitlab_token)
  end

  def token=(value)
    Puppet::Type.class_variable_set(:@@gitlab_token, value)
  end

  def api_url
    Puppet::Type.class_variable_get(:@@gitlab_api_url)
  end

  def api_url=(value)
    Puppet::Type.class_variable_set(:@@gitlab_api_url, value)
  end
end
