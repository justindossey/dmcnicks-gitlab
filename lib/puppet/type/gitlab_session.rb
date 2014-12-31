Puppet::Type.newtype(:gitlab_session) do

  desc 'A Gitlab session'

  newparam(:name) do
    desc 'The name of this Gitlab session'
    validate do |value|
      unless value =~ /^[\w\-_ ]+$/
        raise ArgumentError , "%s is not a valid session name" % value
      end
    end
  end

  newparam(:url) do
    desc 'The URL of the Gitlab API'
    validate do |value|
      unless value =~ /^http(s)?:\/\/(\w+)(\.\w+)+(\/)?/
        raise ArgumentError , "%s is not a valid API URL" % value
      end
    end
  end

  newparam(:login) do
    desc 'The login to use to connect to the Gitlab API'
    validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError , "%s is not a valid API login" % value
      end
    end
  end

  newparam(:password) do
    desc 'The password for the API login'
  end

  newparam(:previous_password) do
    desc 'The password for the API login'
  end

  validate do
    unless self[:url] and self[:login] and self[:password]
      raise Puppet::Error, "url, login and password are required"
    end
  end
end
