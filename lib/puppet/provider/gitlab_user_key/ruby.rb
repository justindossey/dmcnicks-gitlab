require 'puppet/provider/gitlab'
require 'json'

Puppet::Type.type(:gitlab_user_key).provide(
  :ruby,
  :parent => Puppet::Provider::Gitlab
) do

  desc 'Default provider for gitlab_user_key type'

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
      :title         => resource[:title],
      :key           => newkey,
    }
    uri = "/users/%s/keys" % user_id
    RestClient.post(@@api_url + uri, params)
  end

  def destroy
    params = {
      :private_token => @@token
    }
    uri = "/users/%s/keys/%s" % [ user_id, key_id ]
    RestClient.delete(@@api_url + uri, params)
  end

  def exists?
    return key_id != nil
  end

  # Returns the new key.

  def newkey
    # If the new key has been specified explicitly, just return it.
    if resource[:key]
      return resource[:key]
    end
    # If a user has been specified, find the key in the user's home directory.
    if resource[:fromuser]
      homedir = Dir.home(resource[:fromuser])
      keyfile = File.join(homedir, '.ssh', 'id_rsa.pub')
      if ! File.exists?(keyfile)
        keyfile = File.join(homedir, '.ssh', 'id_dsa.pub')
      end
      if File.exists?(keyfile)
       return File.open(keyfile).read.chomp
      end
      return nil
    end
  end

  # Retrieve the key ID.

  def key_id
    params = {
      :private_token => @@token
    }
    uri = "/users/%s/keys" % user_id
    response = RestClient.get(@@api_url + uri, params)
    if response.code == 200
      keys = JSON.parse(response)
      keys.each do |key|
        if key['title'] == resource[:title]
          return key['id']
        end
      end
      return nil
    else
      return nil
    end
  end

  # Retrieve the user ID.

  def user_id
    params = {
      :private_token => @@token
    }
    uri = '/users'
    response = RestClient.get(@@api_url + uri, params)
    if response.code == 200
      users = JSON.parse(response)
      users.each do |user|
        if user['username'] == resource[:username]
          return user['id'].to_s
        end
      end
      return nil
    end
  end
end
