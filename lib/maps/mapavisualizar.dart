import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pianta/api_maps.dart';
import 'package:pianta/modelmaps.dart';
import '../Funciones/constantes.dart';
import '../constants.dart';

const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiZGFuaWVsc2cxOCIsImEiOiJjbGZ1N3F6ZWcwNDByM2Vtamo1OTNoc3hrIn0.5dFY3xEDB7oLtMbCWDdW9A';

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

  List<LatLng> getLatLngList() {
    return locations?.map((location) {
          List<String> coordinates = location.split(',');
          double latitude = double.parse(coordinates[0]);
          double longitude = double.parse(coordinates[1]);
          return LatLng(latitude, longitude);
        }).toList() ??
        [];
  }
}

class LocationeSensor {
  List<LocationSensor> sensors;

  LocationeSensor({
    required this.sensors,
  });

  factory LocationeSensor.fromJson(dynamic json) {
    List<LocationSensor> sensors = [];

    if (json is List && json.isNotEmpty) {
      sensors = json.map((item) => LocationSensor.fromJson(item)).toList();
    }

    return LocationeSensor(sensors: sensors);
  }

  List<LatLng?> getLatLngList() {
    return sensors.map((sensor) => sensor.location).toList();
  }
}

class LocationSensor {
  LatLng location;
  Color color;

  LocationSensor({
    required this.location,
    required this.color,
  });

  factory LocationSensor.fromJson(dynamic json) {
    String locationStr = json['location'] as String;
    List<String> coordinates = locationStr.split(',');
    double latitude = double.parse(coordinates[0]);
    double longitude = double.parse(coordinates[1]);
    LatLng location = LatLng(latitude, longitude);

    Color color = _parseColor(json['color']);

    return LocationSensor(
      location: location,
      color: color,
    );
  }

  static Color _parseColor(String colorStr) {
    // Implementa la lógica para convertir el valor de colorStr en un objeto Color
    // Puedes utilizar el constructor Color() o utilizar algún otro método
    // dependiendo del formato en el que recibas el color desde la API.
    // Por ejemplo:
    // return Color(int.parse(colorStr, radix: 16));

    // Aquí, se devuelve un color blanco por defecto si no se puede parsear el colorStr.
    return Colors.white;
  }
}

class ViewLocalization extends StatefulWidget {
  final int id;

  const ViewLocalization({Key? key, required this.id}) : super(key: key);

  @override
  _ViewLocalizationState createState() => _ViewLocalizationState();
}

class _ViewLocalizationState extends State<ViewLocalization> {
  Future<LocationeDevice?> getDeviceLocationes(String token) async {
    var url =
        Uri.parse("http://127.0.0.1:8000/user/project/${widget.id}/devices/");
    var res = await http.get(url, headers: {
      'Authorization': 'Token $token',
    });
    if (res.statusCode == 200) {
      var json = jsonDecode(res.body);
      LocationeDevice location = LocationeDevice.fromJson(json);
      return location;
    } else {
      return null;
    }
  }

  Future<String?> getProjectLocation(String token) async {
    final Locationes? location = await getLocationes(token);
    return location?.locationes;
  }

  Future<Locationes?> getLocationes(String token) async {
    var url = Uri.parse(
        "http://127.0.0.1:8000/user/project/${widget.id}/"); // Actualiza la URL a la ruta correspondiente para obtener la ubicación del proyecto
    var res = await http.get(url, headers: {
      'Authorization': 'Token $token',
    });
    if (res.statusCode == 200) {
      var json = jsonDecode(res.body);
      Locationes location = Locationes.fromJson(json);
      return location;
    } else {
      return null;
    }
  }

  Future<void> _DeviceLocation() async {
    try {
      var box = await Hive.openBox(tokenBox);
      final token = box.get("token") as String?;
      final fetchedLocation = await getDeviceLocationes(token!);
      setState(() {
        deviceLocation = fetchedLocation;
      });

      print('Locations: ${deviceLocation?.locations}');

      if (deviceLocation?.locations != null &&
          deviceLocation!.locations!.isNotEmpty) {
        DeviceArray = deviceLocation!.getLatLngList();

        if (DeviceArray.isNotEmpty) {
          DeviceArray.add(DeviceArray.first);
          LatLng defaultCenter = DeviceArray.first;
          LatLng center =
              DeviceArray.isNotEmpty ? DeviceArray.first : defaultCenter;
          mapController.move(center, 10.0);
        } else {
          LatLng defaultCenter = LatLng(0.0, 0.0);
          mapController.move(defaultCenter, 10.0);
          print('Location array is empty.');
        }
      } else {
        print('No locations available.');
      }
    } catch (e) {
      print('Failed to load locations: $e');
    }
  }

