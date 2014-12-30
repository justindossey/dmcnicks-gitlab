require 'puppet/provider/gitlab'
require 'json'

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

  # Create a new gitlab_session provider.
  
  def initialize(token, url, *args)

    # Set the private_token and api_url class variables.
  
    self.class.private_token = token
    self.class.api_url = url

    # Pass the rest of the arguments to the parent.

    super(*args)

  end

end
