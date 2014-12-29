Puppet::Type.newtype(:gitlab_user) do

  desc 'A Gitlab user'

  ensurable

  newparam(:username, :namevar => true) do
    desc 'The name of the user'
    validate do |value|
      unless value =~ /^[a-z0-9]+$/
        raise ArgumentError , "%s is not a valid username" % value
      end
    end
  end

  newproperty(:email) do
    desc 'The email address of the user'
    validate do |value|
      unless value =~ /^[a-z0-9]+@(\w+)(\.\w+)+$/
        raise ArgumentError , "%s is not a valid email address" % value
      end
    end
  end

  newproperty(:password) do
    desc 'The password for the user'
  end

  newproperty(:fullname) do
    desc 'The full name of the user'
    validate do |value|
      unless value =~ /^([\w\-_\. ]+)$/
        raise ArgumentError , "%s is not a valid full name" % value
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
  end

end
