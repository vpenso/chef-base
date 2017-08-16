name 'slurmctld'
description 'Slurm Cluster Controller deployment'
run_list( 
  'recipe[base]',
  'role[slurm]'
)
default_attributes(
 

  ##
  # DIRECTORIES
  #
  directory: {
    ##
    # For the Slurm services
    #
    '/var/lib/slurm/ctld': { owner: 'slurm', recursive: true },
    '/var/spool/slurm/ctld': { owner: 'slurm', recursive: true },
    
    ##
    # User directories on shared storage
    #
    '/network/spock' => { owner: 'spock' },
    '/network/sulu' => { owner: 'sulu' },
    '/network/kirk' => { owner: 'kirk' },
    '/network/uhura' => { owner: 'uhura' }
  },

  ##
  # CONFIGURATION FILES
  #
  file: {
     ##
     # NFS shares configuration
     #
     '/etc/exports' => { 
        content: "/etc/slurm lx*(ro,sync,no_subtree_check)\n/network lx*(rw)\n",
        notifies: [ :restart, 'systemd_unit[nfs-server.service]' ]
     },
     ##
     # slurmctld firewall configuration
     #
     '/etc/firewalld/services/slurmctld.xml': {
       content: '
         <?xml version="1.0" encoding="utf-8"?>
	 <service>
	   <short>slurmctld</short>
	   <description>SLURM Workload Manager</description>
	   <port protocol="udp" port="6817"/>
	   <port protocol="tcp" port="6817"/>
	   <port protocol="udp" port="6818"/>
	   <port protocol="tcp" port="6818"/>
	   <port protocol="udp" port="7321"/>
	   <port protocol="tcp" port="7321"/>
	 </service>
       ',
       notifies: [ :run, 'execute[firewall-cmd-add-slurmctld]' ]
     }
  },

  ##
  # EXECUTE
  #
  execute: {
    'firewall-cmd-add-slurmctld': {
      command: '
        firewall-cmd --zone=public --add-service=slurmctld --permanent
        firewall-cmd --reload
      ',
      action: [ :nothing ],
      not_if: [ 'firewall-cmd --zone=public --query-service=slurmctld' ]
    }    
  },

  ##
  # PACKAGES
  # 
  yum_package: {
    'nfs-utils': {},
    'slurm-slurmdbd': {}
  },

  ##
  # SYSTEM SERVICES
  #
  systemd_unit: {
    'nfs-server.service': { action: [:enable,:start] },
    'slurmctld.service': { action: [:enable] },
    'slurmdbd.service': { action: [:enable]}
  }
)
