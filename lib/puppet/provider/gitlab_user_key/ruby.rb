require 'rest_client'

Puppet::Type.type(:gitlab_user_key).provide(:ruby) do

  desc 'Default provider for gitlab_user_key type'

  def create
    token = login()
    key = key()
    user_id = user_id(resource[:username])
    params = {
      :private_token => token,
      :title         => resource[:title],
      :key           => key,
    }
    keys_uri = "/users/%s/keys" % user_id
    RestClient.post(resource[:api_url] + keys_uri, params)
  end

  def destroy
    user_id = user_id(resource[:username])
    id = id(
      :title => resource[:title],
      :user_id => user_id
    )
    token = login()
    params = {
      :private_token => token
    }
    keys_uri = "/users/%s/keys/" % user_id
    RestClient.delete(resource[:api_url] + keys_uri + id.to_s, params)
  end

  def exists?
    return id(
      :title => resource[:title],
      :user_id => user_id(resource[:username])
    )
  end

  def login
    params = {
      :login    => resource[:api_login],
      :password => resource[:api_password]
    }
    response = RestClient.post(resource[:api_url] + '/session', params)
    if response.code == 201
      session = JSON.parse(response)
      return session['private_token']
    else
      return nil
    end
  end
    
  def id(key = {})
    token = login
    params = {
      :private_token => token,
      :id            => key[:user_id]
    }
    keys_uri = "/users/%s/keys" % key[:user_id]
    response = RestClient.get(resource[:api_url] + keys_uri, params)
    if response.code == 200
      user_keys = JSON.parse(response)
      user_keys.each do |user_key|
        if user_key['title'] == key[:title]
          return user_key['id']
        end
      end
      return nil
    else
      return nil
    end
  end

  def user_id(username)
    token = login
    params = {
      :private_token => token
    }
    response = RestClient.get(resource[:api_url] + '/users', params)
    if response.code == 200
      users = JSON.parse(response)
      users.each do |user|
        if user['username'] == username
          return user['id']
        end
      end
      return nil
    else
      return nil
    end
  end

  def key
    if resource[:key]
      return resource[:key]
    end
    homedir = Dir.home(resource[:username])
    keyfile = File.join(homedir, '.ssh', 'id_dsa.pub')
    if ! File.exists?(keyfile)
      keyfile = File.join(homedir, '.ssh', 'id_rsa.pub')
    end
    if File.exists?(keyfile)
     return File.open(keyfile).read.chomp
    end
    return nil
  end

end
