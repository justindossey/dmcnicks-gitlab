require 'puppet/provider/gitlab'

Puppet::Type.type(:gitlab_group).provide(
  :ruby,
  :parent => Puppet::Provider::Gitlab
) do

  desc 'Default provider for gitlab_group type'

  # Make sure that the rest-client package is available.

  confine :true => begin
    begin
      require 'rest_client'
      true
    rescue LoadError
      false
    end
  end  

  # Store the group ID and name as instance variables.

  attr_accessor :group_id, :group_name

  # Create a new gitlab_group provider.

  def initialize(*args)

    # Pass the properties onto the parent class.

    super(*args)

    # Duplicate the property_hash so we have a record of the state of the
    # group before manifests make changes. This will be used in the flush
    # method to work out what has changed.
    
    @old_properties = @property_hash.dup

  end

  # Create getters and setters for type properties.

  mk_resource_methods

  # Prefetch resource data for all declared gitlab_group resources.

  def self.prefetch(resources)

    # Before we cycle through the resources we can prefetch all of the
    # defined group records from the API.
    
    groups = api_get('/groups')

    # Now cycle through each declared resource.
 
    resources.each do |name, resource|
 
      # Find the group record. 
      
      foundgroup = nil

      groups.each do |group|
        if group['name'] == name
          foundgroup = group
        end
      end

      if foundgroup

        # If a group has been found, create a provider with :ensure set to
        # :present.

        properties = {
          :ensure   => :present
        }

        resource.provider = new(properties)

        resource.provider.group_id = foundgroup['id']
        resource.provider.group_name = foundgroup['name']

      else

        # If not, create a provider with :ensure set to :absent.

        resource.provider = new(:ensure => :absent)

        resource.provider.group_name = name

      end

    end

  end

  # Flush properties.

  def flush

    # Work out whether the gitlab_group resource should be created, destroyed
    # or updated by comparing the @property_hash as it is now with the
    # @old_properties hash that was duped when the provider was created.

    case @property_hash[:ensure]

    when :absent

      if @old_properties[:ensure] == :present

        # If the gitlab_group resource is now marked as absent but was
        # previously marked as present then delete it from Gitlab.

        api_delete('/groups/%s' % group_id)

      end

    when :present

      if @old_properties[:ensure] == :absent

        # If the gitlab_group resource is now marked as present but was
        # previously marked as absent then create it in Gitlab.
 
        params = {
          :name => group_name,
          :path => slug_for(group_name)
        }

        api_post('/groups', params)

        # Groups do not have any modifiable properties so there is no third
        # option of modifying an existing resource here.

      end

    end

  end

end
