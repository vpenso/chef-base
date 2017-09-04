name 'apt'
description 'APT configuration'
run_list( 'recipe[base]' )
default_attributes(
   file: {
     ##
     # APT configuration
     #
     '/etc/apt/apt.conf.d/50diff': {
       content: 'Acquire::PDiffs "false";'
     },
     '/etc/apt/apt.conf.d/90recommends': {
       content: 'APT::Install-Recommends 0;'
     },
   },
   apt_update: {
     new_repo: { action: [ :nothing ] }
   },
   ##
   # Additional Repositories
   #
   apt_repository: {
     debian_backports: {
       uri: 'http://ftp.debian.org/debian',
       distribution: 'stretch-backports',
       components: [ 'main' ],
       notifies: [ :update, 'apt_update[new_repo]']
     }
   }
)
