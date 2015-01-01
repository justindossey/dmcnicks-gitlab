require 'puppet/provider/gitlab'
require 'pp'

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

  # Store the parameters as instance variables.

  attr_accessor :group_id, :group_name, :group_owner

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
          :ensure => :present
        }

        resource.provider = new(properties)

        resource.provider.group_id = foundgroup['id']
        resource.provider.group_name = foundgroup['name']

        # The owner parameter is a bit weird because there can be any
        # number of group members with owner rights. For this reason we just
        # check that the owner, if set, is actually a member that has owner
        # rights.

        if resource[:owner]
          add_owner(resource[:owner], foundgroup['id'])
        end

      else

        # If not, create a provider with :ensure set to :absent.

        resource.provider = new(:ensure => :absent)

        resource.provider.group_name = name
        resource.provider.group_owner = resource[:owner]

        # Because the group does not exist we cannot deal with the group owner
        # yet. It will be handled in the flush method after the group has been
        # created.

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

        # Add the owner as a member with owner rights.
 
        if group_owner
          group_id = group_id_for(group_name)
          add_owner(group_owner, group_id)
        end

      end

    end

  end

  # Adds the given user as a group member with owner rights.

  def self.add_owner(user, group_id)

    # First check what access the user has in the group.

    access_level = get_access_level(user, group_id)

    # Return just now if the user is already an owner.

    return if access_level == 50

    # If the user is a member but does not have owner privileges, temporarily
    # remove the user from the group, so that they can be re-added as an owner
    # below.

    user_id = user_id_for(user)

    if access_level > 0
      api_delete('/groups/%s/members/%s' % [ group_id, user_id ])
    end

    # Add the user as a member with owner rights.

    params = {
      :user_id      => user_id,
      :access_level => 50
    }

    api_post('/groups/%s/members' % group_id, params)

  end

  # returns the access level of the user for the given group, or zero if the
  # user is not a member.
 
  def self.get_access_level(name, group_id)

    members = api_get('/groups/%s/members' % group_id)

    members.each do |member|
      if member['username'] == name
        return member['access_level']
      end
    end

    return 0

  end

  def add_owner(user, group_id)
    self.class.add_owner(user, group_id)
  end

end
