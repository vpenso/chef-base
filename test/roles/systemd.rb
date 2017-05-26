name "systemd"
description "Systemd configuration for testing"
run_list( "recipe[base]" )
default_attributes(
  package: [
    'systemd-networkd',
    'systemd-resolved'
  ],
  directory: {
    '/etc/systemd/network': { recursive: true },
    '/etc/systemd/journald.conf.d': { recursive: true }
  },
  file: {
    '/etc/systemd/network/50-dhcp.network': {
      content: '
        [Match]
        Name=eth0
        
        [Network]
        DHCP=yes
      '
    },
    '/etc/systemd/resolved.conf': {
      content: '
        [Resolve]
        DNS=208.67.222.222 208.67.220.220
        FallbackDNS=8.8.8.8 8.8.4.4
        Domains=devops.test
        Cache=yes
      '
    },
    '/etc/systemd/journald.conf.d/journal-storage.conf': {
      content: '
        [Journal]
        Storage=persistent
      '
    }
  },
  systemd_unit: {
    'systemd-networkd.service': { action: [:enable,:start] },
    'systemd-resolved.service': { action: [:enable,:start] },
    'systemd-logind.service': { action: :enable },
    'systemd-journald.service': { action: [:enable,:start] },
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
    }
  }
)
