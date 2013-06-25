dep 'account' do
  requires 'account packages'
  requires 'account groups'
  requires 'account users'
  requires 'admins can passwordless sudo'
  requires 'account default umask'
  requires 'no passwords via ssh'
end

dep 'sudo.bin'

dep 'admins can passwordless sudo' do 
  requires 'account groups'
  requires 'sudo.bin'
  met? { !'/etc/sudoers'.p.read.split("\n").grep(/^%admin.*NOPASSWD/).empty? }
  meet { '/etc/sudoers'.p.append("%admin  ALL=(ALL) NOPASSWD: ALL\n") }
end

dep 'account default umask' do
  logindefs = "/etc/login.defs"
  met? { !logindefs.p.read.split("\n").grep(/^UMASK 077/).empty? }
  meet {
    log "changing default umask to 077"
    system "sed -i 's/^UMASK.*/UMASK 077/g' #{logindefs}"
  }
end

dep 'account skeleton files are 600' do
  etcskel = "/etc/skel/"
  met? {
    # Select things that aren't 600'ed. Empty array means everything is 600
    Dir.entries(etcskel).select do |ent|
      next if ent == "." or ent == ".."
      "#{etcskel}#{ent}".p.stat.mode != 33152
    end.empty?
  }
  meet {
    Dir.foreach(etcskel) do |ent|
      next if ent == "." or ent == ".."
      log "setting #{etcskel}#{ent} to mode 600"
      system "chmod 0600 #{etcskel}#{ent}"
    end

  }
end

dep 'no passwords via ssh' do
  met? { !'/etc/ssh/sshd_config'.p.read.split("\n").grep(/^PasswordAuthentication.*no/).empty? }
  meet { '/etc/ssh/sshd_config'.p.append("PasswordAuthentication no\n") }
  after {
    system "/etc/init.d/ssh restart 2>&1"
  }
end
