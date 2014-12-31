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

      # Try to login with the current password first.
      
      change_password = false

      begin

        params = {
          :login    => resource[:login],
          :password => resource[:password]
        }

        uri = '/session'

        response = api_post(uri, params)

        change_password = resource[:new_password] != nil

      rescue

        # If that fails, try logging in with the new password if it has
        # been set.
 
        if resource[:new_password]
          params[:password] = resource[:new_password]
          response = api_post(uri, params)
        end

      end

      # Set the private token and API URL if logged in successfully.

      if response && response.code == 201

        session = JSON.parse(response)

        self.private_token = session['private_token']

      else

        raise Puppet::Error, "Gitlab login for session '%s' failed" % name

      end

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
