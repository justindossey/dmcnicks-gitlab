Puppet::Type.newtype(:gitlab_deploy_key) do

  desc 'A Gitlab deploy key'

  ensurable

  # Parameters.

  newparam(:name) do
    desc 'The name of the resource'
    validate do |value|
      unless value =~ /^[\w@\.\-_ ]+$/
        raise ArgumentError , "%s is not a valid deploy key name" % value
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

  newparam(:project) do
    desc 'The name of the project that the key is in'
    validate do |value|
      unless value =~ /^[\w\-_ ]+$/
        raise ArgumentError , "%s is not a valid project" % value
      end
    end
  end

  # Properties.

  newproperty(:key) do
    desc 'The key itself'
    validate do |value|
      unless value =~ /^ssh-[dr]sa [^ ]+ [\w@\.\-_]+$/
        raise ArgumentError , "%s is not a valid deploy key" % value
      end
    end
  end

  # Validation.

  validate do
    unless self[:session] && self[:project]
      raise Puppet::Error, "session and project are required"
    end
  end

  # Autorequires.

  autorequire(:gitlab_session) do
    [ self[:session] ]
  end

  autorequire(:gitlab_project) do
    [ self[:project] ]
  end

end
