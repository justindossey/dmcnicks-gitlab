require 'puppet/provider/gitlab'
require 'json'

Puppet::Type.type(:gitlab_session).provide(
  :ruby,
  :parent => Puppet::Provider::Gitlab
) do

  desc 'Default provider for gitlab_session type'

  # Make sure that the rest-client package is available.

  confine :true => begin
    begin
      require 'rest_client'
      true
    rescue LoadError
      false
    end
  end  

  # Create a new gitlab_session provider.
  
  def initialize(token, url)

    # Set the private_token and api_url class variables.
  
    self.private_token = token
    self.api_url = url

    super

  end

  # Prefetch resource data for all declared gitlab_session resources.
 
  def self.prefetch(resources)

    # There should only ever be one gitlab_session resource declared for
    # any node but we will cycle through the declared session resources for
    # completeness.

    resources.each do |name, resource|
  
      # Perform a login to the API and fetch the returned private token.
      
      token = nil
      url = resource[:api_url]

      params = {
        :login    => resource[:api_login],
        :password => resource[:api_password]
      }

      uri = '/session'
      response = RestClient.post(url + uri, params)

      if response.code == 201
        session = JSON.parse(response)
        token = session['private_token']
      end

      # Initialise the provider for this resource.
      
      resource.provider = new(token, url)

    end

  end

  # This provider has no flush method because it has no properties to
  # flush.

end
