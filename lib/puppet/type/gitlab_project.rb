Puppet::Type.newtype(:gitlab_project) do

  desc 'A Gitlab project'

  ensurable

  # Parameters.

  newparam(:name) do
    desc 'The name of the project'
    validate do |value|
      unless value =~ /^([\w\-_ ]+)$/
        raise ArgumentError , "%s is not a valid project name" % value
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

  newparam(:owner) do
    desc 'The owner of the project'
    validate do |value|
      unless value =~ /^[a-z0-9]+$/
        raise ArgumentError , "%s is not a valid project owner name" % value
      end
    end
  end

  newparam(:namespace) do
    desc 'The namespace that the project sits in'
    validate do |value|
      unless value =~ /^[\w\-_ ]+$/
        raise ArgumentError , "%s is not a valid namespace" % value
      end
    end
  end

  # Validation.

  validate do
    unless self[:session]
      raise Puppet::Error, "session is required"
    end
    if self[:owner] && self[:namespace]
      raise Puppet::Error, "cannot specify both owner and namespace"
    end
  end

  # Autorequires.

  autorequire(:gitlab_session) do
    [ self[:session] ]
  end

  autorequire(:gitlab_user) do
    [ self[:owner] ]
  end

end
