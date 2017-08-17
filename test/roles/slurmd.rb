name 'slurmd'
description 'SLURM execution node'
run_list( 
  'recipe[base]',
  'role[slurm]'
)
default_attributes(
  ##
  # DIRECTORIES
  #
  directory: {
    ##
    # For the Slurm services
    #
    '/var/spool/slurm/d': { owner: 'slurm', recursive: true },
  },
  ##
  # SYSTEM SERVICES
  #
  systemd_unit: {
    ##
    # SLURM service
    #
    'slurmd.service': { action: [:enable] },
    ##
    # Mount the SLURM configuration
    #
    'etc-slurm.mount': {
      content: '
        [Unit]
        Description=Mount SLURM configuration
        Wants=network-online.target
        After=network-online.target

        [Mount]
        What=lxrm01.devops.test:/etc/slurm
        Where=/etc/slurm
        Type=nfs
        Options=ro,nosuid
        TimeoutSec=10s

        [Install]
        WantedBy=multi-user.target
      ',
      action: [:create, :enable, :start]
    },
    ##
    # Mount the shared network storage
    #
    'network.mount': {
      content: '
        [Unit]
        Description=Mount network storage
        Wants=network-online.target
        After=network-online.target

        [Mount]
        What=lxrm01.devops.test:/network
        Where=/network
        Type=nfs
        Options=rw,nosuid
        TimeoutSec=10s

        [Install]
        WantedBy=multi-user.target
      ',
      action: [:create, :enable, :start]
    }
  }
)
