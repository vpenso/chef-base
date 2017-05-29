name 'template'
description 'Template configuration for testing'
run_list( 'recipe[base]' )
default_attributes(
  
  directory: {
    '/var/cache/chef': { recursive: true }
  },

  file: {
    # Write a template file
    #
    '/var/cache/chef/template.erb': {
      content: '
        This is some text <%= @one %> <%= @two %>
      ',
      banner: false
    }
  },

  # Render an ERB template from a local file
  template: {
    '/tmp/template.txt': {
      local: true,
      source: '/var/cache/chef/template.erb',
      variables: { 
        one: 'hello',
        two: 'world'
      }
    }
  }
)
