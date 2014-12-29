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

  newparam(:fromuser) do
    desc 'Username to fetch public key from'
    validate do |value|
      unless value =~ /^[a-z0-9]+$/
        raise ArgumentError , "%s is not a user name" % value
      end
    end
  end

  validate do
    unless self[:key] or self[:fromuser]
      raise Puppet::Error, "either key or fromuser is required"
    end
  end

end
