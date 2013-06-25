# Note: first group listed in the :groups array will be the users primary group
users = {
  'ryan' => {
    :enabled => true,
    :groups => ['users', 'admin'],
    :comment => "Ryan",
    :ssh_key => "dddadsfoobarrr"
  },
  'babgen1' => {
    :enabled => true,
    :groups => ['users'],
    :comment => "Babushka did this",
    :ssh_key => "ffoobarrr"
  },
}


dep "account users" do
  users.each_key do |name|
    requires "account #{name} exists"
    requires "account #{name} groups"
    requires "account #{name} ssh authorized_keys"
    requires "account #{name} homedir permissions"
    requires "account #{name} status"
    requires "account #{name} comment"
    requires "account #{name} .mail directory"
    requires "account #{name} .muttrc config"
  end
end

# Here we define all deps that need to be setup for users
users.each do |name,attr|

  home_dir = "/home/#{name}"
  ssh_dir = "#{home_dir}/.ssh"
  shell = "/bin/bash"

  dep "account #{name} exists" do 
    requires 'account groups'
    requires 'account skeleton files are 600'

    met? { '/etc/passwd'.p.grep(/^#{name}\:/) }
    meet { 
      log "adding user #{name}"
      shell "useradd -G #{attr[:groups].join(',')} -m -N -c '#{attr[:comment]}' --shell #{shell} #{name}" 
    }
  end

  dep "account #{name} homedir permissions" do 
    requires "account #{name} exists"
    secure_mode = "0701"
    met? { home_dir.p.stat.mode == 16833 } # 0701
    meet {
      log "setting #{home_dir} to mode #{secure_mode}"
      shell "chmod #{secure_mode} #{home_dir}"
    }
  end

  # Users' groups
  dep "account #{name} groups" do
    requires "account #{name} exists"
    met? { 
      attr[:groups].sort == get_user_groups(name).sort
    }
    meet { 
      # add groups
      (attr[:groups] - get_user_groups(name)).each do |add|
        log "adding #{name} to #{add}"
        shell "gpasswd -a #{name} #{add}"
      end 
      # remove groups
      (get_user_groups(name) - attr[:groups]).each do |remove|
        log "removing #{name} from #{remove}"
        shell "gpasswd -d #{name} #{remove}"
      end
    }
  end

  dep "account #{name} comment" do
    require 'etc'
    requires "account #{name} exists"
    met? { Etc.getpwnam(name).gecos == attr[:comment] }
    meet {
      log "user comment changed from '#{Etc.getpwnam(name).gecos}' to '#{attr[:comment]}'"
      system "usermod --comment '#{attr[:comment]}' #{name}"
    }
  end

  dep "account #{name} status" do
    requires "account #{name} ssh authorized_keys"

    met? { 
      if attr[:enabled] 
        "#{ssh_dir}/authorized_keys".p.owner == name 
      else
        "#{ssh_dir}/authorized_keys".p.owner == 'root'
      end
    }
    meet { 
      if attr[:enabled]
        log "enabling user #{name}"
        system "chown #{name} #{ssh_dir}/authorized_keys"
     else
        log "disabling user #{name}"
        system "chown root #{ssh_dir}/authorized_keys"
     end
    }
  end

  # SSH key(s) - only test if the file is there. Allow users to bootstrap their account with a 
  # disposable keypair and replace their keys after they have logged in for the first time. 
  dep "account #{name} ssh authorized_keys" do
    requires "account #{name} .ssh directory"
    met? { "#{ssh_dir}/authorized_keys".p.exist? }
    meet { 
      log "#{name}'s authorized key deployed as: #{attr[:ssh_key]}"
      "#{ssh_dir}/authorized_keys".p.append("#{attr[:ssh_key]}\n") 
    }
    after {
      shell "chmod 0600 #{ssh_dir}/authorized_keys"
      shell "chown #{name} #{ssh_dir}/authorized_keys"
    }
    
  end

  dep "account #{name} .ssh directory" do
    requires_when_unmet "account #{name} exists"
    met? { ssh_dir.p.exist? }
    meet { 
      log "creating directory #{ssh_dir}"
      ssh_dir.p.mkdir 
    }
    after { 
      shell "chown #{name} #{ssh_dir}"
      shell "chmod 0700 #{ssh_dir}"
    }
  end
  # Mail dir
  dep "account #{name} .mail directory" do
    requires_when_unmet "account #{name} exists"
    met? { "#{home_dir}/.mail".p.exist? }
    meet {
      log "creating #{home_dir}/.mail"
      "#{home_dir}/.mail".p.mkdir
    }
    after { 
      shell "chown #{name} #{home_dir}/.mail"
      shell "chmod 0700 #{home_dir}/.mail"
    }
  end
  # Muttrc - create a default but don't enforce it
  dep "account #{name} .muttrc config" do
    requires_when_unmet "account #{name} exists"
    met? { "#{home_dir}/.muttrc".p.exist? }
    meet {
      log "creating default .muttrc config"
      "#{home_dir}/.muttrc".p.write("
set folder = '~/.mail'
set from = '#{name}@rpishell.org'
set mbox_type=Maildir
set folder='~/.mail'
set mask='!^\\.[^.]'
set mbox='~/.mail'
set record='+.Sent'
set postponed='+.Drafts'
set spoolfile='~/.mail'
")
    }
    after { shell "chown #{name} #{home_dir}/.muttrc" }
  end
  
end

def get_user_groups(user)
  `id #{user} | egrep -o groups=.*`.scan(/\(([a-z]+)\)/).flatten
end

#  meet { "#{ssh_dir}/authorized_keys".p.write(attr[:ssh_key]) }
def file_contents_are_the_same(string,file)
  require "digest"
  Digest::SHA1.hexdigest(string) == Digest::SHA1.hexdigest(File.read(file))
end
