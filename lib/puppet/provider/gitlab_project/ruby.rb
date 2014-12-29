Puppet::Type.type(:gitlab_project).provide(:ruby) do

  desc 'Default provider for gitlab_project type'

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
    token = login()
    namespace_id = group_id(resource[:group])
    params = {
      :private_token => token,
      :name          => resource[:name],
      :namespace_id  => namespace_id
    }
    response = RestClient.post(resource[:api_url] + '/projects', params)
  end

  def destroy
    id = id(resource[:name])
    token = login()
    params = {
      :private_token => token
    }
    RestClient.delete(resource[:api_url] + '/projects/' + id.to_s, params)
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
    response = RestClient.get(resource[:api_url] + '/projects/all', params)
    if response.code == 200
      projects = JSON.parse(response)
      projects.each do |project|
        if project['name'] == name
          return project['id']
        end
      end
      return nil
    else
      return nil
    end
  end

  def group_id(name)
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
