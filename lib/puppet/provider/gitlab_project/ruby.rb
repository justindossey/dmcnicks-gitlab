require 'puppet/provider/gitlab'
require 'json'

Puppet::Type.type(:gitlab_project).provide(
  :ruby,
  :parent => Puppet::Provider::Gitlab
) do

  desc 'Default provider for gitlab_project type'

  # Make sure that the rest-client package is available.

  confine :true => begin
    begin
      require 'rest_client'
      true
    rescue LoadError
      false
    end
  end  

  # Store the project ID and name as instance variables.

  attr_accessor :project_id, :project_name

  # Create a new gitlab_project provider.

  def initialize(*args)

    # Pass the properties onto the parent class.

    super(*args)

    # Duplicate the property_hash so we have a record of the state of the
    # project before manifests make changes. This will be used in the flush
    # method to work out what has changed.
    
    @old_properties = @property_hash.dup

  end

  # Create getters and setters for type properties.

  mk_resource_methods

  # Prefetch resource data for all declared gitlab_project resources.

  def self.prefetch(resources)

    # Before we cycle through the resources we can prefetch all of the
    # defined project records from the API.
    
    projects = []

    params = {
      :private_token => self.private_token
    }

    uri = '/projects/all'
    response = RestClient.get(self.api_url + uri, params)

    if response.code == 200
      projects = JSON.parse(response)
    end

    # Now cycle through each declared resource.
 
    resources.each do |name, resource|
 
      # Find the project record. 
      
      foundproject = nil

      projects.each do |project|
        if project['name'] == name
          foundproject = project
        end
      end

      if foundproject

        # If a project has been found, create a provider with :ensure set to
        # :present.

        properties = {
          :ensure       => :present,
          :namespace    => get_namespace(foundproject['namespace_id'])
        }

        resource.provider = new(properties)

        resource.provider.project_id = foundproject['id']
        resource.provider.project_name = foundproject['name']

      else

        # If not, create a provider with :ensure set to :absent.

        resource.provider = new(:ensure => :absent)

        resource.provider.project_name = name

      end

    end

  end

  # Flush properties.

  def flush

    # Work out whether the gitlab_project resource should be created, destroyed
    # or updated by comparing the @property_hash as it is now with the
    # @old_properties hash that was duped when the provider was created.

    case @property_hash[:ensure]

    when :absent

      if @old_properties[:ensure] == :present

        # If the gitlab_project resource is now marked as absent but was
        # previously marked as present then delete it from Gitlab.

        params = {
          :private_token => self.class.private_token
        }

        uri = '/projects/%s' % project_id
        RestClient.delete(self.class.api_url + uri, params)

      end

    when :present

      if @old_properties[:ensure] == :absent

        # If the gitlab_project resource is now marked as present but was
        # previously marked as absent then create it in Gitlab.
 
        params = {
          :private_token => self.class.private_token,
          :name          => project_name,
          :path          => get_path_for(project_name),
          :namespace_id  => get_namespace_id(@property_hash[:namespace])
        }

        uri = '/projects'
        RestClient.post(self.class.api_url + uri, params)

      else

        # If the gitlab_project resource is now marked as present and it was
        # previously marked as present too then update any changed properties
        # in Gitlab.

        if changed?

          params = {
            :private_token => self.class.private_token,
            :namespace_id  => get_namespace_id(@property_hash[:namespace])
          }

          uri = '/projects/%s' % project_id
          RestClient.put(self.class.api_url + uri, params)

        end

      end

    end

  end

  # Returns true if any of the properties have changed.

  def changed?
    return @property_hash[:namespace] != @old_properties[:namespace]
  end

  # Returns a path slug created from the given name.

  def get_path_for(name)
    name.downcase.gsub(/[^a-z0-9]+/, '-').sub(/^-/, '').sub(/-$/, '')
  end

  # Returns the name of the namespace with the given ID. For projects, a
  # namespace can either be a group or an individual user so both have to
  # be searched for.

  def get_namespace(id)

    params = {
      :private_token => self.class.private_token
    }

    # Check if the id matches any groups.

    uri = '/groups'
    response = RestClient.get(self.api_url + uri, params)

    if response.code == 200
      groups = JSON.parse(response)
      groups.each do |group|
        if group['id'] == id
          return group['name']
        end
      end
    end

    # Check if the id matches any users.

    uri = '/users'
    response = RestClient.get(self.api_url + uri, params)

    if response.code == 200
      users = JSON.parse(response)
      users.each do |user|
        if user['id'] == id
          return user['name']
        end
      end
    end

    # If neither, return nil.

    return nil

  end

  # Returns the ID of the namespace with the given name. For projects, a
  # namespace can either be a group or an individual user so both have to
  # be searched for.

  def get_namespace_id(name)

    params = {
      :private_token => self.class.private_token
    }

    # Check if the id matches any groups.

    uri = '/groups'
    response = RestClient.get(self.api_url + uri, params)

    if response.code == 200
      groups = JSON.parse(response)
      groups.each do |group|
        if group['name'] == name
          return group['id']
        end
      end
    end

    # Check if the id matches any users.

    uri = '/users'
    response = RestClient.get(self.api_url + uri, params)

    if response.code == 200
      users = JSON.parse(response)
      users.each do |user|
        if user['name'] == name
          return user['id']
        end
      end
    end

    # If neither, return nil.

    return nil

  end

end
