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

  # Store the fromuser, user ID and key ID parameters as instance variables.

  attr_reader :fromuser, :user_id, :key_id

  # Create a new gitlab_user_key provider.

  def initialize(fromuser, user_id, key_id, *args)

    # Store the parameters in instance variables.

    @fromuser = fromuser
    @user_id = user_id
    @key_id = key_id

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

    params = {
      :private_token => self.private_token
    }

    uri = '/users'
    response = RestClient.get(self.api_url + uri, params)

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

        params = {
          :private_token => self.private_token
        }

        uri = "/users/%s/keys" % founduser['id']
        response = RestClient.get(self.api_url + uri, params)

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
            :title    => key['title'],
            :key      => key['key']
          }

          resource.provider = new(resource['fromuser'],
                                  founduser['id'],
                                  foundkey['id'],
                                  properties)

        else
  
          # If no key has been found, mark :ensure as :absent.

          resource.provider = new(resource['fromuser'],
                                  founduser['id'],
                                  nil,
                                  :ensure => :absent)

        end

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

        params = {
          :private_token => self.class.private_token
        }

        uri = '/users/%s/keys/%s' % [ user_id, key_id ]
        RestClient.delete(self.class.api_url + uri, params)

      end

    when :present

      # Fetch the key.

      key = @property_hash[:key]

      if ! key
        key = key_from_user
      end

      if @old_properties[:ensure] == :absent

        # If the gitlab_user_key resource is now marked as present but was
        # previously marked as absent then create it in Gitlab.
 
        params = {
          :private_token => self.class.private_token,
          :title         => @property_hash[:title],
          :key           => key
        }

        uri = "/users/%s/keys" % user_id
        RestClient.post(self.class.api_url + uri, params)

      else

        # If the gitlab_user_key resource is now marked as present and it was
        # previously marked as present too then update the key in Gitlab. This
        # is done by deleting the existing key entry and creating a new one so
        # it is only done if the new key is different from the old one.

        if key != @old_properties[:key] && user_id && key_id

          # First delete the key.

          params = {
            :private_token => self.class.private_token
          }

          uri = '/users/%s/keys/%s' % [ user_id, key_id ]
          RestClient.delete(self.class.api_url + uri, params)

          # Then create a new key.

          params = {
            :private_token => self.class.private_token,
            :title         => @property_hash[:title],
            :key           => key
          }

          uri = "/users/%s/keys" % user_id
          RestClient.post(self.class.api_url + uri, params)

        end

      end

    end

    # Finally, clear the property hash now that it has been flushed.

    @property_hash.clear

  end

  # Fetches a public key from the @fromuser's home directory on the local
  # filesystem.

  def key_from_user

    if homedir = Dir.home(fromuser)

      keyfile = File.join(homedir, '.ssh', 'id_rsa.pub')

      if ! File.exists?(keyfile)
        keyfile = File.join(homedir, '.ssh', 'id_dsa.pub')
      end

      if File.exists?(keyfile)
        return File.open(keyfile).read.chomp
      end

    end

    return nil

  end

end
