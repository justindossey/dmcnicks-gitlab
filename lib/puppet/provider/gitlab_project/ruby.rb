require 'puppet/provider/gitlab'

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

  # Store parameters as instance variables.

  attr_accessor :project_id, :project_name, :project_owner

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
    
    projects = api_get('/projects/all')

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
          :ensure    => :present
        }

        resource.provider = new(properties)

        resource.provider.project_id = foundproject['id']
        resource.provider.project_name = foundproject['name']

        if foundproject['owner']
          if owner = foundproject['owner']['name']
            resource.provider.owner = owner
          end
        end

        if foundproject['namespace']
          if namespace = foundproject['namespace']['name']
            resource.provider.owner = namespace
          end
        end

      else

        # If not, create a provider with :ensure set to :absent.

        resource.provider = new(:ensure => :absent)

        resource.provider.project_name = name
        resource.provider.project_owner = resource[:owner]

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

        api_delete('/projects/%s' % project_id)

      end

    when :present

      if @old_properties[:ensure] == :absent

        # If the gitlab_project resource is now marked as present but was
        # previously marked as absent then create it in Gitlab.
 
        params = {
          :name => project_name,
          :path => slug_for(project_name)
        }

        # If an owner is specified, work out whether the owner is a user or
        # a group. If the owner is a user, call the user-specific URI. If the
        # owner is a group, add a :namespace_id parameter.

        if project_owner

          if id = user_id_for(project_owner)
            api_post('/projects/user/%s' % id, params)
          end

          if id = group_id_for(project_owner)
            params[:namespace_id] = id
            api_post('/projects', params)
          end

        end

        # Projects do not have modifiable properties so there is no third
        # option of modifying an existing resource here. It would be nice if
        # we could change the project namespace but the API does not support
        # it.

      end

    end

  end

end
