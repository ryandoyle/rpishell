# Packages that users want installed
user_packages = {
    'curl'     => nil,
    'irssi'    => nil,
    'mutt'     => nil,
    'dnsutils' => {:provides => 'dig'},
    'mtr-tiny' => {:provides => 'mtr'},
    'elinks'   => nil,
    'vim-nox'  => {:provides => 'vim'},
    'htop'     => nil,
    'tmux'     => nil,
    'screen'   => nil,
    'mosh'     => nil,
}

# Dynamically create the deps
user_packages.each do |package,args| 
  dep "#{package}.bin" do
    provides args[:provides] if defined? args[:provides]
  end
end

# Tie them all into 1 dep
dep 'account packages' do
  user_packages.each_key do |package|
    requires "#{package}.bin"
  end
end
