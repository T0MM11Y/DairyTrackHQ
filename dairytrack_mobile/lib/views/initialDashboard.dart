import 'package:dairytrack_mobile/controller/APIURL1/blogManagementController.dart';
import 'package:dairytrack_mobile/controller/APIURL1/galleryManagementController.dart';
import 'package:dairytrack_mobile/views/GuestView/AboutGuestsView.dart';
import 'package:dairytrack_mobile/views/GuestView/BlogGuestsView.dart';
import 'package:dairytrack_mobile/views/GuestView/GalleryGuestsView.dart';
import 'package:dairytrack_mobile/views/highlights/blogView.dart';
import 'package:dairytrack_mobile/views/highlights/galleryView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'loginView.dart';
import '../controller/APIURL1/loginController.dart';

class InitialDashboard extends StatefulWidget {
  @override
  _InitialDashboardState createState() => _InitialDashboardState();
}

class _InitialDashboardState extends State<InitialDashboard>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  // Controllers for fetching data
  final BlogManagementController _blogController = BlogManagementController();
  final GalleryManagementController _galleryController =
      GalleryManagementController();

  // Data lists
  List<Blog> _blogs = [];
  List<Gallery> _galleries = [];
  bool _isLoadingBlogs = true;
  bool _isLoadingGalleries = true;
  String _blogError = '';
  String _galleryError = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _loadBlogsPreview();
    _loadGalleriesPreview();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBlogsPreview() async {
    setState(() {
      _isLoadingBlogs = true;
      _blogError = '';
    });

    try {
      print('Loading blogs preview...');
      List<Blog> blogs = await _blogController.listBlogs();
      print('Blogs loaded: ${blogs.length}');

      setState(() {
        _blogs = blogs.take(3).toList(); // Take only first 3 blogs
        _isLoadingBlogs = false;
      });
    } catch (e) {
      print('Error loading blogs: $e');
      setState(() {
        _isLoadingBlogs = false;
        _blogError = e.toString();
      });
    }
  }

  Future<void> _loadGalleriesPreview() async {
    setState(() {
      _isLoadingGalleries = true;
      _galleryError = '';
    });

    try {
      print('Loading galleries preview...');
      List<Gallery> galleries = await _galleryController.listGalleries();
      print('Galleries loaded: ${galleries.length}');

      setState(() {
        _galleries = galleries.take(4).toList(); // Take only first 4 galleries
        _isLoadingGalleries = false;
      });
    } catch (e) {
      print('Error loading galleries: $e');
      setState(() {
        _isLoadingGalleries = false;
        _galleryError = e.toString();
      });
    }
  }

  String _stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return htmlString;
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity, // Ensure full width
      height: 280, // Increased height for better proportions
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF3D8D7A), // Secondary color from About.js
            Color(0xFFE9A319), // Primary color from About.js
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Floating particles animation
          ...List.generate(
            20,
            (index) => TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(seconds: 3 + (index % 3)),
              builder: (context, value, child) {
                return Positioned(
                  left: (index * 30.0) % MediaQuery.of(context).size.width,
                  top: 50 + (value * 150),
                  child: Opacity(
                    opacity: 0.3,
                    child: Container(
                      width: 4 + (index % 3 * 2.0),
                      height: 4 + (index % 3 * 2.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Full width content with proper safe area
          Positioned.fill(
            child: SafeArea(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20), // Consistent padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
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
                    SizedBox(height: 20),
                    // Full width title
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Seputar Sapi di\nTSTH²",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36, // Increased for better impact
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Full width accent line
                    Container(
                      width: 100, // Increased width
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white70],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Full width description
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Inovasi peternakan sapi yang berkelanjutan\ndan modern untuk Indonesia",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Optional: Add decorative elements at edges
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE9A319), Color(0xFFF4B942)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    "Tentang Kami",
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
                  "Pusat Riset & Inovasi\nPerternakan Sapi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey[800],
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 60, height: 2, color: Color(0xFFE9A319)),
                    Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFE9A319),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(width: 60, height: 2, color: Color(0xFFE9A319)),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  "TSTH² mengembangkan teknologi dan manajemen peternakan sapi berbasis data, nutrisi, dan kesehatan hewan untuk mendukung peternak lokal.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          // Features grid
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildFeatureCard(
                icon: Icons.local_drink,
                title: "Sapi Perah",
                description: "Fokus produksi susu berkualitas tinggi",
                color: Color(0xFF3D8D7A),
              ),
              _buildFeatureCard(
                icon: Icons.biotech,
                title: "Girolando",
                description: "Breed unggul hasil persilangan",
                color: Color(0xFFE9A319),
              ),
              _buildFeatureCard(
                icon: Icons.health_and_safety,
                title: "Kesehatan",
                description: "Standar kesehatan & nutrisi terbaik",
                color: Color(0xFFF15A29),
              ),
              _buildFeatureCard(
                icon: Icons.eco,
                title: "Ramah Lingkungan",
                description: "Peternakan berkelanjutan",
                color: Color(0xFF3D8D7A),
              ),
            ],
          ),
          SizedBox(height: 32),
          // Stats section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3D8D7A).withOpacity(0.1),
                  Color(0xFFE9A319).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  "Pencapaian Kami",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("200+", "Populasi Sapi", Icons.pets),
                    _buildStatItem("1000+", "Liter/Hari", Icons.local_drink),
                    _buildStatItem("50+", "Peternak", Icons.people),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12), // Reduced from 16
      decoration: BoxDecoration(
        color: Colors.white,
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
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        children: [
          Container(
            width: 40, // Reduced from 50
            height: 40, // Reduced from 50
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10), // Reduced from 12
            ),
            child: Icon(icon, color: color, size: 20), // Reduced from 24
          ),
          SizedBox(height: 8), // Reduced from 12
          Flexible(
            // Added Flexible to prevent overflow
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13, // Reduced from 14
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // Added to prevent text overflow
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 6), // Reduced from 8
          Flexible(
            // Added Flexible to prevent overflow
            child: Text(
              description,
              style: TextStyle(
                fontSize: 11, // Reduced from 12
                color: Colors.grey[600],
                height: 1.3, // Reduced from 1.4
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Added to prevent text overflow
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFE9A319).withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: Color(0xFFE9A319), size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBlogPreview() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Blog Terbaru",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey[800],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1; // Navigate to Blog tab
                  });
                },
                child: Text(
                  "Lihat Semua",
                  style: TextStyle(color: Color(0xFFE9A319)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _isLoadingBlogs
              ? Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFE9A319)),
                        SizedBox(height: 16),
                        Text(
                          "Memuat blog...",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              : _blogError.isNotEmpty
                  ? Container(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Gagal memuat blog",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _blogError,
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadBlogsPreview,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE9A319),
                                foregroundColor: Colors.white,
                              ),
                              child: Text("Coba Lagi"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _blogs.isEmpty
                      ? Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Belum ada blog tersedia",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _blogs.length,
                          itemBuilder: (context, index) {
                            final blog = _blogs[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      blog.photoUrl,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          height: 120,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                              color: Color(0xFFE9A319),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 120,
                                          color: Colors.grey[300],
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey[600],
                                                size: 32,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "Gambar tidak dapat dimuat",
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          blog.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey[800],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          _stripHtmlTags(blog.content),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: Colors.grey[500],
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              DateFormat('dd MMM yyyy')
                                                  .format(blog.createdAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ],
      ),
    );
  }

  Widget _buildGalleryPreview() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Galeri",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey[800],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 2; // Navigate to Gallery tab
                  });
                },
                child: Text(
                  "Lihat Semua",
                  style: TextStyle(color: Color(0xFFE9A319)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _isLoadingGalleries
              ? Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFE9A319)),
                        SizedBox(height: 16),
                        Text(
                          "Memuat galeri...",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              : _galleryError.isNotEmpty
                  ? Container(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Gagal memuat galeri",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _galleryError,
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadGalleriesPreview,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE9A319),
                                foregroundColor: Colors.white,
                              ),
                              child: Text("Coba Lagi"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _galleries.isEmpty
                      ? Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Belum ada galeri tersedia",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: _galleries.length,
                          itemBuilder: (context, index) {
                            final gallery = _galleries[index];
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      gallery.imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                              color: Color(0xFFE9A319),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey[600],
                                                size: 32,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "Gambar tidak dapat dimuat",
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 10,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.7),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Text(
                                          gallery.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      color: Color(0xFFE9A319),
      onRefresh: () async {
        await Future.wait([
          _loadBlogsPreview(),
          _loadGalleriesPreview(),
        ]);
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeroSection(),
            _buildAboutSection(),
            _buildBlogPreview(),
            _buildGalleryPreview(),
            SizedBox(height: 100), // Extra space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return AboutGuestsView();
      case 2:
        return BlogGuestsView();
      case 3:
        return GalleryGuestsView();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _currentIndex == 1 || _currentIndex == 2 || _currentIndex == 3
          ? null // Hide AppBar for Blog and Gallery views (they have their own AppBar)
          : AppBar(
              title: Row(
                children: [
                  Icon(Icons.pets, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    "TSTH² DairyTrack",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              backgroundColor: Color(0xFF3D8D7A),
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: () async {
                    await Future.wait([
                      _loadBlogsPreview(),
                      _loadGalleriesPreview(),
                    ]);
                  },
                ),
              ],
            ),
      body: _buildContentSection(),
      floatingActionButton: _currentIndex == 0 ||
              _currentIndex == 1 ||
              _currentIndex == 2 ||
              _currentIndex == 3
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()),
                );
              },
              backgroundColor: Color(0xFFE9A319),
              child: Icon(Icons.login, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3D8D7A), Color(0xFFE9A319)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 0
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home,
                  size: _currentIndex == 0 ? 28 : 24,
                ),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 1
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: _currentIndex == 1 ? 28 : 24,
                ),
              ),
              label: 'About Me',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.article,
                  size: _currentIndex == 2 ? 28 : 24,
                ),
              ),
              label: 'Blog',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 3
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_library,
                  size: _currentIndex == 3 ? 28 : 24,
                ),
              ),
              label: 'Galeri',
            ),
          ],
        ),
      ),
    );
  }
}
