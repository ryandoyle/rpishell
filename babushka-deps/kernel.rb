dep 'sysctl' do
  requires 'reboot on kernel panic'
end

dep 'reboot on kernel panic' do
  sysctl = "/etc/sysctl.conf"
  sysctl_reboot_line = "kernel.panic = 10"
  met? { !sysctl.p.read.split("\n").grep(/^#{sysctl_reboot_line}/).empty? }
  meet {
    log "writing #{sysctl_reboot_line} to #{sysctl}"
    sysctl.p.append("#{sysctl_reboot_line}\n") }
  after {
    log "reloading sysctl settings"
    sysctl_reload
  }
end

def sysctl_reload
  system "sysctl -p"
end
