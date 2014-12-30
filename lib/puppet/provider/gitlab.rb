class Puppet::Provider::Gitlab < Puppet::Provider

  protected
  
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
