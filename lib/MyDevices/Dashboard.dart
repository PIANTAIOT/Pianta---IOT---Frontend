import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pianta/Graficas/VitualPinDatastream.dart';
import 'package:pianta/constants.dart';

import '../Funciones/constantes.dart';
import '../Graficas/TemplateNewGrafic.dart';
import '../Home/graphics_model.dart';
import '../Home/template_model.dart';

class WebDashboard extends StatefulWidget {
  const WebDashboard({Key? key}) : super(key: key);

  @override
  _WebDashboardState createState() => _WebDashboardState();
}

class _WebDashboardState extends State<WebDashboard>
    with SingleTickerProviderStateMixin {
  final graphicstemplate = graphics = [];
  late Future<List<GrapchisTemplate>> futureGraphics;



  late List<ProjectTemplate> projects;
  late Future<List<ProjectTemplate>> futureProjects;
  ProjectTemplate? projecto;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final maxProgress = 40.0;
  ProjectTemplate? project;
  List<ProjectTemplate> duplicatedProjects = [];

  @override
  void initState() {
    super.initState();
    futureProjects = fetchProjects();
    futureGraphics = fetchGraphics();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _animation = Tween<double>(
      begin: 0,
      end: maxProgress,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
      setState(() {});
    });
  }

  Offset? finalPosition;
  List<Widget> duplicatedCards = [];


