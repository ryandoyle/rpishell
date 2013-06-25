postfix_maincf = '/etc/postfix/main.cf'

dep 'mail' do
  requires 'postfix config'
  requires 'etc mailname is my hostname' 
end

dep 'postfix config' do
  requires 'postfix.bin'
  requires 'postfix main.cf'
  requires 'postfix main.cf permissions'
end

dep 'postfix main.cf' do
  @my_hostname = 'rpishell.org'
  requires 'postfix.bin'
  met? { Babushka::Renderable.new(postfix_maincf).from?(dependency.load_path.parent / "erb/main.cf.erb") }
  meet { render_erb "erb/main.cf.erb", :to => postfix_maincf }
  after {
    log "restarting postfix"
    restart_postfix
  }
end

dep 'postfix main.cf permissions' do
  requires 'postfix.bin'
  wrr_mode = "0644"
  met? { postfix_maincf.p.stat.mode == 33188 } # 0644
  meet {
    log  "changing mode of #{postfix_maincf} to #{wrr_mode}"
    system "chmod #{wrr_mode} #{postfix_maincf}"
  }
end

dep 'postfix running' do
  requires 'postfix.bin'
  met? { system '/etc/init.d/postfix status' }
  meet { 
    log 'starting postfix...'
    system '/etc/init.d/postfix start' 
  }
end

dep 'postfix.bin' do
  requires 'sendmail is uninstalled' 
end

dep 'sendmail is uninstalled' do
  before {
    log "stopping sendmail..."
    system '/etc/init.d/sendmail stop' if File.exist? '/etc/init.d/sendmail'
  }
  met? { !File.exist? '/etc/init.d/sendmail' }
  meet {
    log "removing sendmail..."
    system "apt-get -y remove sendmail-base sendmail-bin sendmail-cf sendmail-doc" 
  }
end

dep 'etc mailname is my hostname' do
  mailname = '/etc/mailname'
  met? { !mailname.p.read.grep(/#{@my_hostname}/).empty? }
  meet { mailname.p.write("#{@my_hostname}\n") }
end

def restart_postfix
  system "/etc/init.d/postfix restart"
end
