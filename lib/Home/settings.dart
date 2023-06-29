import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pianta/register/login.dart';
import 'package:pianta/Funciones/edit_setting.dart';
import 'package:pianta/Funciones/constantes.dart';
import '../api_login.dart';
import '../constants.dart';

//clase creada para la pantalla de configuracion
class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}



class _SettingsState extends State<Settings> {
  String? _username;
  String? _email;
  String? _lastLogin;

  @override
  void initState() {
    super.initState();
    _loadUsernameAndLastLogin();
  }

  Future<void> _loadUsernameAndLastLogin() async {
    try {
      var box = await Hive.openBox(tokenBox);
      final token = box.get("token") as String?;
      final username = await getUsername(token!);
      final lastLogin = await getLastLogin(token);
      final email = await getEmail(token);
      print(email);
      setState(() {
        _username = username;
        _email = email;
        _lastLogin = lastLogin != null ? DateTime.parse(lastLogin).toString() : null;
        print(_username);
        print(_email);
        print(_lastLogin);
      });
    } catch (e) {
      print('Failed to load username, email and last login: $e');
    }
  }

  Future<void> _logout() async {
    try {
      var box = await Hive.openBox(tokenBox);
      final token = box.get("token") as String?;
      await logOut(token!);
      box.close();
    } catch (e) {
      print('Failed to logout: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    //User user = context.read<UserCubit>().state;
    return Scaffold(
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              bool isMobile = MediaQuery.of(context).size.width < 600;
              double barWidth = isMobile ? 60.0 : 100.0; // Ajusta el ancho de la barra de navegación
              double textTitleSize = isMobile ? 18.0 : 30.0;
              double textButom = isMobile ? 9.0 : 16.0;
              double iconSize = isMobile ? 18.0: 40.0;
              double names = isMobile ? 15.0 : 30.0;

          return Row(
            children: [
              SizedBox(
                width: barWidth,
                child: Navigation(title: 'nav', selectedIndex: 2 /* Fundamental SelectIndex para que funcione el selector*/),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                //texto al inico de la pagina
                                child: Text(
                                  _username ?? '',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: textTitleSize),
                                ),
                              ),
                              //funcion que permite volver el iciono solo, un boton
                              InkWell(
                                //icono deseado
                                child: Icon(Icons.list, size: iconSize),
                                onTap: (){
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Container(
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            height: MediaQuery.of(context).size.height * 0.8,
                                            child: Column(
                                              children: [
                                                Expanded(child: EditInformation()),
                                              ],
                                            )
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            ]
                        ),
                        Padding(
                          padding: const EdgeInsets.all(19.0),
                          //boton
                          child: ElevatedButton(
                            onPressed: () async{
                              await _logout();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Login()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.white// Color de fondo del botón
                            ),
                            //texto que aparecera en el boton
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: Colors.black, size: iconSize),
                                SizedBox(width: 5),
                                Text('Log Out', style: TextStyle(color: Colors.black, fontSize: textButom)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.black26, //color of divider
                      height: 2, //height spacing of divider
                      thickness: 1, //thickness of divier line
                      indent: 15, //spacing at the start of divider
                      endIndent: 0, //spacing at the end of divider
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email: ',
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: names),
                                    ),
                                    Text(
                                      _email ?? '',
                                      style: TextStyle( fontSize: 30),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Last Log In: ',
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: names),
                                    ),
                                    Text(
                                      _lastLogin ?? '',
                                      style: TextStyle( fontSize: 30),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ]
          );
        }
      )
    );
  }
}

