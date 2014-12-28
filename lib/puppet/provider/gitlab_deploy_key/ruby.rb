require 'rest_client'

Puppet::Type.type(:gitlab_deploy_key).provide(:ruby) do

  desc 'Default provider for gitlab_deploy_key type'

  def create
    token = login()
    project_id = project_id(resource[:project])
    params = {
      :private_token => token,
      :title         => resource[:title],
      :key           => resource[:key]
    }
    keys_uri = "/projects/%s/keys" % project_id
    RestClient.post(resource[:api_url] + keys_uri, params)
  end

  def destroy
    project_id = project_id(resource[:project])
    id = id(
      :title => resource[:title],
      :project_id => project_id
    )
    token = login()
    params = {
      :private_token => token
    }
    keys_uri = "/projects/%s/keys/" % project_id
    RestClient.delete(resource[:api_url] + keys_uri + id.to_s, params)
  end

  def exists?
    return id(
      :title => resource[:title],
      :project_id => project_id(resource[:project])
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
      :id            => key[:project_id]
    }
    keys_uri = "/projects/%s/keys" % key[:project_id]
    response = RestClient.get(resource[:api_url] + keys_uri, params)
    if response.code == 200
      deploy_keys = JSON.parse(response)
      deploy_keys.each do |deploy_key|
        if deploy_key['title'] == key[:title]
          return deploy_key['id']
        end
      end
      return nil
    else
      return nil
    end
  end

  def project_id(name)
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

end
