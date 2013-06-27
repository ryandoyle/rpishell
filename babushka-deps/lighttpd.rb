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
    make_sure_there_is_a_docroot
    log "restarting lighttpd..."
    shell "/etc/init.d/lighttpd restart"
  }
end

dep 'lighttpd is started' do
  requires 'lighttpd.bin'
  # Allows lighttpd to start even if the rpishell site isn't deployed
  before { make_sure_there_is_a_docroot }
  met? { shell "/etc/init.d/lighttpd status" }
  meet { shell "/etc/init.d/lighttpd start" }
end

def make_sure_there_is_a_docroot
  '/var/www/rpishell'.p.mkdir if !'/var/www/rpishell'.p.exist?
end
