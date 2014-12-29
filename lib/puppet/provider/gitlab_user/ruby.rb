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
    uri = '/users/%s' % user(token)['id']
    RestClient.delete(resource[:api_url] + uri, params)
  end

  def exists?
    return user != nil
  end

  # Getters and setters.

  def email
    user['email']
  end

  def email=(value)
    @property_hash[:email] = value
  end

  def fullname
    user['name']
  end

  def fullname=(value)
    @property_hash[:fullname] = value
  end

  def password
    user['password']
  end

  def password=(value)
    @property_hash[:password] = value
  end

  # Perform a login and return a session token.
  
  def login
    # If the password of the api_login user is being set we have to
    # do something clever here.
    if ( resource[:username] == resource[:api_login] ) && resource[:password]
      # Try logging in with the new password first, in case it has been
      # set already.
      if token = loginwith(resource[:password])
        return token
      end
    end
    return loginwith(resource[:api_password])
  end

  def loginwith(password)
    params = {
      :login    => resource[:api_login],
      :password => password
    }
    uri = '/session'
    response = RestClient.post(resource[:api_url] + uri, params)
    if response.code == 201
      session = JSON.parse(response)
      return session['private_token']
    else
      return nil
    end
  rescue
    return nil
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
    uri = '/users/%s' % user(token)['id']
    RestClient.put(resource[:api_url] + uri, @property_hash)
  end

end
