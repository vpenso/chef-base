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
