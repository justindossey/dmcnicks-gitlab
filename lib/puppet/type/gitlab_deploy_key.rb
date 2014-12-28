Puppet::Type.newtype(:gitlab_deploy_key) do

  desc 'A Gitlab deploy key'

  ensurable

  newparam(:title, :namevar => true) do
    desc 'The title of the deploy_key'
    validate do |value|
      unless value =~ /^[\w@\.\-_ ]+$/
        raise ArgumentError , "%s is not a valid deploy key title" % value
      end
    end
  end

  newparam(:project) do
    desc 'The name of the project that the deploy_key is in'
    validate do |value|
      unless value =~ /^[\w\-_ ]+$/
        raise ArgumentError , "%s is not a valid project name" % value
      end
    end
  end

  newparam(:key) do
    desc 'The deploy key itself'
    validate do |value|
      unless value =~ /^ssh-[dr]sa [^ ]+ [\w@\.\-_]+$/
        raise ArgumentError , "%s is not a valid deploy key" % value
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
    unless self[:title] 
      raise Puppet::Error, "deploy key title is required"
    end
  end

end
