x = "{ranged: [{ uuid: \"B9407F30-F5F8-466E-AFF9-25556B57FE6D\", major: 0, minor: 0, rssi: -50, power: -57 },\n" + "{ uuid: \"8492E75F-4FD6-469D-B132-043FE94921D8\", major: 11970, minor: 14674, rssi: -71, power: -59 }]}"
y = eval x
y[:ranged].each do |z|
  puts z
  uuid = z[:uuid]
  puts "uuid:#{uuid}"
end
