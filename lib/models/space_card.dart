class SpaceCard {
  final String title;
  final String description;
  final String imageUrl;
  final String info; 

  SpaceCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.info, 
  });

  factory SpaceCard.fromJson(Map<String, dynamic> json) {
    return SpaceCard(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      info: json['info'] ?? '', 
    );
  }
}
