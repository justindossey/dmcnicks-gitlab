require 'puppet/provider/gitlab'
require 'json'
require 'pp'

Puppet::Type.type(:gitlab_session).provide(
    :rubyone,
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
  
      pp name
      pp resource

      # Perform a login to the API and fetch the returned private token.
      
      token = nil
      url = resource[:api_url]

      params = {
        :login    => resource[:api_login],
        :password => resource[:api_password]
      }

      pp url
      pp params

      result = {}

      uri = '/session'
      response = RestClient.post(url + uri, params)

      if response.code == 201

        # If logged in, create a new provider containing the private token,
        # API URL and mark it as present.

        session = JSON.parse(response)
        token = session['private_token']

        self.class.private_token = token
        self.class.api_url = url

        resource.provider = new(:ensure => :absent)

      else

        resource.provider = new(:ensure => :present)

      end

    end

  end

end
