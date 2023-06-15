class GrapchisTemplate {
  int id;
  final String titlegraphics;
  final String namegraphics;
  final String aliasgraphics;
  final String location;
  GrapchisTemplate({
    required this.id,
    required this.titlegraphics,
    required this.namegraphics,
    required this.aliasgraphics,
    required this.location,
  });

  factory GrapchisTemplate.fromJson(Map<String, dynamic> json) {
    return GrapchisTemplate(
      id: json['id'],
      titlegraphics: json['titlegraphics'],
      namegraphics: json['namegraphics'],
      aliasgraphics: json['aliasgraphics'],
      location: json['location'],
    );
  }
}

List<GrapchisTemplate> graphics = [];