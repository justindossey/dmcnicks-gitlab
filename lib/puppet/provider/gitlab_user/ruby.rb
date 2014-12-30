require 'puppet/provider/gitlab'
require 'json'

Puppet::Type.type(:gitlab_user).provide(
  :ruby,
  :parent => Puppet::Provider::Gitlab
) do

  desc 'Default provider for gitlab_user type'

  # Make sure that the rest-client package is available.

  confine :true => begin
    begin
      require 'rest_client'
      true
    rescue LoadError
      false
    end
  end  

  # Create a new gitlab_user provider.

  def initialize(properties)

    # Pass the properties onto the parent class.

    super(properties)

    # Duplicate the property_hash so we have a record of the state of the
    # user before manifests make changes. This will be used in the flush
    # method to work out what has changed.
    
    @old_properties = @property_hash.dup

  end

  # Create getters and setters for type properties.

  mk_resource_methods

  # Prefetch resource data for all declared gitlab_user resources.

  def self.prefetch(resources)

    # Before we cycle through the resources we can prefetch all of the
    # defined user records from the API.
    
    users = nil

    params = {
      :private_token => self.private_token
    }

    uri = '/users'
    response = RestClient.get(self.api_url + uri, params)

    if response.code == 200
      users = JSON.parse(response)
      users.symbolize_keys
    end

    # Now cycle through each declared resource.
 
    resources.each do |name, resource|
 
      # Find the user record.
      
      user = {}

      users.each do |u|
        if u[:username] == resource[:username]
          user = u.symbolize_keys
        end
      end

      # Collect the properties for the user.
      #
      # Note that the fullname property maps onto the name property from the
      # API. This is done because if we defined a type property called :name
      # it would automatically become a namevar, when we want the namevar for
      # the gitlab_user type to be :username.
      #
      # Note also that we are not collecting the password from the Gitlab API.
      # That is because the API does not expose the password. The password can
      # still be set by the provider if one is specified in the manifest.
      #
      # Finally, note that we are storing the :id as a property even though
      # it is not accessible by the type. It is needed to make API calls later
      # in the flush method.

      properties = {
        :id       => resource[:id],
        :username => resource[:username],
        :email    => user[:email],
        :fullname => user[:name]
      }

      # Create a new provider with the found properties.
 
      resource.provider = new(properties)

    end

  end

  # Flush properties.

  def flush

    # Work out whether the gitlab_user resource should be created, destroyed
    # or updated by comparing the @property_hash as it is now with the
    # @old_properties hash that was duped when the provider was created.

    case @property_hash[:ensure]

    when :absent

      if @old_properties[:ensure] == :present

        # If the gitlab_user resource is now marked as absent but was
        # previously marked as present then delete it from Gitlab.

        params = {
          :private_token => self.class.private_token
        }

        uri = '/users/%s' % @old_properties[:id]
        RestClient.delete(self.class.api_url + uri, params)

      end

    when :present

      if @old_properties[:ensure] == :absent

        # If the gitlab_user resource is now marked as present but was
        # previously marked as absent then create it in Gitlab.
 
        params = {
          :private_token => self.class.private_token,
          :username      => @property_hash[:username],
          :password      => @property_hash[:password],
          :email         => @property_hash[:email],
          :name          => @property_hash[:fullname]
        }

        uri = '/users'
        RestClient.post(self.class.api_url + uri, params)

      else

        # If the gitlab_user resource is now marked as present and it was
        # previously marked as present too then update any changed properties
        # in Gitlab.

        params = {
          :private_token => self.class.private_token,
        }

        if @property_hash[:password]
          params[:password] = @property_hash[:password]
        end

        if @property_hash[:email]
          params[:email] = @property_hash[:email]
        end

        if @property_hash[:fullname]
          params[:name] = @property_hash[:fullname]
        end

        uri = '/users/%s' % @old_properties[:id]
        RestClient.put(self.class.api_url + uri, params)

      end

    end

    # Finally, clear the property hash now that it has been flushed.

    @property_hash.clear

  end

end