  final MapController mapController = MapController();
  double circleRadius = 10.0;
  bool showCircle = true;
  Position? currentLocation;
  Locationes? locationes;
  Location? location;
  LocationeDevice? deviceLocation;
  List<LatLng> locationArray = [];
  List<LatLng> DeviceArray = [];

  bool hidePolylines =
      false; // Variable para controlar la visibilidad de las polilíneas
  bool hideMarkers =
      false; // Variable para controlar la visibilidad de los marcadores

  @override
  void initState() {
    super.initState();
    getLocation();
    _loadData();
  }

  Future<void> _loadData() async {
    // Código para cargar tus datos existentes

    await _fetchLocation();
    await _DeviceLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      var box = await Hive.openBox(tokenBox);
      final token = box.get("token") as String?;
      final fetchedLocation = await getLocationes(token!);
      setState(() {
        locationes = fetchedLocation;
      });

      print('Location: ${locationes?.locationes}');
      String? drawlocation = locationes?.locationes;
      locationArray = drawlocation?.split('|').map((location) {
            List<String> coordinates = location.split(',');
            double latitude = double.parse(coordinates[0]);
            double longitude = double.parse(coordinates[1]);
            return LatLng(latitude, longitude);
          }).toList() ??
          [];

      if (locationArray.isNotEmpty) {
        locationArray.add(locationArray.first);
        LatLng defaultCenter = locationArray.first;
        // Use the default center location in case locationArray is empty
        LatLng center =
            locationArray.isNotEmpty ? locationArray.first : defaultCenter;
        mapController.move(center, 10.0);
      } else {
        // Handle the case when locationArray is empty
        // For example, you can set a default center location or show an error message
        LatLng defaultCenter = LatLng(0.0, 0.0); // Default center location
        mapController.move(defaultCenter, 10.0);
        print('Location array is empty.');
      }
    } catch (e) {
      print('Failed to load location: $e');
    }
  }

  Future<List<String>?> getDeviceLocations(String token) async {
    final fetchedLocations = await getDeviceLocationes(token);
    return fetchedLocations?.locations;
  }

  Future<void> getLocation() async {
    // Obtener la ubicación actual
    // Resto del código...
  }

  void togglePolylinesVisibility() {
    setState(() {
      hidePolylines =
          !hidePolylines; // Cambiar el estado de visibilidad de las polilíneas
    });
  }

  void toggleMarkersVisibility() {
    setState(() {
      hideMarkers =
          !hideMarkers; // Cambiar el estado de visibilidad de los marcadores
    });
  }

  @override
  Widget build(BuildContext context) {
    LatLng? initialLocation;

    if (locationArray.isNotEmpty) {
      // Si la lista de ubicaciones no está vacía, establece la ubicación inicial en la primera coordenada
      initialLocation = locationArray.first;
    }

    return Scaffold(
      body: Row(
        children: [
          const SizedBox(
            width: 100,
            child: Navigation(title: 'nav', selectedIndex: 0),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Location',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(
                            context, 'Valor enviado a la página anterior');
                      },
                      icon: const Icon(Icons.exit_to_app),
                    )
                  ],
                ),
                const Divider(
                  color: Colors.black26,
                  height: 2,
                  thickness: 1,
                  indent: 15,
                  endIndent: 0,
                ),
                Expanded(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      center: initialLocation,
                      zoom: 16, // Establece el nivel de zoom en 10
                      onTap: (point, latLng) {},
                    ),
                    nonRotatedChildren: [
                      TileLayer(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                        additionalOptions: const {
                          'accessToken': MAPBOX_ACCESS_TOKEN,
                          'id': 'mapbox/satellite-v9',
                        },
                      ),
                      if (currentLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: circleRadius * 2,
                              height: circleRadius * 2,
                              point: LatLng(
                                currentLocation!.latitude,
                                currentLocation!.longitude,
                              ),
                              builder: (ctx) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (!hidePolylines)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: locationArray,
                              strokeWidth: 4.0,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      if (!hideMarkers)
                        MarkerLayer(
                          markers: DeviceArray.map(
                            (point) => Marker(
                              width: circleRadius * 2,
                              height: circleRadius * 2,
                              point: point,
                              builder: (ctx) => Container(
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: circleRadius * 2,
                                ),
                              ),
                            ),
                          ).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: togglePolylinesVisibility,
            child:
                Icon(hidePolylines ? Icons.visibility : Icons.visibility_off),
          ),
          const SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: toggleMarkersVisibility,
            child: Icon(hideMarkers ? Icons.location_on : Icons.location_off),
          ),
        ],
      ),
    );
  }
}
