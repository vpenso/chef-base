name 'yum_epel'
description 'EPEL Yum package repository'
run_list( 
  'recipe[base]',
)
default_attributes(
  execute: {
    # Enable the Fedora EPEL package repository
    'epel-release': {
      command: 'yum -y install epel-release',
      creates: '/etc/yum.repos.d/epel.repo'
    }
  },
  package: {
    'singularity': {
      # Make sure EPEL is available before installing packages from it
      notifies: [ :run, 'execute[epel-release]', :before ]
    }
  }
)
