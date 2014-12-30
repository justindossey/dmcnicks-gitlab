require 'puppet/provider/gitlab'
require 'json'

Puppet::Type.type(:gitlab_user).provide(
  :ruby,
  :parent => Puppet::Provider::Gitlab
) do

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
    params = {
      :private_token => @@token,
      :username      => resource[:username],
      :password      => resource[:password],
      :email         => resource[:email],
      :name          => resource[:fullname]
    }
    uri = '/users'
    RestClient.post(@@api_url + uri, params)
  end

  def destroy
    params = {
      :private_token => @@token
    }
    uri = '/users/%s' % user['id']
    RestClient.delete(@@api_url + uri, params)
  end

  def exists?
    return user != nil
  end

  # Getters.

  def email
    user['email']
  end

  def fullname
    user['name']
  end

  def password
    user['password']
  end

  # Setters.

  def email=(value)
    @property_hash[:email] = value
  end

  def fullname=(value)
    @property_hash[:name] = value
  end

  def password=(value)
    @property_hash[:password] = value
  end

  # Prefetch properties.

  def prefetch(newresources)
    user = user(newresources[:username])
    user.symbolize_keys
    properties = [ :email, :fullname, :password ]
    properties.each do |property|
      if newresources[property]
        @property_hash[property] = resources[property]
      end
    end
  end

  # Flush properties that have been set.

  def flush
    params = {
      :private_token => @@token
    }
    properties = [ :email, :fullname, :password ]
    properties.each do |property|
      if @property_hash[property]
        params[property] = @property_hash[property]
      end
    end
    uri = '/users/%s' % user['id']
    RestClient.put(@@api_url + uri, params)
    @property_hash.clear
  end

  # Retrieve the user record.
 
  def user(username = resource[:username])
    params = {
      :private_token => @@token
    }
    uri = '/users'
    response = RestClient.get(@@api_url + uri, params)
    if response.code == 200
      users = JSON.parse(response)
      users.each do |user|
        if user['username'] == username
          return user
        end
      end
      return nil
    end
  end
end
