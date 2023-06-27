import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../register/login.dart';
//se entrega la pantalla
class IntroScreenDefault extends StatefulWidget {
  @override
  _IntroScreenDefaultState createState() => _IntroScreenDefaultState();
}

class _IntroScreenDefaultState extends State<IntroScreenDefault> {
  List<ContentConfig> listContentConfig = [];

  @override
  void initState() {
    super.initState();

    listContentConfig.add(
      const ContentConfig(
        title: "WELCOME!",
        description:
            "PIANTA offers you a complete and detailed vision of the environment in different places. It's like having a magical window to the world around you!",
        pathImage: "images/Logotipo_pianta.png",
        backgroundColor: Color(0xffBEC9DF),
      ),
    );

    listContentConfig.add(
      const ContentConfig(
        title: "A BIT OF US",
        description:
            "Pianta is a mobile application and web interface for collecting and processing data from IoT sensors, providing real-time information on environmental variables.",
        pathImage: "images/Logotipo_pianta.png",
        backgroundColor: Color(0xff839695),
      ),
    );
  }

  void onDonePress() {
    log("End of slides");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("¿Do you want to download the PDF?"),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              ); // Cierra el cuadro de diálogo // Cierra el cuadro de diálogo
              abrirLinkGoogleDrive();
            },
            child: Text("YES"),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              ); // Cierra el cuadro de diálogo
            },
            child: Text("NO"),
          ),
        ],
      ),
    );
  }

  Future<void> abrirLinkGoogleDrive() async {
    const url = 'https://drive.google.com/file/d/1Al-aaxG0gaZ8tr3BJP-JuF_vFjmOuUmN/view?usp=sharing'; // Reemplaza con la URL de tu archivo PDF en Google Drive
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      log('No se pudo abrir el enlace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IntroSlider(
            key: UniqueKey(),
            listContentConfig: listContentConfig,
            onDonePress: onDonePress,
          ),
        ),
      ],
    );
  }
}