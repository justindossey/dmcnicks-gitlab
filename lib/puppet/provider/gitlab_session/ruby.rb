require 'puppet/provider/gitlab'
require 'json'

Puppet::Type.type(:gitlab_session).provide(
  :rubyone,
  :parent => Puppet::Provider::Gitlab
) do

  desc 'Default provider for gitlab_session type'

end
