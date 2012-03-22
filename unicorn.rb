
# This has to match the ports in ../config/initializers/picky.rb
# Somehow, unicorn does not work right. Find out why later.
port = case ENV['PICKY_ENV']
       when 'development'
         '9292'
       when 'production'
         '9293'
       when 'staging'
         '9294'
       else
         '9295'
       end

listen            '0.0.0.0:' + port
pid               'tmp/pids/unicorn.pid'
preload_app       true
stderr_path       'log/unicorn.stderr.log'
stdout_path       'log/unicorn.stdout.log'
timeout           10
worker_processes  3

# TODO Decide if you want to use the Unicorn killing trick. (Good with large data sets)
#
# After forking, the GC is disabled, because we
# kill off the workers after x requests and fork
# new ones – so the GC doesn't run.
#
# after_fork do |_, _|
#   GC.disable
# end
