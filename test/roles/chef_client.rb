name 'chef_client'
description 'Install the Chef client '
run_list( 
  'recipe[base]',
)
default_attributes(
  directory: {
    '/etc/chef': {}
  },
  file: {
    '/etc/yum.repos.d/site-local.repo': {
      content: '
        [site-local]
        baseurl=http://lxdev01.devops.test/repo
        enabled=1
        gpgcheck=0
      '
    },
    '/etc/systemd/system/chef-client.service': {
      content: '
        [Unit]
        Description=Chef Client daemon
        After=network.target auditd.service

        [Service]
        Type=oneshot
        ExecStart=/opt/chef/embedded/bin/ruby /usr/bin/chef-client -c /etc/chef/client.rb -L /var/log/chef-client.log
        ExecReload=/bin/kill -HUP $MAINPID
        SuccessExitStatus=3

        [Install]
        WantedBy=multi-user.target
      '
    },
    '/etc/systemd/system/chef-client.timer': {
      content: '
        [Unit]
        Description=Chef Client periodic execution

        [Install]
        WantedBy=timers.target

        [Timer]
        OnBootSec=1min
        OnUnitActiveSec=1800sec
        AccuracySec=300sec
      '
    }
  },
  ## Install the client software from a repository
  package: [ 'chef' ],
  systemd_unit: {
    'chef-client.timer': { action: [:enable,:start] }
  }
)