//esto es para mostrar la card
  Future<List<GrapchisTemplate>> fetchGraphics() async {
    var box = await Hive.openBox(tokenBox);
    final token = box.get("token") as String?;
    final response =
    await http.get(Uri.parse('http://127.0.0.1:8000/user/graphics/'),headers: {'Authorization': 'Token $token'},);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final List<GrapchisTemplate> projects =
      jsonList.map((json) => GrapchisTemplate.fromJson(json)).toList();
      //esto refresca el proyecto para ver los cambios
      //await refreshProjects();
      return projects;
    } else {
      throw Exception('Failed to load project list');
    }
  }
  Future<List<ProjectTemplate>> fetchProjects() async {
    var box = await Hive.openBox(tokenBox);
    final token = box.get("token") as String?;
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/user/template/'),
      headers: {'Authorization': 'Token $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final List<ProjectTemplate> projects =
      jsonList.map((json) => ProjectTemplate.fromJson(json)).toList();
      setState(() {
        this.projects = projects;
        projecto = projects.first;
      });
      return projects;
    } else {
      throw Exception('Failed to load project list');
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SizedBox(
            width: 100,
            child: Navigation(
              title: 'nav',
              selectedIndex: 1,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project?.name ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Info',
                                  style: TextStyle(
                                      fontSize: 24, color: Colors.black),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Acción a realizar al presionar el botón "Dashboard"
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const WebDashboard(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Web Dashboard',
                                  style: TextStyle(
                                      fontSize: 24, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

                  child: Stack(
                    children: [
                      Positioned.fill(
                        bottom: 0,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                transform: Matrix4.translationValues(
                                    0, _animationController.value * 100, 0),
                                child: Column(
                                  children: [
                                    Text(
                                      projecto?.name ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            fit: FlexFit.loose,
                                            child: Card(
                                              elevation: 9,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(1),
                                              ),
                                              child: InkWell(
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {},
                                                      child: Draggable<double>(
                                                        feedback: CustomPaint(
                                                          foregroundPainter:
                                                          Circular_graphics(
                                                              _animation
                                                                  .value),
                                                          child: const SizedBox(
                                                            width: 100,
                                                            height: 250,
                                                            child: Center(
                                                              child: Text(
                                                                '0 °C',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                    50),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        child: CustomPaint(
                                                          foregroundPainter:
                                                          Circular_graphics(
                                                              _animation
                                                                  .value),
                                                          child: const SizedBox(
                                                            width: 250,
                                                            height: 250,
                                                            child: Center(
                                                              child: Text(
                                                                '0 °C',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                    50),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        childWhenDragging:
                                                        const SizedBox(),
                                                        onDraggableCanceled:
                                                            (Velocity velocity,
                                                            Offset offset) {
                                                          setState(() {
                                                            finalPosition =
                                                                offset;
                                                            duplicatedCards.add(
                                                              Positioned(
                                                                top:
                                                                finalPosition!
                                                                    .dy,
                                                                left:
                                                                finalPosition!
                                                                    .dx,
                                                                child:
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                        const TempCreateGrafics(),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Card(
                                                                    child: SizedBox(
                                                                      width: 250,
                                                                      height: 250,
                                                                      child: Stack(
                                                                        children: [
                                                                          Center(
                                                                            child: CustomPaint(
                                                                              painter: Circular_graphics(_animation.value),
                                                                              child: SizedBox(
                                                                                width: 200,
                                                                                height: 200,
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    '0 °C',
                                                                                    style: TextStyle(
                                                                                      fontSize: 50,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Positioned(
                                                                            top: 10,
                                                                            right: 10,
                                                                            child: IconButton(
                                                                              icon: Icon(Icons.edit),
                                                                              onPressed: () {
                                                                                // Acción para editar la tarjeta
                                                                              },
                                                                            ),
                                                                          ),
                                                                          Positioned(
                                                                            bottom: 10,
                                                                            right: 10,
                                                                            child: IconButton(
                                                                              icon: Icon(Icons.delete),
                                                                              onPressed: () {
                                                                                // Acción para eliminar la tarjeta
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),

                                                                ),
                                                              ),
                                                            );
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {},
                                                      child: Draggable<double>(
                                                        feedback: SizedBox(
                                                          height: 250,
                                                          width: 250,
                                                          child:
                                                          Linea_Graphics(),
                                                        ),
                                                        child: SizedBox(
                                                          height: 250,
                                                          width: 250,
                                                          child:
                                                          Linea_Graphics(),
                                                        ),
                                                        childWhenDragging:
                                                        SizedBox(),
                                                        onDraggableCanceled:
                                                            (Velocity velocity,
                                                            Offset offset) {
                                                          setState(() {
                                                            finalPosition =
                                                                offset;
                                                            duplicatedCards.add(
                                                              Positioned(
                                                                top:
                                                                finalPosition!
                                                                    .dy,
                                                                left:
                                                                finalPosition!
                                                                    .dx,
                                                                child:
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    // Acción a realizar al tocar la gráfica lineal duplicada
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                        const TempCreateGrafics(),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                  SizedBox(
                                                                    height: 250,
                                                                    width: 250,
                                                                    child:
                                                                    Linea_Graphics(),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                        ),
                      ),
                      ...duplicatedCards,
                    Center(
                      child: FutureBuilder<List<GrapchisTemplate>>(
                        future: futureGraphics,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final projects = snapshot.data!;
                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).size.width > 1200
                                    ? 5
                                    : MediaQuery.of(context).size.width > 800
                                    ? 4
                                    : MediaQuery.of(context).size.width > 600
                                    ? 3
                                    : 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: projects.length,
                              itemBuilder: (BuildContext context, int index) {
                                final project = projects[index];
                                return Container(
                                  height: 1200,
                                  child: Card(
                                    color: Color.fromRGBO(0, 191, 174, 1),
                                    child: Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: new EdgeInsets.all(0),
                                            height: 130,
                                            decoration: new BoxDecoration(
                                              border: new Border.all(color: Colors.white),
                                              color: Colors.white,
                                            ),
                                          ),
                                          ListTile(
                                            title: Text(
                                              project.titlegraphics,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.black),
                                              onPressed: () async {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text('Delete template'),
                                                      content: const Text(
                                                          'Are you sure you want to delete this template?'),
                                                      actions: <Widget>[
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                          children: [
                                                            Spacer(),
                                                            TextButton(
                                                              style: ButtonStyle(
                                                                backgroundColor:
                                                                MaterialStateProperty.all<Color>(
                                                                  const Color.fromRGBO(0, 191, 174, 1),
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: const Text(
                                                                'Cancel',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          // By default, show a loading spinner
                          return Center(child: CircularProgressIndicator());
                        },
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
}



class Circular_graphics extends CustomPainter {
  final double currentProgress;

  Circular_graphics(this.currentProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..strokeWidth = 5
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );
    final radius = 100.0; //se cuadra el tamano del circulo
    canvas.drawCircle(center, radius, circlePaint);

    final animationArcPaint = Paint()
      ..strokeWidth = 5
      ..color = Colors.purpleAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final angle = 2 * pi * (currentProgress / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi / 2,
        angle, false, animationArcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Linea_Graphics extends StatelessWidget {
  const Linea_Graphics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = [
      Expenses(2, 120),
      Expenses(3, 220),
      Expenses(4, 219),
      Expenses(5, 154),
      Expenses(6, 310),
      Expenses(7, 290),
      Expenses(8, 390),
    ];
    final series = [
      charts.Series(
        id: 'Expenses',
        data: data,
        domainFn: (Expenses expenses, _) => expenses.day,
        measureFn: (Expenses expenses, _) => expenses.amount,
      ),
    ];

    final chart = charts.LineChart(
      series,
      animate: true,
    );

    return AbsorbPointer(
      absorbing: true, // Deshabilita la interacción con los widgets hijos
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: chart,
      ),
    );
  }
}

class Expenses {
  final int day;
  final int amount;

  Expenses(this.day, this.amount);
}