require 'puppet/provider/gitlab'
require 'json'

Puppet::Type.type(:gitlab_deploy_key).provide(
  :ruby,
  :parent => Puppet::Provider::Gitlab
) do

  desc 'Default provider for gitlab_deploy_key type'

  # Make sure that the rest-client package is available.

  confine :true => begin
    begin
      require 'rest_client'
      true
    rescue LoadError
      false
    end
  end  

  # Store the project ID and key ID parameters as instance variables.

  attr_accessor :project_id, :key_id, :key_title

  # Create a new gitlab_deploy_key provider.

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

    response = api_get('/projects/all')

    if response.code == 200
      projects = JSON.parse(response)
    end

    # Now cycle through each declared resource.
 
    resources.each do |name, resource|
 
      # Get the project record for the project that the key is being added to.

      foundproject = nil

      projects.each do |project|
        if project['name'] == resource[:project]
          foundproject = project.dup
        end
      end

      if foundproject

        # Get the key that is being added.

        foundkey = nil

        uri = "/projects/%s/keys" % foundproject['id']

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

          # If we have found the project and have a key to add, set the
          # properties and mark :ensure as :present.

          properties = {
            :ensure   => :present,
            :key      => foundkey['key']
          }

          resource.provider = new(properties)

          resource.provider.project_id = foundproject['id']
          resource.provider.key_id = foundkey['id']
          resource.provider.key_title = name

        else
  
          # If no key has been found, mark :ensure as :absent.

          resource.provider = new(:ensure => :absent)

          resource.provider.project_id = foundproject['id']
          resource.provider.key_title = name

        end

      end

    end

  end

  # Flush properties.

  def flush

    # Work out whether the gitlab_deploy_key resource should be created,
    # destroyed or updated by comparing the @property_hash as it is now with
    # the @old_properties hash that was duped when the provider was created.

    case @property_hash[:ensure]

    when :absent

      if @old_properties[:ensure] == :present

        # If the gitlab_deploy_key resource is now marked as absent but was
        # previously marked as present then delete it from Gitlab.

        uri = '/projects/%s/keys/%s' % [ project_id, key_id ]

        api_delete(uri)

      end

    when :present

      if @old_properties[:ensure] == :absent

        # If the gitlab_deploy_key resource is now marked as present but was
        # previously marked as absent then create it in Gitlab.
 
        params = {
          :private_token => self.class.private_token,
          :key           => @property_hash[:key],
          :title         => key_title
        }

        uri = "/projects/%s/keys" % project_id

        api_post(uri, params)

      else

        # If the gitlab_deploy_key resource is now marked as present and it was
        # previously marked as present too then update the key in Gitlab if any
        # properties have changed. This is done by deleting the existing key
        # entry and creating a new one.

        if changed? && project_id && key_id && key_title

          # First delete the key.

          uri = '/projects/%s/keys/%s' % [ project_id, key_id ]

          api_delete(uri)

          # Then create a new key.

          params = {
            :private_token => self.class.private_token,
            :key           => @property_hash[:key],
            :title         => key_title
          }

          uri = "/projects/%s/keys" % project_id

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
