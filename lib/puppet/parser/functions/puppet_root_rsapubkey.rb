module Puppet::Parser::Functions
  newfunction(:puppet_root_rsapubkey, :type => :rvalue) do |args|
    pubkey = '/root/.ssh/id_rsa.pub'
    if File.exists? pubkey
      File.read(pubkey).chomp
    end
  end
end
