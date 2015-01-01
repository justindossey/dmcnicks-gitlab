Facter.add("hardware_platform") do
  setcode do
    Facter::Util::Resolution.exec('/bin/uname -i')
  end
end
