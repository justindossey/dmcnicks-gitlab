Puppet::Type.newtype(:gitlab_user_key) do

  desc 'A Gitlab user key'

  ensurable

  # Parameters.
  
  newparam(:name) do
    desc 'The name of the resource'
    validate do |value|
      unless value =~ /^[\w@\.\-_ ]+$/
        raise ArgumentError , "%s is not a valid user key name" % value
      end
    end
  end

  newparam(:session) do
    desc 'The Gitlab API session to be associated with'
    validate do |value|
      unless value =~ /^[\w\-_ ]+$/
        raise ArgumentError , "%s is not a valid session name" % value
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

  # Properties.

  newproperty(:key) do
    desc 'The key itself'
    validate do |value|
      unless value =~ /^ssh-[dr]sa [^ ]+ [\w@\.\-_]+$/
        raise ArgumentError , "%s is not a valid user key" % value
      end
    end
  end

  # Validation.

  validate do
    unless self[:session] && self[:username]
      raise Puppet::Error, "session and username are required"
    end
  end

  # Autorequires.

  autorequire(:gitlab_session) do
    [ self[:session] ]
  end

  autorequire(:gitlab_user) do
    [ self[:username] ]
  end

end
