require 'json'

class Puppet::Provider::Gitlab < Puppet::Provider

  # The URI of the current API.

  self.const_set(:API_URI, '/api/v3')

  # Shorter version of the OpenSSL::SSL::VERIFY_NONE constant.

  self.const_set(:NONE, OpenSSL::SSL::VERIFY_NONE)

  # Initialise the class variables.

  self.class_variable_set(:@@private_token, nil)
  self.class_variable_set(:@@site_url, nil)

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
  # Class setter methods that allow the gitlab_session provider to set the
  # private_token and site_url class variables.
  #

  def self.private_token=(value)
    @@private_token = value
  end

  def self.site_url=(value)
    @@site_url = value
  end

  #
  # Methods for interacting with the API.
  #

  # Perform a GET request and return a JSON response.

  def self.api_get(uri, params = {})
    
    params[:private_token] = @@private_token

    url = @@site_url + API_URI + uri
    
    resource = RestClient::Resource.new(url, :verify_ssl => NONE)
    
    begin

      response = resource.get(params)

      if response && response.code == 200
        return JSON.parse(response)
      else
        raise "api_get %s invalid response: %s" % [ uri, response.code ]
      end

    rescue RestClient::Exception => e

      raise "api_get %s failed: %s: %s" % [ uri, e.message, e.response ]

    end
  
  end

  # Perform a POST request and return a JSON response.

  def self.api_post(uri, params = {})
    
    params[:private_token] = @@private_token

    url = @@site_url + API_URI + uri
    
    resource = RestClient::Resource.new(url, :verify_ssl => NONE)
    
    begin

      response = resource.post(params)

      if response && response.code == 201
        return JSON.parse(response)
      else
        raise "api_post %s invalid response: %s" % [ uri, response.code ]
      end

    rescue RestClient::Exception => e

      raise "api_post %s failed: %s: %s" % [ uri, e.message, e.response ]

    end
  
  end

  # Perform a PUT request and return a JSON response.

  def self.api_put(uri, params = {})
    
    params[:private_token] = @@private_token

    url = @@site_url + API_URI + uri
    
    resource = RestClient::Resource.new(url, :verify_ssl => NONE)
    
    begin

      response = resource.put(params)

      if response && response.code == 200
        return JSON.parse(response)
      else
        raise "api_put %s invalid response: %s" % [ uri, response.code ]
      end

    rescue RestClient::Exception => e

      raise "api_put %s failed: %s: %s" % [ uri, e.message, e.response ]

    end
  
  end

  # Perform a DELETE request and return a JSON response.

  def self.api_delete(uri, params = {})
    
    params[:private_token] = @@private_token

    url = @@site_url + API_URI + uri
    
    resource = RestClient::Resource.new(url, :verify_ssl => NONE)
    
    begin

      response = resource.delete(params)

      if response && response.code == 200
        return JSON.parse(response)
      else
        raise "api_delete %s invalid response: %s" % [ uri, response.code ]
      end

    rescue RestClient::Exception => e

      raise "api_delete %s failed: %s: %s" % [ uri, e.message, e.response ]

    end
  
  end

  # Attempt to login with the given credentials. If successful, return the
  # private token. If not, return nil.

  def self.api_login(login, password)
    
    params = {
      :login    => login,
      :password => password
    }

    url = @@site_url + API_URI + '/session'
    
    resource = RestClient::Resource.new(url, :verify_ssl => NONE)
    
    begin

      response = resource.post(params)
     
    rescue RestClient::Exception => e

      # If the post failed specifically because of a 401 unauthorized error
      # then return nil to signify that the login failed.

      if e.http_code == 401
        return nil
      else
        raise "api_login %s failed: %s: %s" % [ login, e.message, e.response ]
      end

    end

    # If we get a valid response, parse the output and return the private
    # token.

    if response && response.code == 201
      return JSON.parse(response)['private_token']
    end
  
    # Otherwise, return nil to signify that the login failed.

    return nil

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

    groups = api_get('/groups')

    groups.each do |group|
      if group['name'] == name
        return group['id']
      end
    end

    return nil

  end

  # Returns the user ID of the given user.

  def self.user_id_for(name)

    # Check if the id matches any users.

    users = api_get('/users')

    users.each do |user|
      if user['username'] == name
        return user['id']
      end
    end

    return nil

  end

  # Returns the project ID of the given project.

  def self.project_id_for(name)

    # Check if the id matches any projects.

    projects = api_get('/projects/all')

    projects.each do |project|
      if project['projectname'] == name
        return project['id']
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
