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

     '/etc/apt/preferences.d/unstable': {
       content: %(
         Pin: release o=Debian,a=unstable
         Pin-Priority: 400
       )
     },
   
   },

   apt_repository: {
   
     backports: {
       uri: 'http://ftp.debian.org/debian',
       distribution: 'jessie-backports',
       components: [ 'main' ]
     },

     unstable: {
       uri: 'http://ftp.de.debian.org/debian',
       distribution: 'unstable',
       components: [ 'main' ]
     }
   
   }
)
