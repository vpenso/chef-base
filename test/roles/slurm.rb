name 'slurm'
description 'SLURM Generic Configuration'
run_list( 
  'recipe[base]',
  'role[munged]'
)
default_attributes(
 
  ##
  # Groups
  #
  group: {
    ##
    # Group to operate SLURM services
    #
    slurm: {}
  },

  ##
  # USERS
  #
  user: {
    ##
    # User to operate the SLURM services
    #
    slurm: {
      home: '/var/lib/slurm',
      group: 'slurm',
      shell: '/bin/bash',
      comment: 'SLURM workload manager'
    },
    ##
    # Slurm cluster users
    #
    spock: { 
      uid: 1111,
      home: '/network/spock',
      shell: '/bin/bash'
    },
    sulu: { 
      uid: 1112,
      home: '/network/sulu',
      shell: '/bin/bash'
    },
    kirk: { 
      uid: 1113,
      home: '/network/kirk',
      shell: '/bin/bash'
    },
    uhura: { 
      uid: 1114,
      home: '/network/uhura',
      shell: '/bin/bash'
    }
  },

  ##
  # DIRECTORIES
  #
  directory: {
    ##
    # For the Slurm services
    #
    '/var/log/slurm': { owner: 'slurm' },
    ##
    # Create directories used for NFS export
    #
    '/etc/slurm': {},
    '/network': {}
  },

  ##
  # CONFIGURATION FILES
  #
  file: {
     ##
     # Site specific package repository
     #
     '/etc/yum.repos.d/site-local.repo': {
       content: '
         [site-local]
         name=site-local
         baseurl=http://lxrepo01.devops.test/repo
         enabled=1
         gpgcheck=0
       '
     },
  },

  ##
  # PACKAGES
  # 
  yum_package: {
    'slurm': {},
    'slurm-munge': {}
  }

)
