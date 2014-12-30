Puppet::Type.newtype(:gitlab_user_key) do

  desc 'A Gitlab user key'

  ensurable

  newparam(:name) do
    desc 'The name of the resource'
    validate do |value|
      unless value =~ /^[\w@\.\-_ ]+$/
        raise ArgumentError , "%s is not a valid user key name" % value
      end
    end
  end

  newproperty(:key) do
    desc 'The key itself'
    validate do |value|
      unless value =~ /^ssh-[dr]sa [^ ]+ [\w@\.\-_]+$/
        raise ArgumentError , "%s is not a valid user key" % value
      end
    end
  end

  newparam(:session) do
    desc 'The Gitlab API session to be associated with'
  end

  newparam(:username) do
    desc 'The name of the user that the key is in'
    validate do |value|
      unless value =~ /^[\w\-_ ]+$/
        raise ArgumentError , "%s is not a valid username" % value
      end
    end
  end

  validate do
    unless self[:key] && self[:session] && self[:username]
      raise Puppet::Error, "key, session and username are required"
    end
  end

  autorequire(:gitlab_session) do
    [ self[:session] ]
  end

  autorequire(:gitlab_user) do
    [ self[:username] ]
  end

end
