require 'puppet/provider/gitlab'
require 'json'

Puppet::Type.type(:gitlab_session).provide(
  :ruby,
  :parent => Puppet::Provider::Gitlab
) do

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
    Puppet::Provider::Gitlab.api_url = resource[:api_url]
    params = {
      :login    => resource[:api_login],
      :password => resource[:api_password]
    }
    uri = '/session'
    response = RestClient.post(Puppet::Provider::Gitlab.api_url + uri, params)
    if response.code == 201
      session = JSON.parse(response)
      Puppet::Provider::Gitlab.token = session['private_token']
    end
  end

  def destroy
    Puppet::Provider::Gitlab.token = nil
  end

  def exists?
    Puppet::Provider::Gitlab.token != nil
  end
end
