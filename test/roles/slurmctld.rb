name 'slurmctld'
description 'Slurm Cluster Controller deployment'
run_list( 'recipe[base]' )
default_attributes(
 
  ##
  # Groups
  #
  group: {
    slurm: {}
  },

  ##
  # USERS
  #
  user: {
    ##
    # User to operate the Slurm services
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
    '/var/lib/slurm/ctld': { owner: 'slurm', recursive: true },
    '/var/spool/slurm/ctld': { owner: 'slurm', recursive: true },
    '/var/run/slurm': { owner: 'slurm' },
    '/var/log/slurm': { owner: 'slurm' },
    ##
    # Create directories used for NFS export
    #
    '/etc/slurm': {},
    '/network': {},
    ##
    # User directories on shared storage
    #
    '/network/spock' => { owner: 'spock' },
    '/network/sulu' => { owner: 'sulu' },
    '/network/kirk' => { owner: 'kirk' },
    '/network/uhura' => { owner: 'uhura' }
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
     ##
     # NFS shares configuration
     #
     '/etc/exports' => { 
        content: "/etc/slurm lx*(ro,sync,no_subtree_check)\n/network lx*(rw)\n",
        notifies: [ :restart, 'systemd_unit[nfs-server.service]' ]
     },
     ##
     # Slurm shared secret
     #
     '/etc/munge/munge.key' => {
        content: '030340d651edb16efabf24a8c080d4b7',
        notifies: [ :restart, 'systemd_unit[munge.service]' ]
     }
  },

  ##
  # PACKAGES
  # 
  yum_package: [ 
    'nfs-utils', 
    'slurm',
    'slurm-slurmdbd',
    'slurm-munge'
  ],

  ##
  # SYSTEM SERVICES
  #
  systemd_unit: {
    'nfs-server.service': { action: [:enable,:start] },
    'munge.service': { action: [:enable,:start] },
    'slurmctld.service': { action: [:enable] },
    'slurmdbd.service': { action: [:enable]}
  }
)
