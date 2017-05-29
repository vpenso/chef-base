name 'ntp'
description 'Base configuration for CentOS 7'
run_list( 'recipe[base]' )
default_attributes(
 
  ##
  # PACKAGES
  # 
  package: [ 'ntp','ntpdate' ],

  # Remove the default NTP service on CentOS
  yum_package: { chrony: { action: :remove } },

  ##
  # CONFIGURATION FILES
  #
  file: {
   
    ##
    # Time Synchronisation 
    #
    '/etc/ntp.conf': {
      content: %(
        server 0.pool.ntp.org
        server 1.pool.ntp.org
        server 2.pool.ntp.org
        server 3.pool.ntp.org
        driftfile /var/lib/ntp/ntp.drift
        statistics loopstats peerstats clockstats
        filegen loopstats file loopstats type day enable
        filegen peerstats file peerstats type day enable
        filegen clockstats file clockstats type day enable
        restrict -4 default kod notrap nomodify nopeer noquery
        restrict -6 default kod notrap nomodify nopeer noquery
        restrict 127.0.0.1
        restrict ::1
      ),
      notifies: [ :restart, 'systemd_unit[ntpd.service]', :delayed ]
    }
  },

  ##
  # SYSTEM SERVICES
  #
  systemd_unit: {

    ##
    # Set timezone at boot 
    #
    'set-timezone.service': {
      content: '
        [Unit]
        Description=Set the time zone to Europe/Berlin
        
        [Service]
        ExecStart=/usr/bin/timedatectl set-timezone Europe/Berlin
        RemainAfterExit=yes
        Type=oneshot
      ',
      action: [:create, :enable, :start]
    },

    # Disable /etc/init.d/ntp if present
    'ntp.service': { action: [:stop, :disable] },

    'ntpd.service': { 
      content: %(
        [Unit]
        Description=Network Time Service
        After=syslog.target ntpdate.service sntp.service

        [Service]
        Type=forking
        ExecStart=/usr/sbin/ntpd -u ntp:ntp -g
        PrivateTmp=true

        [Install]
        WantedBy=multi-user.target
      ),
      action: [:create, :enable, :start],
      notifies: [ :restart, 'systemd_unit[ntpd.service]']
    }
  }
)
