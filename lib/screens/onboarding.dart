import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  bool _showCloseButton = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null && _pageController.page!.round() == 4) {
        setState(() {
          _showCloseButton = true;
        });
      } else {
        setState(() {
          _showCloseButton = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              _buildPage('lib/assets/images/gezegen.png', 'Gezegenler', 'Güneş Sistemi\'ndeki gezegenler hakkında bilgi edinin.'),
              _buildPage('lib/assets/images/günlük.png', 'Günlük', 'Tüm notlarınızı tek bir yerde toplayın. Ayrıca, günlük yazılarınızı paylaşın.'),
              _buildPage('lib/assets/images/bot.png', 'SpaceHub Chat', 'SpaceHub Chat ile ulaşmak istediğiniz bilgilere saniyeler içinde erişin.'),
              _buildPage('lib/assets/images/gündem.png', 'Gündem Hakkında Haber!', 'Göreviniz esnasında güncel gelişmeleri takip edin.'),
              _buildPage('lib/assets/images/profil.png', 'Anlık Sağlık Takip Profili', 'Kritik sağlık bilgilerinizi anlık olarak takip edin. Ayrıca, görev detaylarınızı kontrol edin.'),
            ],
          ),
          Positioned(
            left: 160,
            right: 0,
            bottom: 20,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 5,
                effect: WormEffect(),
                onDotClicked: (index) => _pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
          ),
          if (_showCloseButton)
            Positioned(
              top: 50.0,
              right: 15.0,
              child: AnimatedOpacity(
                opacity: _showCloseButton ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  icon: Icon(Icons.close, color: Colors.black),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(String imagePath, String title, String description) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 40.0),
          Text(
            title,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.0),
          Text(
            description,
            style: TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
