import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AssistantPage extends StatefulWidget {
  @override
  _AssistantPageState createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  Timer? dataFetchTimer;
  Map<String, String> stats = {
    'Kan Basıncı': 'Veri Yok',
    'Nabız': 'Veri Yok',
    'Kandaki Oksijen Seviyesi': 'Veri Yok',
    'Solunum Sayısı': 'Veri Yok'
  };

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    fetchDataFromAPI();
    dataFetchTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchDataFromAPI();
    });
  }

  @override
  void dispose() {
    dataFetchTimer?.cancel();
    super.dispose();
  }

  Future<void> initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final initializationSettings = InitializationSettings(iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> fetchDataFromAPI() async {
    try {
      var url = Uri.parse('http://127.0.0.1:8080/api/Profile');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        checkAndShowNotification('Nabız', jsonResponse['nabiz']);
        checkAndShowNotification(
            'Kan Basıncı', jsonResponse['kan_basinci']);
        checkAndShowNotification(
            'Kandaki Oksijen Seviyesi', jsonResponse['kandaki_oksijen']);
        checkAndShowNotification(
            'Solunum Sayısı', jsonResponse['solunum_sayisi']);

        setState(() {
          stats = {
            'Kan Basıncı': jsonResponse['kan_basinci'].toString(),
            'Nabız': jsonResponse['nabiz'].toString(),
            'Kandaki Oksijen Seviyesi':
                jsonResponse['kandaki_oksijen'].toString(),
            'Solunum Sayısı': jsonResponse['solunum_sayisi'].toString(),
          };
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  void checkAndShowNotification(String title, dynamic value) {
    // Set your threshold values here
    if (title == 'Nabız' && value < 90) {
      showNotification(title, value);
    } else if (title == 'Kan Basıncı' && value < 80) {
      showNotification(title, value);
    } else if (title == 'Kandaki Oksijen Seviyesi' && value < 99) {
      showNotification(title, value);
    } else if (title == 'Solunum Sayısı' && value < 12) {
      showNotification(title, value);
    }
  }

  Future<void> showNotification(String title, dynamic value) async {
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Uyarı: $title Düştü!',
      '$title değeri $value değerine düştü!',
      platformChannelSpecifics,
      payload: 'notification',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kritik Sağlık Bilgilerim',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 30),
          CircleAvatar(
            radius: 90,
            backgroundImage: AssetImage('lib/assets/images/alper_gezeravcı.jpg'),
          ),
          SizedBox(height: 10),
          Text(
            'Alper Gezeravcı',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Türkiye',
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: EdgeInsets.all(10),
              children: <Widget>[
                for (var entry in stats.entries)
                  _buildStatCard(entry.key, entry.value),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MissionScreen()), 
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.indigo,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Görev Detayları',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count) {
    IconData iconData;
    switch (title) {
      case 'Kan Basıncı':
        iconData = Icons.favorite;
        break;
      case 'Nabız':
        iconData = Icons.monitor_heart_sharp;
        break;
      case 'Kandaki Oksijen Seviyesi':
        iconData = Icons.bloodtype_sharp;
        break;
      case 'Solunum Sayısı':
        iconData = Icons.air;
        break;
      default:
        iconData = Icons.error;
    }

    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.blueGrey[100], 
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 35,
              color: Color.fromARGB(162, 255, 18, 1),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Görev Detayları',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color.fromARGB(255, 58, 55, 88),
                Color.fromARGB(255, 93, 97, 148)
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 70), 
            MissionDetailCard(
              title: 'Görev Merkezi',
              detail: 'ISS (Uluslararası Uzay İstasyonu)',
            ),
            SizedBox(height: 20),
            MissionDetailCard(
              title: 'Görev Adı ve Süresi',
              detail: 'Axiom Misson 3 , 14 Gün',
            ),
            SizedBox(height: 20),
            MissionDetailCard(
              title: 'Görev Ekibi',
              detail: 'Michael López-Alegría, Walter Villadei, Marcus Wandt',
            ),
            SizedBox(height: 20),
            MissionDetailCard(
              title: 'Yapılacak Deneyler',
              detail:
                  'Extramophyte, Crispr Gem, Uyna, gMetal, UzMAn, Pranet, Metabolom, Miyeloid, Message, Miyoka, Oksijen Satürasyonu, Vokalkord, AlgalSpace',
            ),
          ],
        ),
      ),
    );
  }
}

class MissionDetailCard extends StatelessWidget {
  final String title;
  final String detail;

  const MissionDetailCard({
    Key? key,
    required this.title,
    required this.detail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.blueGrey[100], 
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 73, 93, 134),
              ),
            ),
            SizedBox(height: 10),
            Text(
              detail,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
