name 'accounts'
description 'Accounts configuration for testing'
run_list( 'recipe[base]' )
default_attributes(
  package: [ 'zsh' ],
  group: { trek: {}    },
  user: {
    root: {
      password: '$1$ZrL37lDG$VNCKeJf8WiZwLIxQobbA3/',
      action: :modify
    },
    kirk: {
      uid: 1234,
      gid: 'trek',
      password: '$1$Bx2pz1Qq$s2LjQOtw9/5KgaodbtUA10',
      shell: '/bin/zsh',
      manage_home: true
    },
    spock: { system: true },
    sulu: { action: :remove }
  }
)
