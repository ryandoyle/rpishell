rpishell_www_root = "/var/www/rpishell"
dep 'rpishell www' do 
  requires 'lighttpd'
  requires 'rpishell assets are deployed'
end

dep 'rpishell assets are deployed' do
  # As the www site is packaged up with this repo, just link it off
  met? {
    rpishell_www_root.p.readlink == File.expand_path(dependency.load_path.parent + '../www')
  }
  meet {  
    log "creating symlink #{File.expand_path(dependency.load_path.parent + '../www')} to #{rpishell_www_root}"
    rpishell_www_root.p.delete if rpishell_www_root.p.symlink?
    File.symlink(File.expand_path(dependency.load_path.parent + '../www'), rpishell_www_root)
  }
end
