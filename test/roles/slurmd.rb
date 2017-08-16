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
    'slurmd.service': { action: [:enable] },
  }
)
