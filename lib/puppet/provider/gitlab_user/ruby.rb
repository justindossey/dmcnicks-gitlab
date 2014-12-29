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
      :private_token => self.token,
      :username      => resource[:username],
      :password      => resource[:password],
      :email         => resource[:email],
      :name          => resource[:fullname]
    }
    uri = '/users'
    RestClient.post(self.api_url + uri, params)
  end

  def destroy
    params = {
      :private_token => self.token
    }
    uri = '/users/%s' % user['id']
    RestClient.delete(self.api_url + uri, params)
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
    @property_hash[:name] = value
  end

  def password
    user['password']
  end

  def password=(value)
    @property_hash[:password] = value
  end

  # Flush properties that have been set.

  def flush
    @property_hash[:private_token] = self.token
    uri = '/users/%s' % user['id']
    RestClient.put(self.api_url + uri, @property_hash)
  end

  # Retrieve the user record.
 
  def user
    params = {
      :private_token => self.token
    }
    uri = '/users'
    response = RestClient.get(self.api_url + uri, params)
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
end
