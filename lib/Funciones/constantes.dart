import 'package:flutter/material.dart';
import 'package:pianta/Home/settings.dart';
import 'package:pianta/Home/templates.dart';
import 'package:pianta/Home/proyecto.dart';
import 'package:flutter/services.dart';

var myDefaultBackground = Colors.white;

class Navigation extends StatefulWidget {
  const Navigation({Key? key, required this.title, required this.selectedIndex})
      : super(key: key);
  final String title;
  final int selectedIndex;

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  List<IconData> icons = [Icons.search, Icons.more_horiz, Icons.settings_outlined];
  List<Widget> pages = [
    Proyectos(),
    Templates(),
    Settings(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          bool isMobile = MediaQuery.of(context).size.width < 600;
          double barWidth = isMobile ? 60.0 : 100.0; // Ajusta el ancho de la barra de navegación
          double itemHeight = isMobile ? 60.0 : 100.0; // Ajusta el alto de los elementos de la barra de navegación
          double iconSize = isMobile ? 30.0 : 40.0; // Ajusta el tamaño de los iconos en la barra de navegación

          return Row(
            children: <Widget>[
              // Barra de navegación
              SizedBox(
                width: barWidth,
                child: Column(
                  children: [
                    Container(
                      width: barWidth,
                      height: itemHeight,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/logo_P.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: icons.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => pages[index]),
                              );
                            },
                            child: Container(
                              height: itemHeight,
                              color: _selectedIndex == index
                                  ? const Color.fromRGBO(0, 191, 174, 1)
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  const SizedBox(width: 20.0),
                                  Icon(
                                    icons[index],
                                    size: iconSize,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

