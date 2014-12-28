require 'rest_client'

Puppet::Type.type(:gitlab_group).provide(:ruby) do

  desc 'Default provider for gitlab_group type'

  def create
    token = login()
    params = {
      :private_token => token,
      :name          => resource[:name],
      :path          => resource[:path]
    }
    RestClient.post(resource[:api_url] + '/groups', params)
  end

  def destroy
    id = id(resource[:name])
    token = login()
    params = {
      :private_token => token
    }
    RestClient.delete(resource[:api_url] + '/groups/' + id.to_s, params)
  end

  def exists?
    return id(resource[:name])
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
    
  def id(name)
    token = login
    params = {
      :private_token => token
    }
    response = RestClient.get(resource[:api_url] + '/groups', params)
    if response.code == 200
      groups = JSON.parse(response)
      groups.each do |group|
        if group['name'] == name
          return group['id']
        end
      end
      return nil
    else
      return nil
    end
  end

end
