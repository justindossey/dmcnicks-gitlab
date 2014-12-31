class Puppet::Provider::Gitlab < Puppet::Provider

  # Initialise the class variables.

  self.class_variable_set(:@@private_token, nil)
  self.class_variable_set(:@@api_url, nil)

  # These create, destroy and exists? methods provide the basic ensurable
  # functionality for all of the Gitlab providers. Since we are using prefetch
  # and flush, these methods only have to manage the @propety_hash. All of the
  # hard work is done by the flush method in each provider.

  def create
    @property_hash[:ensure] = :present
    self.class.resource_type.validproperties.each do |property|
      if value = resource.should(property)
        @property_hash[property] = value
      end
    end
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] != :absent
  end

  #
  # Class methods that give provider subclasses access to the shared
  # private_token and api_url class variables.
  #

  def self.private_token
    @@private_token
  end

  def self.private_token=(value)
    @@private_token = value
  end

  def self.api_url
    @@api_url
  end

  def self.api_url=(value)
    @@api_url = value
  end

  #
  # Utility methods for provider subclasses.
  #

  # Returns a slug created from the given name.

  def self.slug_for(name)
    name.downcase.gsub(/[^a-z0-9]+/, '-').sub(/^-/, '').sub(/-$/, '')
  end

  # Returns the group ID of the given group.

  def self.group_id_for(name)

    params = {
      :private_token => self.private_token
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

    return nil

  end

  # Returns the user ID of the given user.

  def self.user_id_for(name)

    params = {
      :private_token => self.private_token
    }

    # Check if the id matches any users.

    uri = '/users'
    response = RestClient.get(self.api_url + uri, params)

    if response.code == 200
      users = JSON.parse(response)
      users.each do |user|
        if user['username'] == name
          return user['id']
        end
      end
    end

    return nil

  end

  # Returns the project ID of the given project.

  def self.project_id_for(name)

    params = {
      :private_token => self.private_token
    }

    # Check if the id matches any projects.

    uri = '/projects/all'
    response = RestClient.get(self.api_url + uri, params)

    if response.code == 200
      projects = JSON.parse(response)
      projects.each do |project|
        if project['projectname'] == name
          return project['id']
        end
      end
    end

    return nil

  end

  # Create equivalent instance methods for the above class methods.

  def slug_for(name)
    return self.class.slug_for(name)
  end

  def group_id_for(name)
    return self.class.group_id_for(name)
  end

  def user_id_for(name)
    return self.class.user_id_for(name)
  end

  def project_id_for(name)
    return self.class.project_id_for(name)
  end

end
