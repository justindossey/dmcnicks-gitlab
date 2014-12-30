require 'puppet/provider/gitlab'
require 'json'

Puppet::Type.type(:gitlab_session).provide(:rubythree) do

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
  
  def initialize(token, url, *args)

    # Set the private_token and api_url class variables.
  
    self.class.private_token = token
    self.class.api_url = url

    # Pass the rest of the arguments to the parent.

    super(*args)

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

      result = {}

      uri = '/session'
      response = RestClient.post(url + uri, params)

      if response.code == 201

        # If logged in, create a new provider containing the private token,
        # API URL and mark it as present.

        session = JSON.parse(response)
        token = session['private_token']

        resource.provider = new(token, url, :ensure => :present)

      else

        # Otherwise, create a new provider marked as absent.
 
        resource.provider = new(nil, nil, :ensure => :present)

      end

    end

  end

end
