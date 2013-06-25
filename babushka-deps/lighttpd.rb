dep 'lighttpd' do
  requires 'lighttpd.bin'
  requires 'lighttpd.conf is configured'
  requires 'lighttpd is started'
end

dep 'lighttpd.bin'

dep 'lighttpd.conf is configured' do
  requires 'lighttpd.bin'
  met? { Babushka::Renderable.new('/etc/lighttpd/lighttpd.conf').from?(dependency.load_path.parent / "erb/lighttpd.conf.erb") }
  meet { render_erb "erb/lighttpd.conf.erb", :to => '/etc/lighttpd/lighttpd.conf' }
  after {
    log "restarting lighttpd..."
    shell "/etc/init.d/lighttpd restart"
  }
end

dep 'lighttpd is started' do
  requires 'lighttpd.bin'
  met? { shell "/etc/init.d/lighttpd status" }
  meet { shell "/etc/init.d/lighttpd start" }
end
