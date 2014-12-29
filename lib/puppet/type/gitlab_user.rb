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
      unless value =~ /^([\w\'\-_\. ]+)$/
        raise ArgumentError , "%s is not a valid full name" % value
      end
    end
  end

end
