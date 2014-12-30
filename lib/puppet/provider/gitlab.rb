class Puppet::Provider::Gitlab < Puppet::Provider

  protected
  
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
