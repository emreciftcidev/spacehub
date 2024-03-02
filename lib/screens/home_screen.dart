import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import '../models/space_card.dart';
import './planets_detail.dart';
import './astro_bot.dart';
import './favorite_cards.dart'; 
import './assistant.dart'; 
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SpaceCard> cards = [];
  List<SpaceCard> favoriteCards = []; 
  List<String> notes = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  Future<void> loadCards() async {
    final String response = await rootBundle.loadString('lib/assets/data/cards_info.json');
    final List<dynamic> cardListJson = json.decode(response) as List;
    setState(() {
      cards = cardListJson.map((json) => SpaceCard.fromJson(json)).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AstroBotPage()));
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => FavoriteCardsPage(favoriteCards: favoriteCards)));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AssistantPage()));
        break;
      case 4:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AgendaPage())); // Gündem sayfası için yönlendirme
        break;
    }
  }

  void _toggleFavorite(SpaceCard card) {
    setState(() {
      if (favoriteCards.contains(card)) {
        favoriteCards.remove(card);
      } else {
        favoriteCards.add(card);
      }
    });
  }

  void _openNotePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotePage(notes: _convertNotesToMap())),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        notes.add(result);
      });
    }
  }

  List<Map<String, String>> _convertNotesToMap() {
    List<Map<String, String>> formattedNotes = [];
    for (String note in notes) {
      formattedNotes.add({'title': '', 'content': note});
    }
    return formattedNotes;
  }

  void _openAboutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SpaceHub',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 58, 55, 88), Color.fromARGB(255, 93, 97, 148)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey[200],
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 58, 55, 88), Color.fromARGB(255, 93, 97, 148)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    'SpaceHub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Günlük',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                onTap: _openNotePage,
              ),
              ListTile(
                title: Text(
                  'Hakkımda',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                onTap: _openAboutPage,
              ),
              ListTile(
                title: Text(
                  'Gündem',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AgendaPage()));
                },
              ),
            ],
          ),
        ),
      ),

      body: Column(
          children: <Widget>[
            SizedBox(height: 25.0),
            Expanded(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  final isFavorite = favoriteCards.contains(card);
                  if (index == 0) {
                    // Mars kartını ekleyin
                    return Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: AssetImage(card.imageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.7),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Card(
                        color: Colors.transparent,
                        elevation: 0,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(card.imageUrl),
                            radius: 30,
                          ),
                          title: Text(card.title,
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(card.description,
                              style: TextStyle(color: Colors.white)),
                          trailing: IconButton(
                            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                            color: isFavorite ? Colors.red : Colors.white,
                            onPressed: () => _toggleFavorite(card),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PlanetDetailPage(planet: card),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    
                    return Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: AssetImage(card.imageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.7),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Card(
                        color: Colors.transparent,
                        elevation: 0,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(card.imageUrl),
                            radius: 30,
                          ),
                          title: Text(card.title,
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(card.description,
                              style: TextStyle(color: Colors.white)),
                          trailing: IconButton(
                            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                            color: isFavorite ? Colors.red : Colors.white,
                            onPressed: () => _toggleFavorite(card),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PlanetDetailPage(planet: card),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_sharp),
            label: 'SpaceBot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class NotePage extends StatefulWidget {
  final List<Map<String, String>> notes;

  const NotePage({Key? key, required this.notes}) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final String apiUrl = 'http://127.0.0.1:8080/api/Notes'; 

 
  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> fetchedNotes = json.decode(response.body);
        setState(() {
          widget.notes.clear();
          widget.notes.addAll(fetchedNotes.map((note) => {
            'id': note['id'], 
            'title': note['baslik'],
            'content': note['icerik'],
          }));
        });
      } else {
        
        print('Failed to load notes from API');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _addNote() async {
    final String title = _titleController.text;
    final String content = _contentController.text;
    if (title.isNotEmpty && content.isNotEmpty) {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'baslik': title,
          'icerik': content,
          
          'durum': true,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newNote = json.decode(response.body);
        final newNoteId = newNote['id']; 
        setState(() {
          widget.notes.add({
            'id': newNoteId!.toString(), 
            'title': title,
            'content': content,
          });
        });
      } else {

        print('Notlar Yüklenemedi.');
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        setState(() {
          widget.notes.removeWhere((note) => note['id'] == id);
        });
      } else {
        
        print('Notlar Yüklenemedi.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Günlük',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 58, 55, 88), Color.fromARGB(255, 93, 97, 148)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Günlük Notlar',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: widget.notes.length,
                itemBuilder: (context, index) {
                  final note = widget.notes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          note['title']!,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          note['content']!,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteNote(note['id']!), 
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'İçerik',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addNote,
              child: Text('Günlüğüme Not Et', style: TextStyle(color: Color.fromARGB(255, 86, 95, 170), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}


class ProfilePage extends StatelessWidget {
  final String _url = 'https://www.bento.me/emreciftci'; 

 
  void _launchURL() async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: AppBar(
          title: Text('Hakkımda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color.fromARGB(255, 58, 55, 88), Color.fromARGB(255, 93, 97, 148)],
              ),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 75,
              backgroundImage: AssetImage('lib/assets/images/emre_ciftci.jpg'),
            ),
            SizedBox(height: 24),
            Text(
              'Emre Çiftçi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "I'm Emre Çiftçi. I'm 23 years old and I live in Istanbul. I managed our building materials market business between 2021-2024. Afterwards, I started to be interested in software development. Following this interest, I applied to courses in WEB and Mobile Application Development. I started learning with the courses I was entitled to. I am currently learning Front-end / Back-end for WEB and Swift software languages for mobile application development. I'm also learning Flutter with the Kodluyoruz Hİ-Kod 2.0 bootcamp that I am entitled to attend. I'm enthusiastically getting involved in communities, meeting new people, and learning from their experiences. Joining teams and taking part in interviews helps me gain new skills and grow as a person.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: _launchURL,
              child: Text('Sosyal Medya Hesaplarım'),
              style: ElevatedButton.styleFrom(
                primary: Colors.indigo, 
                onPrimary: Colors.white, 
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}

class AgendaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gündem',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 58, 55, 88), Color.fromARGB(255, 93, 97, 148)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildNewsCard(
              title: 'Axiom Space, Uzay İstasyonundan Dönüşün Ardından Ax-3 Mürettebatının Basın Toplantısı Düzenleyecek',
              description: 'Axiom Mission 3 (Ax-3) mürettebatı, uzayda yaklaşık 22 gün ve Uluslararası Uzay İstasyonunda 18 gün geçirdikten sonra Dünyaya döndü. 27 Şubat 2024 tarihinde TSİ 10:00da düzenlenecek bir basın toplantısında deneyimlerini paylaşacaklar. Ax-3, İtalya, Türkiye ve İsveçten astronotları barındıran ve Avrupalı ilk ticari uzay uçuşu görevidir. Mürettebat, yörüngede 54 deney ve 28 medya ve sosyal yardım faaliyeti gerçekleştirdi. Bu çalışmalar, insan fizyolojisinin Dünya dışında anlaşılmasını ve uzun süreli uzay görevlerine hazırlığı destekleyecektir. Görev, SpaceX Falcon 9 roketi ve Dragon uzay aracıyla 18 Ocakta başladı ve 7 Şubatta ISSden ayrılarak güvenli bir şekilde sona erdi.',
              imageUrl: 'https://images.squarespace-cdn.com/content/v1/5f9c4976896349619c5b3d7b/b7a0e434-b141-4bdf-a66d-eac42b955d23/Screen+Shot+2024-02-01+at+11.54.01+PM.png?format=2500w',
            ),
            _buildNewsCard(
              title: 'Ax-3 Astronotları Sıçrayarak ISSye Tüm Avrupayı kapsayan İlk Ticari Astronot Görevini Tamamladı',
              description: 'Axiom Mission 3 (Ax-3), Avrupadan hükümet ve ESA destekli astronotlardan oluşan ilk ticari uzay uçuşu görevi, 18 gün boyunca Uluslararası Uzay İstasyonunda (UUİ) kalarak 30dan fazla deney ve 50den fazla sosyal etkinlik gerçekleştirdi. Görev, insan fizyolojisinin Dünya ve mikro yerçekimi koşullarında daha iyi anlaşılmasına yönelik veriler topladı. Ax-3, Avrupanın ticari uzay endüstrisinde öncü olduğunu gösteriyor ve Axiom Spacein dünyanın ilk ticari uzay istasyonu olan Axiom İstasyonuna doğru ilerlemesinde kritik bir kilometre taşını işaret ediyor. Görev, Alper Gezeravcıyı ilk Türk astronotu ve Marcus Wandtı ticari bir uzay görevinde uçan ilk ESA proje astronotu yaparak birçok ilki kutluyor. Axiom Space, Ax-4ü Ekim 2024ten önce fırlatmayı planlıyor ve uluslararası topluluğa mikro yerçekimi ortamında bilimsel araştırmalar yapma fırsatları sunuyor.',
              imageUrl: 'https://images.squarespace-cdn.com/content/v1/5f9c4976896349619c5b3d7b/74c362f3-922d-4a4d-b30c-96a71af3e2c7/image006.jpg?format=2500w',
            ),
            _buildNewsCard(
              title: 'Ax-3 Görev Güncellemesi Uçuş Günü #22',
              description: 'Aksiyom Misyonu 3 (Ax-3) Komutanı Michael López-Alegría, Pilot Walter Villadei, Misyon Uzmanı Alper Gezeravcı ve Misyon Uzmanı Marcus Wandt ev yolunda! Yaklaşık 435 saat, 18 gün ve 288 yörünge boyunca yaklaşık 7.6 milyon mil kat eden Ax-3 astronotlarının uzay istasyonundaki zamanı sona erdi. Dün, ekip 9:20de (doğu saatine göre) Uluslararası Uzay İstasyonundan ayrılarak ev yolculuklarına başladı ve yanlarında unutulmaz anılar ve paha biçilmez bilimsel veriler taşıdılar. Dünyaya 47 saatlik bir yolculuktan sonra astronotların Florida kıyılarının açıklarında yarın saat 8:30da (doğu saatine göre) denize iniş yapması hedefleniyor ve yayın saat 7:25te başlayacak. İniş güncellemeleri ve detayları buradan bulabilirsiniz. Ax-3 birçok ilki kutluyor: Hükümet ve ESA sponsorlu ulusal astronotların yer aldığı ilk ticari uzay uçuşu misyonu olması; Misyon Uzmanı Alper Gezeravcının tarihte ilk kez Türk astronot olması; ve Misyon Uzmanı Marcus Wandtın bir ticari uzay misyonunda uçan ilk ESA proje astronotu olması. Ax-3, dünyanın ilk ticari uzay istasyonu olan Aksiyom İstasyonunun gerçekleştirilmesine doğru kritik bir kilometre taşı işaret ediyor.',
              imageUrl: 'https://images.squarespace-cdn.com/content/v1/5f9c4976896349619c5b3d7b/a41b6370-f4f1-40a9-b6c1-05ff7c444cc8/ax03e015036.jpg?format=2500w',
            ),
            _buildNewsCard(
              title: 'Axiom Space, Ax-3 mürettebatının Uluslararası Uzay İstasyonuna Gelişini Kutluyor',
              description: 'Aksiyom Misyonu 3 (Ax-3) mürettebatı başarılı bir şekilde hedeflerine ulaştı ve Uluslararası Uzay İstasyonundaki (ISS) 14 günlük görevlerine başladı. Ax-3 Komutanı Michael López-Alegría, Pilot Walter Villadei, Misyon Uzmanı Alper Gezeravcı ve Misyon Uzmanı Marcus Wandt, 20 Ocakta doğu saatiyle 07:15te uzay istasyonuna girdi. Komutan López-Alegría, diğer mürettebat üyelerine resmi astronot rozetlerini törenle takarak ekip üyelerinin resmi olarak astronot olmaya başladığını belirtti. Gezeravcının uzaya giden 676. ve Wandtın 677. kişi olduğunu duyurdu. Villadei ise 29 Haziran 2023te Virgin Galactic uçuşu sırasında 666. kişi oldu.Ax-3 astronotlarını taşıyan SpaceX Dragon uzay aracı, 18 Ocakta Floridadaki Kennedy Uzay Merkezindeki Fırlatma Kompleksi 39A dan doğu saatiyle 16:49da Falcon 9 roketi ile uzaya yola çıktı.Uzay istasyonunda geçirecekleri süre boyunca Ax-3 mürettebatı, bilim ve teknolojinin çeşitli alanlarını kapsayan 30 dan fazla deney gerçekleştirecek. Bu çabalar, insan uzay uçuşlarında ilerlemelerin sağlanmasını amaçlamakta ve ev gezegenimizde yaşamı geliştirmeye katkıda bulunmaktadır. Ax-3, dünyanın ilk ticari uzay istasyonu olması planlanan Aksiyom İstasyonu için temel oluşturan, önerilen Aksiyom Uzay insan uzay uçuşu misyonlarının üçüncüsü olarak yer almaktadır. Görev, 3 Şubatta kenetlenmeyle sona erecek ve Dragon uzay aracıyla Florida kıyılarının açıklarında bir denize inişle noktalanacak.',
              imageUrl: 'https://images.squarespace-cdn.com/content/v1/5f9c4976896349619c5b3d7b/b66e45ce-f321-49c7-9ff6-a79cb360c97e/Screen+Shot+2024-01-20+at+6.36.05+AM.png?format=2500w',
             ),
             _buildNewsCard(
              title: 'Ax-3 Mürettebatı Uluslararası Uzay İstasyonuna Kenetlendi',
              description: 'Axiom Space in Axiom Mission 3 (Ax-3) mürettebatı, yaklaşık 36 saatlik bir yolculuğun ardından Uluslararası Uzay İstasyonu na (UUİ) başarıyla ulaştı. SpaceX Dragon uzay aracı, Pasifik Okyanusu üzerinde süzülürken 20 Ocak günü sabah saat 5:42 de ISS Harmony modülüne kenetlendi. Ax-3 görevi, alçak dünya yörüngesine (LEO) giden yolu yeniden tanımlayan ve dünyanın ilk ticari uzay istasyonu olan Axiom İstasyonu na doğru bir rota çizilmesine yardımcı olan ISS ye fırlatılan tamamı Avrupalı ilk ticari astronot göreviyle bir başka kilometre taşına işaret ediyor. Ax-3 mürettebatı ABD ve İspanya dan Komutan Michael López-Alegría, İtalyan Hava Kuvvetleri nden Pilot Walter Villadei ve Türkiye den Alper Gezeravcı ile İsveç ve Avrupa Uzay Ajansı ndan Marcus Wandt tan oluşuyor. Çok uluslu Ax-3 astronotları UUİ ye yönelik tarihi görevlerine NASA nın Florida daki Kennedy Uzay Merkezi nde bulunan Fırlatma Kompleksi 39A dan başladılar. Kalkış 18 Ocak günü saat 16:49 da (ET) gerçekleşti. Ax-3 mürettebatı yakında uzay istasyonuna girecek ve karşılama töreni için NASA nın Keşif Ekibi tarafından karşılanacak. Böylece yörüngedeki laboratuvarda mikro yerçekimi araştırmaları, teknoloji gösterileri ve sosyal yardım faaliyetleri yürütmek üzere 14 güne kadar sürecek görevlerine başlayacaklar.',
              imageUrl: 'https://images.squarespace-cdn.com/content/v1/5f9c4976896349619c5b3d7b/ecf8155d-0abf-4aa0-a7be-efd6b77a2f43/Screen+Shot+2024-01-20+at+6.27.53+AM.png?format=2500w',
             ),
          ],
        ),
      ),
    );
  }

   Widget _buildNewsCard({required String title, required String description, required String imageUrl}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 7,
          offset: Offset(0, 3), 
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Material(
        child: InkWell(
          onTap: () {
           
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
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
  );
}
}