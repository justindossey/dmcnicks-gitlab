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

  # Store the user ID parameter as instance variables.

  attr_accessor :user_id

  # Create a new gitlab_user provider.

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
 
      # Find the user record. 
      
      founduser = nil

      users.each do |user|
        if user['username'] == name
          founduser = user
        end
      end

      # If a user has been found, create a provider with :ensure set to
      # :present and the user details. 

      if founduser

        # If a password has been specified, check whether it is currently
        # valid. If it is then we will set the prefetched resource to the
        # same password to avoid extraneous "defined 'password' as 'nnnn'"
        # messages on the puppet agent.
 
        password = nil

        if login?(founduser['username'], resource['password'])
          password = resource['password']
        end

        properties = {
          :ensure   => :present,
          :username => founduser['username'],
          :email    => founduser['email'],
          :fullname => founduser['name'],
          :password => password
        }

        resource.provider = new(properties)
        resource.provider.user_id = founduser['id']

      else

        # If not, create a provider with :ensure set to :absent.

        resource.provider = new(:ensure => :absent)

      end

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

        uri = '/users/%s' % user_id
        RestClient.delete(self.class.api_url + uri, params)

      end

    when :present

      if @old_properties[:ensure] == :absent

        # If the gitlab_user resource is now marked as present but was
        # previously marked as absent then create it in Gitlab.
 
        params = {
          :private_token => self.class.private_token,
          :username      => @property_hash[:name],
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

        uri = '/users/%s' % user_id
        RestClient.put(self.class.api_url + uri, params)

      end

    end

  end

  # Returns true if the provided credentials are valid (i.e. that they can
  # be used to login to the API.

  def self.login?(login, password)

    return false if ! password

    params = {
      :login    => login,
      :password => password
    }

    begin
      response = RestClient.post(self.api_url + '/session', params)
      return response.code == 201
    rescue 
      return false
    end

  end

end
