class Puppet::Provider::Gitlab < Puppet::Provider

  # Initialise the class variables.

  self.class_variable_set(:@@private_token, nil)
  self.class_variable_set(:@@api_url, nil)

  # These create, destroy and exists? methods provide the basic ensurable
  # functionality for all of the Gitlab providers. Since we are using prefetch
  # and flush, these methods only have to manage the @propety_hash. All of the
  # hard work is done by the flush method in each provider.

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

  def self.private_token
    @@private_token
  end

  def self.private_token=(value)
    @@private_token = value
  end

  def self.api_url
    @@api_url
  end

  def self.api_url=(value)
    @@api_url = value
  end

end
