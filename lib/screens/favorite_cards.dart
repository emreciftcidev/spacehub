import 'package:flutter/material.dart';
import '../models/space_card.dart';
import './planets_detail.dart';

class FavoriteCardsPage extends StatelessWidget {
  final List<SpaceCard> favoriteCards;

  const FavoriteCardsPage({Key? key, required this.favoriteCards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favoriler',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 58, 55, 88),
                Color.fromARGB(255, 93, 97, 148)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: favoriteCards.length,
        itemBuilder: (context, index) {
          final card = favoriteCards[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlanetDetailPage(planet: card),
                ),
              );
            },
            child: Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    card.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(card.description),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(card.imageUrl),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
