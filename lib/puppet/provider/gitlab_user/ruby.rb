require 'rest_client'
require 'json'

Puppet::Type.type(:gitlab_user).provide(:ruby) do

  desc 'Default provider for gitlab_user type'

  def create
    token = login()
    params = {
      :private_token => token,
      :username      => resource[:username],
      :password      => resource[:password],
      :email         => resource[:email],
      :name          => resource[:fullname]
    }
    RestClient.post(resource[:api_url] + '/users', params)
  end

  def destroy
    id = id(resource[:username])
    token = login()
    params = {
      :private_token => token
    }
    RestClient.delete(resource[:api_url] + '/users/' + id.to_s, params)
  end

  def exists?
    return id(resource[:username])
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
    
  def id(username)
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

end
