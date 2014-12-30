class Puppet::Provider::Gitlab < Puppet::Provider

  protected
  
    def token
      class_variable_get(:@@token)
    end
  
    def token=(value)
      class_variable_set(:@@token, value)
    end
  
    def api_url
      class_variable_get(:@@api_url)
    end
  
    def api_url=(value)
      class_variable_set(:@@api_url, value)
    end
end
