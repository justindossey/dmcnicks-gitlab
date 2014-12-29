require 'json'

Puppet::Type.type(:gitlab_session).provide(:ruby) do

  desc 'Default provider for gitlab_session type'

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
    params = {
      :login    => resource[:api_login],
      :password => resource[:api_password]
    }
    response = RestClient.post(resource[:api_url] + '/session', params)
    if response.code == 201
      session = JSON.parse(response)
      @@token = session['private_token']
    end
  end

  def destroy
    @@token = nil
  end

  def exists?
    return @@token != nil
  end

  def token
    return @@token
  end

end
