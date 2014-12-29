Puppet::Type.newtype(:gitlab_user_key) do

  desc 'A Gitlab user key'

  ensurable

  newparam(:title, :namevar => true) do
    desc 'The title of the user key'
    validate do |value|
      unless value =~ /^[\w@\.\-_ ]+$/
        raise ArgumentError , "%s is not a valid user key title" % value
      end
    end
  end

  newparam(:username) do
    desc 'The name of the user that the key is in'
    validate do |value|
      unless value =~ /^[\w\-_ ]+$/
        raise ArgumentError , "%s is not a valid username" % value
      end
    end
  end

  newparam(:key) do
    desc 'The key itself'
    validate do |value|
      unless value =~ /^ssh-[dr]sa [^ ]+ [\w@\.\-_]+$/
        raise ArgumentError , "%s is not a valid user key" % value
      end
    end
  end

  newparam(:userkey) do
    desc 'Username to fetch public key from'
    validate do |value|
      unless value =~ /^[a-z0-9]+$/
        raise ArgumentError , "%s is not a user name" % value
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
      raise Puppet::Error, "key title is required"
    end
    unless self[:key] or self[:userkey]
      raise Puppet::Error, "either key or userkey is required"
    end
  end

end
