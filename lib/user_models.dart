import 'package:flutter/cupertino.dart';


//clase usuario, los datos enviados por los guarda aca para mostrarlos en la aplicacion
class User {
  int? id;
  String? token;
  String? username;
  String? email; //first_name, last_name;

  User({
    this.email,
    // this.first_name,
    //this.last_name,
    this.id,
    this.username,
  });

//{"pk":2,"username":"","email":"example1@gmail.com","first_name":"First","last_name":"Last"}
  factory User.fromJson(json) {
    print(json);
    return User(
      email: json["email"],
      //first_name: json["first_name"],
      id: json["pk"],
      //last_name: json["last_name"],
      username: json["username"],
    );
  }
}
