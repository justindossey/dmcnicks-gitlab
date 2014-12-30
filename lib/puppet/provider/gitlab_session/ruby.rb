require 'puppet/provider/gitlab'
require 'json'

Puppet::Type.type(:gitlab_session).provide(
  :rubyone,
  :parent => Puppet::Provider::Gitlab
) do

  desc 'Default provider for gitlab_session type'

  # Make sure that the rest-client package is available.

  confine :true => begin
    begin
      require 'rest_client'
      true
    rescue LoadError
      false
    end
  end  

end
