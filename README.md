## Description

This cookbook enables to configuration of generic [Chef resources](https://docs.chef.io/resources.html) by attributes.

The following resource list include by default mapped resources: 

```
apt_repository
apt_update
apt_package
yum_repository
yum_package
package
group
user
directory
file
remote_file
link
template
git
subversion
execute
bash
script
service
systemd_unit
route
mount
```

### Configuration

Append more resources to the resource list mapped by this cookbook with the attribute `base/resources`:

```ruby
name 'cron'
description 'Cron configuration'
run_list( 'recipe[base]' )
default_attributes(

  base: { resources: [ 'cron' ] },

  cron: {
    'noop': {
      hour: '5',
      minute: '0',
      command: '/bin/true'
    }
  }

)
```

### Usage

Take a look to [test/roles/](test/roles) directory for a list of example roles using this cookbook.

```ruby
name 'ntpd'
description 'NTPD configuration'
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

```

## License

Author:: Victor Penso

Copyright:: 2017

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
