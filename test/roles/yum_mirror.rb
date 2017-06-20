name 'yum_mirror'
description 'Configure a Yum package mirror'
run_list( 'recipe[base]' )
default_attributes(
  package: [
    'yum-utils',
    'yum-cron',
    'createrepo',
    'httpd'
  ],
  directory: {
    '/var/www/html/centos/7/os/x86_64/': { recursive: true }
  },
  file: {
    ##
    # Disable SELinux
    #
    '/etc/selinux/config': {
      content: '
        SELINUX=disabled
        SELINUXTYPE=targeted 
      '
    },
    ##
    # Apply security updates automatically
    #
    '/etc/yum/yum-cron-hourly.conf': {
      content: '
        [commands]
        update_cmd = security
        update_messages = yes
        download_updates = yes
        apply_updates = yes
        random_sleep = 15

        [emitters]
        system_name = None
        emit_via = stdio
        output_width = 80

        [email]
        email_from = root
        email_to = root
        email_host = localhost
        [groups]

        group_list = None
        group_package_types = mandatory, default

        [base]
        debuglevel = -2
        mdpolicy = group:main
      '
    },
    ##
    # Sync local mirror of the base package repository
    #
    '/etc/systemd/system/reposync.service': {
      content: '
        [Unit]
        Description=Mirror package repository

        [Service]
        ExecStart=/usr/bin/reposync -gml --download-metadata -r base -p /var/www/html/centos/7/os/x86_64/
        ExecStartPost=/usr/bin/createrepo -v --update /var/www/html/centos/7/os/x86_64/base -g comps.xml
        Type=oneshot
      '
    },
    ##
    # Periodically trigger mirror sync
    #
    '/etc/systemd/system/reposync.timer': {
      content: '
        [Unit]
        Description=Periodically execute package mirror sync

        [Timer]
        OnStartupSec=300s
        OnUnitInactiveSec=2h

        [Install]
        WantedBy=multi-user.target
      '
    }
  },
  systemd_unit: {
    # Web-server used to host the local package mirror
    'httpd.service': { action: [:enable, :start] },
    # Disable the firewall in the internal network
    'firewalld.service': { action: [:stop, :disable] },
    # Autonomous package updates
    'yum-cron.service': { action: [:start, :enable] },
    # Service to sync the package mirror
    'reposync.timer':  { action: [:enable, :start] }
  }
)
