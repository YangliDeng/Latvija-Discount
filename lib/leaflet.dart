class Leaflet {
  final String id;
  final String name;
  final String period;
  final String path;

  Leaflet({
    required this.id,
    required this.name,
    required this.period,
    required this.path,
  });

  factory Leaflet.fromJson(Map<String, dynamic> json){
    return Leaflet(
        id: json['id'],
        name: json['name'],
        period: json['period'],
        path: json['path']
    );
  }
}