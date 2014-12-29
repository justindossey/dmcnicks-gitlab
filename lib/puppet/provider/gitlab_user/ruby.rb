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
      :name          => resource[:name]
    }
    uri = '/users'
    RestClient.post(resource[:api_url] + uri, params)
  end

  def destroy
    token = login
    params = {
      :private_token => token
    }
    uri = '/users/' + user_id(resource[:username], token)
    RestClient.delete(resource[:api_url] + uri, params)
  end

  def exists?
    return user_id(resource[:username])
  end

  # Allow password to be set.

  def password
    get['password']
  end

  def password(value)
    set(:password, value)
  end

  # Allow email address to be set.

  def email
    get['email']
  end

  def email(value)
    set(:email, value)
  end

  # Allow name to be set.

  def name
    get['name']
  end

  def name(value)
    set(:name, value)
  end

  # Internal methods.
  
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
    
  def get(token = nil)
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

  def set(name, value, token = nil)
    token = token ? token : login
    params = {
      name => value,
      :private_token => token
    }
    uri = '/users/' + user_id(resource[:username], token)
    RestClient.put(resource[:api_url] + uri, params)
  end

  def user_id(username, token = nil)
    token = token ? token : login
    params = {
      :private_token => token
    }
    uri = '/users'
    response = RestClient.get(resource[:api_url] + uri, params)
    if response.code == 200
      users = JSON.parse(response)
      users.each do |user|
        if user['username'] == username
          return user['id'].to_s
        end
      end
      return nil
    else
      return nil
    end
  end

end
