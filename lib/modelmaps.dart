

class Locationes {
  String? locationes;

  Locationes({
    String? location,
  }) : locationes = location;

//{"pk":2,"username":"","email":"example1@gmail.com","first_name":"First","last_name":"Last"}
factory Locationes.fromJson(dynamic json) {
  print(json);

  if (json is List<dynamic>) {
    if (json.isNotEmpty) {
      Map<String, dynamic> firstItem = json.first as Map<String, dynamic>;
      String location = firstItem['location'] as String;
      return Locationes(location: location);
    } else {
      return Locationes(location: null);
    }
  } else if (json is Map<String, dynamic>) {
    String location = json['location'] as String;
    return Locationes(location: location);
  }

  throw FormatException('Invalid JSON format');
}


  split(String s) {}
}

class LocationeDevice {
  List<String>? locations;

  LocationeDevice({
    this.locations,
  });

  factory LocationeDevice.fromJson(dynamic json) {
    if (json is List && json.isNotEmpty) {
      List<String> locations = json.map((item) {
        Map<String, dynamic> device = item as Map<String, dynamic>;
        return device['location'] as String;
      }).toList();
      
      return LocationeDevice(
        locations: locations,
      );
    } else {
      return LocationeDevice(locations: []);
    }
  }
}


