import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import '../Funciones/constantes.dart';

const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiZGFuaWVsc2cxOCIsImEiOiJjbGZ1N3F6ZWcwNDByM2Vtamo1OTNoc3hrIn0.5dFY3xEDB7oLtMbCWDdW9A';

class MapSensor extends StatefulWidget {
  final Color selectedColor;

  MapSensor(this.selectedColor);

  @override
  _MapSensorState createState() => _MapSensorState();
}

class _MapSensorState extends State<MapSensor> {
  final MapController mapController = MapController();
  List<LatLng> polylineCoordinates = [];
  List<Marker> markers = [];
  bool showMarker = true; // Cambio: establece showMarker en true
  bool myUbication = true; 
  String polylineString = '';
  Position? currentLocation;
  LatLng initialCoordinate = LatLng(0, 0);

  List<LatLng> locationArray = [];

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = position;
      initialCoordinate = LatLng(
        currentLocation!.latitude,
        currentLocation!.longitude,
      );
      mapController.move(
        initialCoordinate,
        13.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    polylineString = polylineCoordinates
        .map((point) => '${point.latitude},${point.longitude}')
        .join('|');
    print(polylineString);

    LatLng? initialLocation;

    if (locationArray.isNotEmpty) {
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
                      zoom: 13.0,
                      onTap: _handleTap,
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
                      MarkerLayer(markers: markers),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: locationArray,
                            strokeWidth: 2.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      if (currentLocation != null && myUbication)
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: LatLng(
                                currentLocation!.latitude,
                                currentLocation!.longitude,
                              ),
                              color: Colors.blue.withOpacity(0.5),
                              radius: 10,
                            ),
                          ],
                        ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              color: Color.fromARGB(255, 58, 57, 57),
                              child: Ink(
                                decoration: ShapeDecoration(
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.location_on),
                                  color: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      showMarker = true;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(TapPosition, LatLng location) async {
    if (showMarker) {
      setState(() {
        markers.clear();
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: location,
            builder: (ctx) => Container(
              child: Icon(Icons.location_pin, color: widget.selectedColor),
            ),
          ),
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Guardar ubicación'),
              content: Text('¿Desea guardar esta ubicación?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    setState(() {
                      markers.clear();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                TextButton(
                  child: Text('Guardar'),
                  onPressed: () {
                    polylineCoordinates.add(location);
                    polylineString = polylineCoordinates
                        .map((point) =>
                            '${point.latitude},${point.longitude}')
                        .join('|');
                    print(polylineString);

                    Navigator.pop(context);
                    Navigator.pop(context, polylineString);
                  },
                ),
              ],
            );
          },
        );

        showMarker = false;
      });
    }
  }
}
