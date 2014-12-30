class Puppet::Provider::Gitlab < Puppet::Provider

  # The create, destroy and exists? methods provide the basic ensurable
  # functionality for all of the Gitlab providers. Since we are using
  # prefetch/flush, these methods only have to manage the @propety_hash.

  def create
    @property_hash[:ensure] = :present
    self.class.resource_type.validproperties.each do |property|
      if val = resource.should(property)
        @property_hash[property] = val
      end
    end
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] != :absent
  end

  def token
    Puppet::Provider::Gitlab.class_variable_get(:@@token)
  end

  def token=(value)
    Puppet::Provider::Gitlab.class_variable_set(:@@token, value)
  end

  def api_url
    Puppet::Provider::Gitlab.class_variable_get(:@@api_url)
  end

  def api_url=(value)
    Puppet::Provider::Gitlab.class_variable_set(:@@api_url, value)
  end
end
