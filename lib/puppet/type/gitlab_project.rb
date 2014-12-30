Puppet::Type.newtype(:gitlab_project) do

  desc 'A Gitlab project'

  ensurable

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

  newproperty(:namespace) do
    desc 'The namespace that the project sits in'
    validate do |value|
      unless value =~ /^[\w\-_ ]+$/
        raise ArgumentError , "%s is not a valid namespace" % value
      end
    end
  end

  autorequire(:gitlab_session) do
    [ self[:session] ]
  end

  validate do
    unless self[:session]
      raise Puppet::Error, "session is required"
    end
  end
end
