name 'yum_repo'
description 'Configure a local Yum package repository'
run_list( 
  'recipe[base]',
  'role[yum_mirror]'
)
default_attributes(
  directory: {
    '/var/www/html/repo': { recursive: true }
  },
  execute: {
    # Initialize once when repo is created
    'createrepo /var/www/html/repo': {
      creates: '/var/www/html/repo/repodata'
    },
    # Update after additional packages have been added
    'createrepo --update /var/www/html/repo': {
     action: :nothing
    }
  },
  # Download packages to the repository
  remote_file: {
    '/var/www/html/repo/chef-13.1.31-1.el7.x86_64.rpm': {
      source: 'https://packages.chef.io/files/stable/chef/13.1.31/el/7/chef-13.1.31-1.el7.x86_64.rpm',
      notifies: [:run, 'execute[createrepo --update /var/www/html/repo]', :delayed]
    }
  }
)
