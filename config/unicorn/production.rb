worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
timeout 15
preload_app true

listen '/tmp/.supermarket.sock.0'

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  SegmentIO = Supermarket::SegmentIoAgent.new(Supermarket::Config)

  puts "=> SegmentIO is #{SegmentIO.enabled? ? 'enabled' : 'disabled'}"

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end
