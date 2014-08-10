require 'pty'
cmd = "/Users/james.mcelhiney/dev/ibeacon -s" 
begin
  PTY.spawn( cmd ) do |stdin, stdout, pid|
    begin
      # Do stuff with the output here. Just printing to show it works
      stdin.each { |line| print line }
    rescue Errno::EIO
      puts "Errno:EIO error, but this probably just means " +
            "that the process has finished giving output"
    end
  end
rescue PTY::ChildExited
  puts "The child process exited!"
end

