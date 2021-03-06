Puppet::Type.newtype(:gitlab_user) do

  desc 'A Gitlab user'

  ensurable

  # Parameters.
  
  newparam(:name) do
    desc 'The name of the user'
    validate do |value|
      unless value =~ /^[a-z0-9]+$/
        raise ArgumentError , "%s is not a valid username" % value
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

  # Properties.

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
    validate do |value|
      if value && value.length < 8
        raise ArgumentError , "password is too short (minimum is 8 characters)" 
      end
    end
  end

  newproperty(:fullname) do
    desc 'The full name of the user'
    validate do |value|
      unless value =~ /^([\w\'\-_\. ]+)$/
        raise ArgumentError , "%s is not a valid full name" % value
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
