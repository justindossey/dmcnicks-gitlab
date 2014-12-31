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

  # Prefetch resource data for all declared gitlab_session resources.
 
  def self.prefetch(resources)

    # There should only ever be one gitlab_session resource declared for
    # any node but we will cycle through the declared session resources for
    # completeness.

    resources.each do |name, resource|
  
      # Set the API URL.

      self.api_url = resource[:url]

      # Attempt to login.

      token = api_login(resource[:login], resource[:password])

      # Mark the password to be changed if the login succeeded and a new
      # password has been specified.

      change_password = token && resource[:new_password]

      # If the login failed try logging in with the new password instead.

      token = api_login(resource[:login], resource[:new_password])

      # Raise an exception if the login failed with the new password too.

      unless token
        raise Puppet::Error, "Gitlab login for session '%s' failed" % name
      end

      # Set the API token.

      this.private_token = token

      # Create the new resource.

      resource.provider = new

      # Change the password if required.

      if change_password && resource[:new_password] != resource[:password]

        params = {
          :password => resource[:new_password]
        }

        uri = '/users/%s' % user_id_for(resource[:login])

        api_put(uri, params)

      end

    end

  end

end
