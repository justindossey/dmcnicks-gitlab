require 'json'

Puppet::Type.type(:gitlab_user).provide(:ruby) do

  desc 'Default provider for gitlab_user type'

  # Confine the provider to only run once the rest-client package is
  # available. Puppet will install the rest-client package during the
  # first run. This confine will return true in subsequent runs.
  
  confine :true => begin
    begin
      require 'rest_client'
      true
    rescue LoadError
      false
    end
  end  

  def create
    token = login
    params = {
      :private_token => token,
      :username      => resource[:username],
      :password      => resource[:password],
      :email         => resource[:email],
      :name          => resource[:fullname]
    }
    uri = '/users'
    RestClient.post(resource[:api_url] + uri, params)
  end

  def destroy
    token = login
    params = {
      :private_token => token
    }
    uri = '/users/' + user(token)['id']
    RestClient.delete(resource[:api_url] + uri, params)
  end

  def exists?
    return user != nil
  end

  # Allow password to be set.

  def password
    user['password']
  end

  def password=(value)
    @property_hash[:password] = value
  end

  # Allow email address to be set.

  def email
    user['email']
  end

  def email=(value)
    @property_hash[:email] = value
  end

  # Allow full name to be set.

  def fullname
    user['name']
  end

  def fullname=(value)
    @property_hash[:fullname] = value
  end

  # Perform a login and return a session token.
  
  def login
    params = {
      :login    => resource[:api_login],
      :password => resource[:api_password]
    }
    uri = '/session'
    response = RestClient.post(resource[:api_url] + uri, params)
    if response.code == 201
      session = JSON.parse(response)
      return session['private_token']
    else
      return nil
    end
  end
    
  # Retrieve the user record.
 
  def user(token = nil)
    token = token ? token : login
    params = {
      :private_token => token
    }
    uri = '/users'
    response = RestClient.get(resource[:api_url] + uri, params)
    if response.code == 200
      users = JSON.parse(response)
      users.each do |user|
        if user['username'] == resource[:username]
          return user
        end
      end
      return nil
    end
  end

  # Flush any property changes.

  def flush
    token = login
    @property_hash[:private_token] = token
    uri = '/users/' + user(token)['id']
    RestClient.put(resource[:api_url] + uri, @property_hash)
  end

end
