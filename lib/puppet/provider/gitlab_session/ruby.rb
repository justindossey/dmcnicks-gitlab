require 'puppet/provider/gitlab'
require 'json'
require 'pp'

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

  # Prefetch resource data for all declared gitlab_session resources.
 
  def self.prefetch(resources)

    # There should only ever be one gitlab_session resource declared for
    # any node but we will cycle through the declared session resources for
    # completeness.

    resources.each do |name, resource|
  
      # Login to the API.
      
      params = {
        :login    => resource[:api_login],
        :password => resource[:api_password]
      }

      result = {}

      uri = '/session'
      response = RestClient.post(resource[:api_url] + uri, params)

      # Set the private token and API URL if logged in successfully.

      if response.code == 201

        session = JSON.parse(response)

        self.private_token = session['private_token']
        self.api_url = resource[:api_url]

      end

      # Create the new resource.

      resource.provider = new

    end

  end

end
