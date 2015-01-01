Facter.add('gitlab_root_rsapubkey') do
  pubkey = '/root/.ssh/id_rsa.pub'
  if File.exists? pubkey
    setcode do
      File.read(pubkey).chomp
    end
  end
end
