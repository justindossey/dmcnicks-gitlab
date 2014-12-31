require 'puppet/provider/gitlab'
require 'json'

Puppet::Type.type(:gitlab_user_key).provide(
  :ruby,
  :parent => Puppet::Provider::Gitlab
) do

  desc 'Default provider for gitlab_user_key type'

  # Make sure that the rest-client package is available.

  confine :true => begin
    begin
      require 'rest_client'
      true
    rescue LoadError
      false
    end
  end  

  # Store the user ID, key ID and key title parameters as instance variables.

  attr_accessor :user_id, :key_id, :key_title

  # Create a new gitlab_user_key provider.

  def initialize(*args)

    # Pass the properties onto the parent class.

    super(*args)

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
    
    users = []

    response = api_get('/users')

    if response.code == 200
      users = JSON.parse(response)
    end

    # Now cycle through each declared resource.
 
    resources.each do |name, resource|
 
      # Get the user record for the user that the key is being added to.

      founduser = nil

      users.each do |user|
        if user['username'] == resource[:username]
          founduser = user.dup
        end
      end

      if founduser

        # Get the key that is being added.

        foundkey = nil

        uri = "/users/%s/keys" % founduser['id']

        response = api_get(uri)

        if response.code == 200

          keys = JSON.parse(response)

          keys.each do |key|
            if key['title'] == name
              foundkey = key.dup
            end
          end

        end

        if foundkey

          # If we have found the user and have a key to add, set the properties
          # and mark :ensure as :present.

          properties = {
            :ensure   => :present,
            :key      => foundkey['key']
          }

          resource.provider = new(properties)

          resource.provider.user_id = founduser['id']
          resource.provider.key_id = foundkey['id']
          resource.provider.key_title = name

        else
  
          # If no key has been found, mark :ensure as :absent.

          resource.provider = new(:ensure => :absent)

          resource.provider.user_id = founduser['id']
          resource.provider.key_title = name

        end

      else

        # Raise an error if the user is not found.

        raise "user %s not found for key %s" % [ resource[:username], name ]

      end

    end

  end

  # Flush properties.

  def flush

    # Work out whether the gitlab_user_key resource should be created,
    # destroyed or updated by comparing the @property_hash as it is now with
    # the @old_properties hash that was duped when the provider was created.

    case @property_hash[:ensure]

    when :absent

      if @old_properties[:ensure] == :present

        # If the gitlab_user_key resource is now marked as absent but was
        # previously marked as present then delete it from Gitlab.

        uri = '/users/%s/keys/%s' % [ user_id, key_id ]

        api_delete(uri)

      end

    when :present

      if @old_properties[:ensure] == :absent

        # If the gitlab_user_key resource is now marked as present but was
        # previously marked as absent then create it in Gitlab.
 
        params = {
          :key   => @property_hash[:key],
          :title => key_title
        }

        uri = "/users/%s/keys" % user_id

        api_post(uri, params)

      else

        # If the gitlab_user_key resource is now marked as present and it was
        # previously marked as present too then update the key in Gitlab if any
        # properties have changed. This is done by deleting the existing key
        # entry and creating a new one.

        if changed? && user_id && key_id && key_title

          # First delete the key.

          uri = '/users/%s/keys/%s' % [ user_id, key_id ]

          api_delete(uri)

          # Then create a new key.

          params = {
            :key   => @property_hash[:key],
            :title => key_title
          }

          uri = "/users/%s/keys" % user_id

          api_post(uri, params)

        end

      end

    end

  end

  # Returns true if any of the properties have changed.

  def changed?
    return @property_hash[:key] != @old_properties[:key]
  end

end
