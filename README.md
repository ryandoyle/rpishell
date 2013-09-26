Free shell accounts hosted on an RPi @ [rpishell.org](http://rpishell.org)
---
# What's a shell account #
It's a user account on a remote server. They usually have:
- ssh access
- email
- web hosting
- compilers
- a bunch of command line tools (irc/web/ftp clients)

# Whats this? #
An [awesome company](http://raspberrycolocation.com/) has started offering free Raspberry Pi co-location. Without even thinking what I would do with free RPi hosting, another RPi was being shipped, ready to configure and send off to [Amsterdam](https://www.pcextreme.nl/en/contact/).

As much as RPi hosting is an [experiment](http://raspberrycolocation.com/why/), this project is too, an experiment. I've registered rpishell.org and have free shell accounts to give out.

# How do I get one? #
Good question - using `git` of course! Your account is part of the configuration management codebase of rpishell.org. I've used [babushka](http://babushka.me/) to configure all aspects of the RPi (but you don't need to know too much about it to get an account).

### The 4 easy steps ###
- Fork this repo!
- Edit `babushka-deps/account_users.rb` and append your account details to the `users` hash. EG:
~~~
         :comment => "First Last",
         :ssh_key => "ssh-rsa AAAAAbasdjhBJhdbjhabsjdhbHSDBAJSDBHffoobarrr"
       },
    +  'accountyname' => {
    +    :enabled => true,
    +    :groups => ['users'],
    +    :comment => "Mr Shell Account",
    +    :ssh_key => "ssh-rsa AAAAAbasdjhBJhdbjhabsjdhbHSDBAJ..."
    +  },
     }
~~~
- Commit and issue a pull request
- If I have capacity (I have no idea how many users the RPi can support), I'll merge it.


_But I don't really want my public SSH key available for the world to see_. 

And that's fair enough. What I suggest (and what I have done) is to create a throwaway/bootstrap keypair to get your initial login. After you login, remove this key and add your own to the `.ssh/authorized_keys` file. Babushka only makes sure that the file is present, not what it contains.

# I want something (installed|configured|improved) #
*Great!*  You'll need to know a _small_ amount of Ruby and a _tiny_ amount of Babushka. If you know nothing about either, I'm sure you can still figure it out. Also, keep in mind that this runs Raspbian (basically Debian). That might be important for package names or configuration file locations.

As en example, lets go over installing elinks:

Open up `babushka-deps/user_packages.rb`. Packages that you want installed should be defined here.

Add the dpkg name name of the package in the hash, in our case, `elinks`.
~~~
         'mutt'     => nil,
         'mtr-tiny' => {:provides => 'mtr'},
    +    'elinks'   => {:provides => 'links'},
       }
~~~
Note the `provides` statement there? If the package name _isn't_ the _same name_ as the binary that is being installed, you will need to tell Babushka what it provides (it's how it knows that it's installed).

**It's collaborative sysadmin :)**

_A heads up: Due to the hardware constraints of the RPi I'm unlikely to merge commits for applications that are memory hungry. Think java/modphp/rails/X11._

# Housekeeping #
#### Actions/Content ####
- Use common sense
- Don't host anything illegal
- Don't nmap/DoS the Internet
- You get the idea

#### Memory/Processes ####
The RPi is very constrained hardware-wise. If you launch something that "eats all the megabytes", I'm sure you'd be the first one taken care of by the kernel OOM killer but it would be nice for that not to run too much (especially if it decides `sshd` should die). I have some swap configured, but it is on an SD card... There are 

#### Storage ####
The rpishell.org server has a 16GB SD card. It's not a lot. Don't store too much in your home directory please. There are no quotas enabled at the moment but that might have to change.

#### Access ####
At any stage this RPi could disappear from either the hosting disappearing or myself not willing to maintain it. Don't keep _anything_ valuable on it whatsoever. Nothing is backed up :)
