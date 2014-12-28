Puppet::Type.newtype(:gitlab_project) do

  desc 'A Gitlab project'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the project'
    validate do |value|
      unless value =~ /^[\w\-_ ]+$/
        raise ArgumentError , "%s is not a valid project name" % value
      end
    end
  end

  newparam(:group) do
    desc 'The group that the project is in'
    validate do |value|
      unless value =~ /^[\w\-_ ]+$/
        raise ArgumentError , "%s is not a valid project group" % value
      end
    end
  end

  newparam(:api_login) do
    desc 'The login to use to connect to the Gitlab API'
    validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError , "%s is not a valid API login" % value
      end
    end
  end

  newparam(:api_password) do
    desc 'The password for the API login'
  end

  newparam(:api_url) do
    desc 'The URL of the Gitlab API'
    validate do |value|
      unless value =~ /^http(s)?:\/\/(\w+)(\.\w+)+(\/)?/
        raise ArgumentError , "%s is not a valid API URL" % value
      end
    end
  end

  validate do
    unless self[:api_url] and self[:api_login] and self[:api_password]
      raise Puppet::Error, "api_url, api_login, api_password are required"
    end
    unless self[:name] 
      raise Puppet::Error, "project name is required"
    end
  end

end
