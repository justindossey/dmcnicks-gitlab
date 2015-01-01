Puppet::Type.newtype(:gitlab_group) do

  desc 'A Gitlab group'

  ensurable

  # Parameters.

  newparam(:name) do
    desc 'The name of the group'
    validate do |value|
      unless value =~ /^[\w\-_ ]+$/
        raise ArgumentError , "%s is not a valid group name" % value
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
    desc 'A user that should be a member of the group with owner rights'
    validate do |value|
      unless value =~ /^[a-z0-9]+$/
        raise ArgumentError , "%s is not a valid owner username" % value
      end
    end
  end

  # Validation.

  validate do
    unless self[:session]
      raise Puppet::Error, "session is required"
    end
  end

  # Autorequires.

  autorequire(:gitlab_session) do
    [ self[:session] ]
  end

end
