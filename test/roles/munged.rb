name 'munged'
description 'MUNGE authentication service'
run_list( 'recipe[base]' )
default_attributes(

  ##
  # CONFIGURATION FILES
  #
  file: {
     ##
     # Shared secret
     #
     '/etc/munge/munge.key' => {
        content: '030340d651edb16efabf24a8c080d4b7',
        action: [ :nothing ],
        notifies: [ :restart, 'systemd_unit[munge.service]' ]
     }
  },

  ##
  # PACKAGES
  # 
  yum_package: {
    'munge': { notifies: [ :create, 'file[/etc/munge/munge.key]' ] },
  },

  ##
  # SYSTEM SERVICES
  #
  systemd_unit: {
    'munge.service': { action: [:enable,:start] }
  }
)
