name 'ssh'
description 'SSH configuration for testing'
run_list( 
  'recipe[base]',
  'role[accounts]'
)
default_attributes(

  directory: {
    '/home/kirk/.ssh/': { mode: '0700' }  
  },

  file: {

    ##
    # Global SSH daemon configuration
    # 
    sshd_config: {
      path: '/etc/ssh/sshd_config',
      content: '
        HostKey /etc/ssh/ssh_host_rsa_key
        HostKey /etc/ssh/ssh_host_ecdsa_key
        HostKey /etc/ssh/ssh_host_ed25519_key
        SyslogFacility AUTHPRIV
        AuthorizedKeysFile .ssh/authorized_keys
        PasswordAuthentication yes
        ChallengeResponseAuthentication no
        GSSAPIAuthentication yes
        GSSAPICleanupCredentials no
        UsePAM yes
        X11Forwarding yes
        UsePrivilegeSeparation sandbox
        AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
        AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
        AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
        AcceptEnv XMODIFIERS
        Subsystem       sftp    /usr/libexec/openssh/sftp-server
      '
    },

    ##
    # SSH public keys for users
    #
    '/home/kirk/.ssh/authorized_keys': {
      content: '
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDzh1d1GvDtj6MgOD8okGW0RxQFqfC1UXPQ5eJ4I8+LO6T3gCZRyvIrz8IWLfttu0NLp7oODdQW7DqA9KB01wZweQnE9WAnpOFEphNq4SH0R1xoJt+Xbcmb/3XdwNc224TCfr5UYPkYFD3ThBBaA6xKxc/PPnTxB6EjYfilskWvKe8tzg9gVJRFezMtT9lOjUXx9kZZl8S8ORCzNKAG3Nw4NpJwuGOI+oBYU9yBknFsr1j/HJOcwPIsYqm3slcLDD+USUbxHd2mLo5JNLzmD9CTienMy6QDuRqoND5bcuJ4edduJFuiH65n+ciZAX429R36ezEjU+tyMkJ/N0D0DFGH
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDzh1d1GvDtj6MgOD8okGW0RxQFqfC1UXPQ5eJ4I8+LO6T3gCZRyvIrz8IWLfttu0NLp7oODdQW7DqA9KB01wZweQnE9WAnpOFEphNq4SH0R1xoJt+Xbcmb/3XdwNc224TCfr5UYPkYFD3ThBBaA6xKxc/PPnTxB6EjYfilskWvKe8tzg9gVJRFezMtT9lOjUXx9kZZl8S8ORCzNKAG3Nw4NpJwuGOI+oBYU9yBknFsr1j/HJOcwPIsYqm3slcLDD+USUbxHd2mLo5JNLzmD9CTienMy6QDuRqoND5bcuJ4edduJFuiH65n+ciZAX429R36ezEjU+tyMkJ/N0D0C21J
      '
    }

  }
)
