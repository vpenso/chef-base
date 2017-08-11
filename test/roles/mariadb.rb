name 'mariadb'
description 'Install and configure MariaDB'
run_list( 
  'recipe[base]',
)
default_attributes(
  directory: {
    '/etc/my.cnf.d': {}
  },
  file: {
    # Use official MariaDB packages from the developers
    '/etc/yum.repos.d/mariadb.repo': {
      content: '
        [mariadb]
        name = mariadb
        baseurl = http://yum.mariadb.org/10.2/centos7-amd64
        gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
        gpgcheck=1
      '
    },
    # Basic MariaDB server configuration
    '/etc/my.cnf.d/server.cnf': {
      content: '
        [mysqld]
        bind-address=0.0.0.0
      ',
      notifies: [ :restart, 'systemd_unit[mariadb.service]' ]
    }
  },
  package: [ 'MariaDB-server','MariaDB-client' ],
  execute: {
    'firewall-cmd-add-service-mysql': {
      command: '
        firewall-cmd --zone=public --add-service=mysql --permanent
        firewall-cmd --reload
      ',
      not_if: [ 'firewall-cmd --zone=public --query-service=mysql' ] 
    }
  },
  systemd_unit: {
    'mariadb.service': { action: [:enable,:start] }
  }
)
