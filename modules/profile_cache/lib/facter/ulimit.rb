Facter.add(:ulimit) do
  confine :kernel => :Linux
  setcode do
    descriptors = Facter::Util::Resolution.exec('ulimit -n')
  end
end
