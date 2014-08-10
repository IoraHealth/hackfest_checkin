# line:{ranged: [{ uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 58755, minor: 11058, rssi: -61, power: -74 },
#           { uuid: "A6F72630-C548-4B34-9011-B1538ACC07EB", major: 0, minor: 0, rssi: -41, power: -57 }]}
# line:{ranged: [{ uuid: "8492E75F-4FD6-469D-B132-043FE94921D8", major: 11970, minor: 14674, rssi: -72, power: -59 },
#           { uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 0, minor: 0, rssi: 0, power: -57 }]}
# ranged
# line:{exited: { uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 0, minor: 0, rssi: 0, power: -57 }}
# {ranged: []}
# {entered: { uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 58755, minor: 11058, rssi: -78, power: -74 }}"
# {ranged: [{ uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 58755, minor: 11058, rssi: -78, power: -74 }]}
# {ranged: [{ uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 58755, minor: 11058, rssi: -79, power: -74 }]}
# {ranged: [{ uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 58755, minor: 11058, rssi: 0, power: -74 }]}
# {ranged: [{ uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 58755, minor: 11058, rssi: -77, power: -74 }]}
# {ranged: [{ uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 58755, minor: 11058, rssi: 0, power: -74 }]}
# {ranged: [{ uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 58755, minor: 11058, rssi: 0, power: -74 }]}
# {ranged: [{ uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 58755, minor: 11058, rssi: 0, power: -74 }]}
# {ranged: [{ uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 58755, minor: 11058, rssi: 0, power: -74 }]}
# {exited: { uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 58755, minor: 11058, rssi: 0, power: -74 }}
# {ranged: [{ uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 0, minor: 0, rssi: -50, power: -57 },
#           { uuid: "8492E75F-4FD6-469D-B132-043FE94921D8", major: 11970, minor: 14674, rssi: -71, power: -59 }]}
# x = "{ranged: [{ uuid: \"B9407F30-F5F8-466E-AFF9-25556B57FE6D\", major: 0, minor: 0, rssi: -50, power: -57 },\n" + "{ uuid: \"8492E75F-4FD6-469D-B132-043FE94921D8\", major: 11970, minor: 14674, rssi: -71, power: -59 }]}"

require 'pty'
require_relative 'calculate_distance'

BEACON_CMD = "ibeacon -s" # this OSX command line utility must be installed in the user's path
SPEAK = ENV['SPEAK'] # run like this if you want the program to speak: SPEAK=true ruby checkin.rb

class Beacon 
  attr_reader :name, :location, :uuid, :major, :minor, :power
  attr_accessor :rssi, :distance, :units

  def initialize(name, location, uuid, major, minor, power)
    @name = name
    @location = location
    @uuid = uuid
    @major = major
    @minor = minor
    @power = power
  end
end

IBEACONS = {}

# configure the practice beacons, put them in a Hash
name = "Purple iBeacon"
location = "Exam Room 1"
uuid = "B9407F30-F5F8-466E-AFF9-25556B57FE6D"
major = 58755
minor = 11058
power = -74
IBEACONS["#{uuid}:#{major}:#{minor}"] = Beacon.new(name, location, uuid, major, minor, power)

name = "James iPhone"
location = "Consult Room 3"
uuid = "52414449-5553-4E45-5457-4F524B53434F"
major = 0
minor = 0
power = -57
IBEACONS["#{uuid}:#{major}:#{minor}"] = Beacon.new(name, location, uuid, major, minor, power)

IBEACONS["closest"] = Beacon.new("starter","","","","","")
IBEACONS["closest"].distance = 9999

def process_line line
  # puts "line:#{line}" 
  eval_line = eval line

  if eval_line[:ranged]
    # puts "ranged" 
    eval_line[:ranged].each do |line|
      if line[:rssi] < 0 
        uuid = line[:uuid]
        beacon = IBEACONS["#{line[:uuid]}:#{line[:major]}:#{line[:minor]}"]
        if beacon
          beacon.rssi = line[:rssi]
          beacon.distance = calculate_distance(line[:power], line[:rssi], true) 
          puts "i see #{beacon.name} in #{beacon.location}, distance is about #{beacon.distance.round(1)} feet away"
          if beacon.distance < IBEACONS["closest"].distance
            IBEACONS["closest"] = beacon
            putsay "you are now closer to #{beacon.name} in #{beacon.location}, distance is about #{beacon.distance.round(1)} feet away"
          end
        end
      end
    end
  elsif eval_line[:entered]
    puts "entered uuid:#{eval_line[:entered][:uuid]}"
  elsif eval_line[:exited]
    puts "exited uuid:#{eval_line[:exited][:uuid]}"
  else
    puts "ERROR: unknown state:#{line}"
  end
end

def putsay(text)
  puts text
  `say #{text}` if SPEAK
end


# here's the main processing loop. 
# launch ibeacon cli and process each returned line
# we must join lines that end in a , because we can't process a non-complete line
begin
  user = ENV['LOGNAME']
  greeting = "Hello #{user} Welcome to the Hackfest!"
  putsay greeting

  PTY.spawn( BEACON_CMD ) do |stdin, stdout, pid|
    begin
      lines = ''
      stdin.each { |line|
        lines += line 
        last_char = lines.chomp[-1,1] # chomp removes the newline
        if last_char != ','
          process_line lines
          lines = ''
        end
      }
    rescue Errno::EIO
      puts "Errno:EIO error, but this probably just means " +
            "that the process has finished giving output"
    end
  end
rescue PTY::ChildExited
  puts "The child process exited!"
end


# Enter room
# speak!
# push to api
# get config depending on location
# patient app!
