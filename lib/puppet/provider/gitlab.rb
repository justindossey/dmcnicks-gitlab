class Puppet::Provider::Gitlab < Puppet::Provider

  # Initialise the class variables.

  self.class_variable_set(:@@token, nil)
  self.class_variable_set(:@@api_url, nil)

  # The create, destroy and exists? methods provide the basic ensurable
  # functionality for all of the Gitlab providers. Since we are using
  # prefetch/flush, these methods only have to manage the @propety_hash.

  def create
    @property_hash[:ensure] = :present
    self.class.resource_type.validproperties.each do |property|
      if value = resource.should(property)
        @property_hash[property] = value
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
    @@token
  end

  def token=(value)
    @@token = value
  end

  def api_url
    @@api_url
  end

  def api_url=(value)
    @@api_url = value
  end

end
