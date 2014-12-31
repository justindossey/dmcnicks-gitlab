require 'json'

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
  # Methods for interacting with the API.
  #

  def self.api_get(uri, params = {})
    
    params[:private_token] = self.private_token
    
    r = RestClient::Resource.new(self.api_url + uri,
                                 :verify_ssl => OpenSSL::SSL::VERIFY_NONE)
    
    begin
      r.get(params)
    rescue RestClient::Exception => e
      raise "api_get %s failed: %s: %s" % [ uri, e.message, e.response ]
    end
  
  end

  def self.api_post(uri, params = {})
    
    params[:private_token] = self.private_token
    
    r = RestClient::Resource.new(self.api_url + uri,
                                 :verify_ssl => OpenSSL::SSL::VERIFY_NONE)
    
    begin
      r.post(params)
    rescue RestClient::Exception => e
      raise "api_post %s failed: %s: %s" % [ uri, e.message, e.response ]
    end

  end

  def self.api_put(uri, params = {})

    params[:private_token] = self.private_token

    r = RestClient::Resource.new(self.api_url + uri,
                                 :verify_ssl => OpenSSL::SSL::VERIFY_NONE)

    begin
      r.put(params)
    rescue RestClient::Exception => e
      raise "api_put %s failed: %s: %s" % [ uri, e.message, e.response ]
    end

  end

  def self.api_delete(uri, params = {})

    params[:private_token] = self.private_token

    r = RestClient::Resource.new(self.api_url + uri,
                                 :verify_ssl => OpenSSL::SSL::VERIFY_NONE)

    begin
      r.delete(params)
    rescue RestClient::Exception => e
      raise "api_delete %s failed: %s: %s" % [ uri, e.message, e.response ]
    end

  end

  def self.api_login(login, password)

    params = {
      :login    => login,
      :password => password
    }

    r = RestClient::Resource.new(self.api_url + '/session',
                                 :verify_ssl => OpenSSL::SSL::VERIFY_NONE)

    begin

      response = r.post(params)

    rescue RestClient::Exception => e

      # If the post failed specifically because of a 401 unauthorized error
      # then return nil to signify that the login failed.

      if e.http_code == 401
        return nil
      else
        raise "api_login %s failed: %s: %s" % [ login, e.message, e.response ]
      end

    end

    if response && response.code == 201
      session = JSON.parse(response)
      return session['private_token']
    else
      return nil
    end

  end

  # Instance method equivalents for the above methods.

  def api_get(uri, params = {})
    self.class.api_get(uri, params)
  end

  def api_post(uri, params = {})
    self.class.api_post(uri, params)
  end

  def api_put(uri, params = {})
    self.class.api_put(uri, params)
  end

  def api_delete(uri, params = {})
    self.class.api_delete(uri, params)
  end

  def api_login(login, password)
    self.class.api_login(login, password)
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

    # Check if the id matches any groups.

    uri = '/groups'
    response = api_get(uri)

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

    # Check if the id matches any users.

    uri = '/users'
    response = api_get(uri)

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

    # Check if the id matches any projects.

    uri = '/projects/all'
    response = api_get(uri)

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
    self.class.slug_for(name)
  end

  def group_id_for(name)
    self.class.group_id_for(name)
  end

  def user_id_for(name)
    self.class.user_id_for(name)
  end

  def project_id_for(name)
    self.class.project_id_for(name)
  end

end
