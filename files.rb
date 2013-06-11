#! /usr/bin/ruby

    #ROOT = 'post/'
    ROOT = ''
    PU = ROOT + 'vendor/plugins/'
    LIB = ROOT + 'lib/'
    DB = ROOT + 'db/'
    CONF = ROOT + 'config/'
    APP = ROOT + 'app/'
    TEST = ROOT + 'test/'
    SPEC = ROOT + 'spec/'
    CUCUMBER = ROOT + 'features/'

    verbose = true
    verbose = ARGV.size == 0
    verbose = false
    
    files = []

    pusher = lambda {|list, file| list.push file if File.file? file }

    if verbose
      #files += Dir[PU + '**/*.rb'].sort
      files += Dir[LIB + '**/*.rb'].sort

      #files.push CONF + 'database.yml'
    end

    files.push 'README.md'
    files.push 'Gemfile'

    files.push CONF + 'routes.rb'

    #files += Dir[DB + 'migrate/*.rb'].sort

    files.push DB + 'schema.rb'

    #files.push DB + 'database.yml'

    #files += Dir[APP + "assets/javascripts/*.{js.coffee}"].sort
    #files += Dir[APP + "assets/stylesheets/*css"].sort

    %w(models controllers helpers).each do |subdir|    
      files += Dir[APP + "#{subdir}/**/*.rb"].sort
    end

    pusher.call files, 'public/javascripts/application.js'
    files.push 'public/stylesheets/application.css'


    files += Dir[APP + "views/**/*.*"].grep(/[^~]$/).sort

    #files += Dir[APP + "html_views/**/*.*"].grep(/[^~]$/).sort

    files += Dir[SPEC + "**/*.rb"].grep(/[^~]$/).sort

    files += Dir[CUCUMBER + "**/*.feature"].grep(/[^~]$/).sort
    files += Dir[CUCUMBER + "**/*.rb"].grep(/[^~]$/).sort

    if verbose
      #files += Dir[TEST + "**/*.*"].sort

      #pusher.call files, 'public/stylesheets/scaffold.css'

      #files.push 'files.rb'

      #pusher.call files, 'x'
    end
    pusher.call files, 'x'

    sep = ' '
    sep = ARGV.shift || ' '
    sep = "\n" if sep == 'n'

    print files.join(sep) + sep

