import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutGuestsView extends StatefulWidget {
  const AboutGuestsView({Key? key}) : super(key: key);

  @override
  _AboutGuestsViewState createState() => _AboutGuestsViewState();
}

class _AboutGuestsViewState extends State<AboutGuestsView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // TSTH² Theme colors
  static const Color primaryColor = Color(0xFFE9A319);
  static const Color secondaryColor = Color(0xFF3D8D7A);
  static const Color accentColor = Color(0xFFF15A29);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color textSecondaryColor = Color(0xFF718096);

  final List<Map<String, dynamic>> statsData = [
    {
      'icon': Icons.show_chart,
      'value': '1000+',
      'label': 'Liter Susu/Hari',
      'color': primaryColor,
    },
    {
      'icon': Icons.school,
      'value': '50+',
      'label': 'Peternak Terlatih',
      'color': secondaryColor,
    },
    {
      'icon': Icons.biotech,
      'value': '10+',
      'label': 'Riset Genetik',
      'color': accentColor,
    },
    {
      'icon': Icons.emoji_events,
      'value': '5+',
      'label': 'Penghargaan Sapi',
      'color': primaryColor,
    },
  ];

  // ...existing code...
  final List<Map<String, dynamic>> featuresData = [
    {
      'icon': Icons.local_drink,
      'title': 'Sapi Perah',
      'description':
          'Fokus pada produksi susu berkualitas tinggi melalui manajemen nutrisi, kesehatan, dan lingkungan kandang yang optimal.',
      'color': secondaryColor,
      'url': 'https://id.wikipedia.org/wiki/Sapi_perah',
    },
    {
      'icon': Icons.biotech,
      'title': 'Girolando',
      'description':
          'Sapi Girolando adalah hasil persilangan antara sapi Gir dan Holstein, menggabungkan ketahanan tropis dengan produktivitas susu tinggi.',
      'color': primaryColor,
      'url': 'https://en.wikipedia.org/wiki/Girolando',
    },
    {
      'icon': Icons.health_and_safety,
      'title': 'Kesehatan & Nutrisi',
      'description':
          'TSTH² menerapkan standar kesehatan hewan dan nutrisi berbasis riset untuk memastikan kesejahteraan sapi.',
      'color': accentColor,
      'url':
          'https://www.fao.org/dairy-production-products/animal-health-and-welfare/en/',
    },
    {
      'icon': Icons.eco,
      'title': 'Lingkungan Hijau',
      'description':
          'Komitmen pada keberlanjutan dengan menjaga keseimbangan ekosistem dan mendukung praktik peternakan ramah lingkungan.',
      'color': primaryColor,
      'url': 'https://www.fao.org/sustainability/en/',
    },
  ];
  // ...existing code...

  final List<Map<String, dynamic>> girolandoFeatures = [
    {
      'icon': Icons.wb_sunny,
      'title': 'Adaptabilitas Iklim',
      'description': 'Toleransi panas dan kelembaban tinggi di iklim tropis',
    },
    {
      'icon': Icons.shield,
      'title': 'Resistensi Penyakit',
      'description': 'Ketahanan terhadap parasit dan penyakit tropis',
    },
    {
      'icon': Icons.opacity,
      'title': 'Produksi Susu',
      'description': 'Rata-rata 15-25 liter/hari dengan kadar lemak 4-5%',
    },
    {
      'icon': Icons.calendar_month,
      'title': 'Masa Laktasi',
      'description': 'Periode laktasi 275-305 hari dengan persistensi baik',
    },
  ];

  final List<String> missionItems = [
    'Mengembangkan sistem pemeliharaan sapi berbasis teknologi dan data.',
    'Melakukan riset nutrisi, kesehatan, dan genetika sapi untuk meningkatkan produktivitas.',
    'Meningkatkan kapasitas peternak melalui pelatihan dan pendampingan.',
    'Menjadi pusat kolaborasi nasional dan internasional di bidang peternakan sapi.',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Try launching with external application first
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // If external application fails, try in-app web view
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
          );
        } else {
          // Show error message if URL cannot be launched
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tidak dapat membuka link: $url'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Handle any exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error membuka link: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final progress = (_particleController.value + index * 0.1) % 1.0;
            final size = 2.0 + (index % 3) * 2.0;
            final opacity = 0.3 - (progress * 0.3);

            return Positioned(
              left: (index * 50.0) % MediaQuery.of(context).size.width,
              top: MediaQuery.of(context).size.height * progress,
              child: Opacity(
                opacity: opacity.clamp(0.0, 0.3),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            secondaryColor.withOpacity(0.9),
            secondaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background image overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryColor.withOpacity(0.8),
                  primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Floating particles
          _buildFloatingParticles(),
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.pets, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  "Pusat Riset Peternakan Sapi",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Seputar Sapi di\nTSTH²",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: 80,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.white70],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "TSTH² tidak hanya fokus pada tanaman herbal dan hortikultura, tetapi juga menjadi pusat pengembangan dan riset sapi perah. Kami berkomitmen pada inovasi peternakan sapi yang berkelanjutan dan modern.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24),
                          Column(
                            children: [
                              "Riset Genetik",
                              "Teknologi Modern",
                              "Berkelanjutan"
                            ]
                                .asMap()
                                .entries
                                .map((entry) => Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            entry.value,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String badge,
    required String title,
    required String description,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            badge,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1.3,
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 60, height: 2, color: primaryColor),
            Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 60, height: 2, color: primaryColor),
          ],
        ),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        feature['color'],
                        feature['color'].withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: feature['color'].withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    feature['icon'],
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  feature['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  feature['description'],
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _launchURL(feature['url']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feature['color'],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Pelajari Lebih",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stat) {
    return Container(
      padding: EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        children: [
          Container(
            width: 50, // Reduced from 60
            height: 50, // Reduced from 60
            decoration: BoxDecoration(
              color: stat['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12), // Reduced from 15
            ),
            child: Icon(
              stat['icon'],
              color: stat['color'],
              size: 24, // Reduced from 28
            ),
          ),
          SizedBox(height: 8), // Reduced from 12
          Text(
            stat['value'],
            style: TextStyle(
              fontSize: 20, // Reduced from 24
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: 2), // Reduced from 4
          Text(
            stat['label'],
            style: TextStyle(
              fontSize: 11, // Reduced from 12
              color: textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2, // Added to handle long labels
            overflow: TextOverflow.ellipsis, // Added overflow handling
          ),
        ],
      ),
    );
  }

  Widget _buildGirolandoFeatureItem(Map<String, dynamic> feature) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature['icon'],
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  feature['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionItem(String mission, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              mission,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Tentang TSTH²',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ],
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [secondaryColor, primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(),

            SizedBox(height: 60),

            // About Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionHeader(
                badge: "Tentang Kami",
                title: "Pusat Riset & Inovasi\nPerternakan Sapi",
                description:
                    "TSTH² mengembangkan teknologi dan manajemen peternakan sapi berbasis data, nutrisi, dan kesehatan hewan. Kami mendukung peternak lokal untuk meningkatkan produktivitas dan kualitas sapi Indonesia.",
              ),
            ),

            SizedBox(height: 40),

            // Features Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: featuresData
                    .map((feature) => _buildFeatureCard(feature))
                    .toList(),
              ),
            ),

            SizedBox(height: 40),

            // Stats Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    secondaryColor.withOpacity(0.1),
                    primaryColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  _buildSectionHeader(
                    badge: "Pencapaian Kami",
                    title: "Inovasi Peternakan\nSapi Modern",
                    description:
                        "Kami mengintegrasikan teknologi digital untuk monitoring sapi, pencatatan produksi susu, pertumbuhan, dan kesehatan.",
                  ),
                  SizedBox(height: 32),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: statsData.length,
                    itemBuilder: (context, index) {
                      return _buildStatsCard(statsData[index]);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Girolando Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildSectionHeader(
                    badge: "Breed Unggulan",
                    title: "Pengembangan Breed\nGirolando",
                    description:
                        "Girolando dikembangkan pertama kali di Brasil dan sekarang menjadi salah satu breed sapi perah utama di daerah tropis.",
                  ),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'lib/assets/about.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [secondaryColor, primaryColor],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.pets,
                              size: 80,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Karakteristik Breed Girolando",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: girolandoFeatures
                        .map((feature) => _buildGirolandoFeatureItem(feature))
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Di TSTH², kami memelihara populasi Girolando dengan perbandingan genetik 5/8 Holstein dan 3/8 Gir yang telah terbukti optimal untuk kondisi iklim Indonesia.",
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondaryColor,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _launchURL(
                              'https://openknowledge.fao.org/bitstreams/94676ea4-7091-4c52-adea-d23f573d0b50/download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.book, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Penelitian FAO",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _launchURL(
                              'https://www.embrapa.br/en/gado-de-leite'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: secondaryColor,
                            side: BorderSide(color: secondaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.link, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Embrapa",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Vision & Mission Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    secondaryColor.withOpacity(0.05),
                    primaryColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  _buildSectionHeader(
                    badge: "Komitmen Kami",
                    title: "Visi & Misi\nPerternakan Sapi",
                    description:
                        "Menjadi pusat unggulan riset, inovasi, dan pengembangan sapi di Indonesia.",
                  ),
                  SizedBox(height: 32),
                  // Vision Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border(
                        left: BorderSide(color: primaryColor, width: 5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor,
                                    primaryColor.withOpacity(0.8)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                Icons.lightbulb,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "Visi",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Menjadi pusat riset dan inovasi peternakan sapi yang menghasilkan teknologi, produk untuk mendukung ketahanan pangan nasional. Kami berkomitmen untuk menjadi rujukan di tingkat nasional dan regional dalam pengembangan peternakan sapi yang berkelanjutan, efisien, dengan integrasi teknologi modern untuk kesejahteraan peternak dan kemandirian industri peternakan Indonesia.",
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Mission Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border(
                        left: BorderSide(color: secondaryColor, width: 5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    secondaryColor,
                                    secondaryColor.withOpacity(0.8)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                Icons.flag,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "Misi",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Column(
                          children: missionItems
                              .asMap()
                              .entries
                              .map((entry) =>
                                  _buildMissionItem(entry.value, entry.key))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 100), // Extra space for bottom navigation
          ],
        ),
      ),
    );
  }
}
