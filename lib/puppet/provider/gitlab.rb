class Puppet::Provider::Gitlab < Puppet::Provider

  class_variable_set(:@@token, nil)
  class_variable_set(:@@api_url, nil)

  def self.token
    @@token
  end

  def self.token=(value)
    @@token = value
  end

  def self.api_url
    @@api_url
  end

  def self.api_url=(value)
    @@api_url = value
  end
end
