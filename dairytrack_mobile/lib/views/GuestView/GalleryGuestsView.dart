import 'package:dairytrack_mobile/controller/APIURL1/galleryManagementController.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GalleryGuestsView extends StatefulWidget {
  const GalleryGuestsView({Key? key}) : super(key: key);

  @override
  _GalleryGuestsViewState createState() => _GalleryGuestsViewState();
}

class _GalleryGuestsViewState extends State<GalleryGuestsView> {
  final GalleryManagementController galleryController =
      GalleryManagementController();

  List<Gallery> galleries = [];
  List<Gallery> filteredGalleries = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  bool isSearching = false;

  // Light theme colors for guest view
  static const Color lightPrimary = Color(0xFFE9A319);
  static const Color lightSecondary = Color(0xFF3D8D7A);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2D3748);
  static const Color lightTextSecondary = Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    _loadGalleries();
  }

  Future<void> _loadGalleries() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      galleries = await galleryController.listGalleries();
      filteredGalleries = List.from(galleries);
    } catch (e) {
      errorMessage = 'Gagal memuat galeri: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterGalleries(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredGalleries = List.from(galleries);
      } else {
        filteredGalleries = galleries
            .where((gallery) =>
                gallery.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showFullScreenImage(BuildContext context, Gallery gallery) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Background overlay
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.black87,
                ),
              ),
              // Image container
              Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: Image.network(
                            gallery.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 300,
                                color: lightBackground,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: lightPrimary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 300,
                              color: lightSurface,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 64,
                                    color: lightTextSecondary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Gambar tidak dapat dimuat',
                                    style: TextStyle(
                                      color: lightTextSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Info panel
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: lightBackground,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gallery.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: lightText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: lightTextSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Dibuat: ${DateFormat('dd MMMM yyyy').format(gallery.createdAt)}',
                                    style: TextStyle(
                                      color: lightTextSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              if (gallery.createdAt != gallery.updatedAt) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.update,
                                      size: 16,
                                      color: lightTextSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Diperbarui: ${DateFormat('dd MMMM yyyy').format(gallery.updatedAt)}',
                                      style: TextStyle(
                                        color: lightTextSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightSurface,
      appBar: AppBar(
        title: isSearching
            ? TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Cari galeri...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: _filterGalleries,
              )
            : Row(
                children: [
                  Icon(Icons.photo_library, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Galeri TSTH²',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
        backgroundColor: lightSecondary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [lightSecondary, lightPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false, // Remove back button
        leading: isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    _filterGalleries('');
                  });
                },
              )
            : null, // No leading widget when not searching
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            ),
          if (isSearching)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                setState(() {
                  _filterGalleries('');
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadGalleries,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(lightPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat galeri...',
              style: TextStyle(
                color: lightTextSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else if (errorMessage != null) {
      return _buildErrorWidget();
    } else if (filteredGalleries.isEmpty && searchQuery.isNotEmpty) {
      return _buildNoSearchResultsWidget();
    } else if (filteredGalleries.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildGalleryGrid();
    }
  }

  Widget _buildErrorWidget() {
    return RefreshIndicator(
      color: lightPrimary,
      onRefresh: _loadGalleries,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: lightBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ups! Terjadi Kesalahan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      color: lightTextSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _loadGalleries,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoSearchResultsWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: lightBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ditemukan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada galeri yang cocok dengan "$searchQuery"',
              style: TextStyle(
                color: lightTextSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _filterGalleries('');
                });
              },
              icon: Icon(Icons.refresh, color: lightPrimary),
              label: Text(
                'Tampilkan Semua Galeri',
                style: TextStyle(color: lightPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return RefreshIndicator(
      color: lightPrimary,
      onRefresh: _loadGalleries,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: lightBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: lightTextSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Galeri',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada galeri yang tersedia saat ini',
                    style: TextStyle(
                      color: lightTextSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return RefreshIndicator(
      color: lightPrimary,
      onRefresh: _loadGalleries,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62, // Increased from 0.75 to give more height
        ),
        itemCount: filteredGalleries.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final gallery = filteredGalleries[index];
          return _buildGalleryItem(gallery);
        },
      ),
    );
  }

  Widget _buildGalleryItem(Gallery gallery) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, gallery),
      child: Container(
        decoration: BoxDecoration(
          color: lightBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section
            Expanded(
              flex: 4, // Increased from 3
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      gallery.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: lightSurface,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: lightPrimary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          color: lightSurface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: lightTextSecondary,
                              size: 28, // Reduced from 32
                            ),
                            const SizedBox(height: 6), // Reduced from 8
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Gambar tidak dapat dimuat',
                                style: TextStyle(
                                  color: lightTextSecondary,
                                  fontSize: 10, // Reduced from 12
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6), // Reduced from 8
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(10), // Reduced from 12
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: Colors.white,
                        size: 18, // Reduced from 20
                      ),
                    ),
                  ),
                  // View indicator
                  Positioned(
                    bottom: 6, // Reduced from 8
                    right: 6, // Reduced from 8
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, // Reduced from 8
                        vertical: 3, // Reduced from 4
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius:
                            BorderRadius.circular(10), // Reduced from 12
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 10, // Reduced from 12
                          ),
                          SizedBox(width: 3), // Reduced from 4
                          Text(
                            'Lihat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9, // Reduced from 10
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Expanded(
              flex: 2, // Keep the same
              child: Padding(
                padding: const EdgeInsets.all(10), // Reduced from 12
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // Add this to prevent overflow
                  children: [
                    // Title
                    Flexible(
                      // Changed from fixed height to Flexible
                      child: Text(
                        gallery.title,
                        style: TextStyle(
                          fontSize: 14, // Reduced from 16
                          fontWeight: FontWeight.bold,
                          color: lightText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6), // Reduced from 8
                    // Date
                    Flexible(
                      // Changed to Flexible
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12, // Reduced from 14
                            color: lightTextSecondary,
                          ),
                          const SizedBox(width: 3), // Reduced from 4
                          Expanded(
                            child: Text(
                              DateFormat('dd MMM yyyy')
                                  .format(gallery.createdAt),
                              style: TextStyle(
                                color: lightTextSecondary,
                                fontSize: 10, // Reduced from 12
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4), // Add small spacer
                    // Bottom info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, // Reduced from 8
                        vertical: 3, // Reduced from 4
                      ),
                      decoration: BoxDecoration(
                        color: lightPrimary.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(6), // Reduced from 8
                        border: Border.all(
                          color: lightPrimary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 10, // Reduced from 12
                            color: lightPrimary,
                          ),
                          const SizedBox(width: 3), // Reduced from 4
                          Text(
                            'Ketuk untuk melihat',
                            style: TextStyle(
                              color: lightPrimary,
                              fontSize: 8, // Reduced from 10
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
