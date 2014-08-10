# the source for this algorithm: 
# http://stackoverflow.com/questions/20416218/understanding-ibeacon-distancing
#
# ios function
# protected static double calculateAccuracy(int txPower, double rssi) {
#   if (rssi == 0) {
#     return -1.0; // if we cannot determine accuracy, return -1.
#   }

#   double ratio = rssi*1.0/txPower;
#   if (ratio < 1.0) {
#     return Math.pow(ratio,10);
#   }
#   else {
#     double accuracy =  (0.89976)*Math.pow(ratio,7.7095) + 0.111;    
#     return accuracy;
#   }
# }   

def calculate_distance(power, rssi, feet=nil)
	if rssi == 0 # if we cannot determine accuracy, return -1
		distance = -1
	else
		ratio = rssi * 1.0 / power		
		if ratio < 1
			distance = ratio ** 10
		else
			distance = (0.89976) * (ratio ** 7.7095) + 0.111
		end
	end
	units = 'meters'
	if feet
		units = 'feet'
		distance = distance * 3.28084
	end
	# puts "distance:#{distance.round(1)} #{units}, power:#{power}  rssi:#{rssi}"
	return distance
end
