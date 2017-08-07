name 'yum_epel'
description 'EPEL Yum package repository'
run_list( 
  'recipe[base]',
)
default_attributes(
  execute: {
    # Initialize once when repo is created
    'epel-release': {
      command: 'yum -y install epel-release',
      creates: '/etc/yum.repos.d/epel.repo'
    }
  },
  package: {
    'singularity': {
      notifies: [ :run, 'execute[epel-release]', :before ]
    }
  }
)
