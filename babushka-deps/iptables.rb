iptables_file = '/etc/iptables.up.rules'
onboot_file = '/etc/network/if-pre-up.d/iptables'
onboot_line = "#!/bin/bash\n/sbin/iptables-restore < #{iptables_file}\n"

dep 'iptables' do
  requires 'iptables rules file is deployed'
  requires 'iptables runs on boot'
end

dep 'iptables rules file is deployed' do
  met? { Babushka::Renderable.new(iptables_file).from?(dependency.load_path.parent / "erb/iptables.up.rules.erb") }
  meet { render_erb "erb/iptables.up.rules.erb", :to => iptables_file }
  after {
    log "reloading iptables rules"
    system "/sbin/iptables-restore < #{iptables_file}"
  }
end

dep 'iptables runs on boot' do
  met? { onboot_file.p.read == onboot_line }
  meet { onboot_file.p.write onboot_line }
  after { shell "chmod 755 #{onboot_file}" }
end
