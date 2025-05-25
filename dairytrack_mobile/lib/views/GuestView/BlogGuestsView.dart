import 'package:dairytrack_mobile/controller/APIURL1/blogManagementController.dart';
import 'package:dairytrack_mobile/controller/APIURL1/categoryManagementController.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlogGuestsView extends StatefulWidget {
  const BlogGuestsView({Key? key}) : super(key: key);

  @override
  _BlogGuestsViewState createState() => _BlogGuestsViewState();
}

class _BlogGuestsViewState extends State<BlogGuestsView> {
  final BlogManagementController _blogController = BlogManagementController();
  final CategoryManagementController _categoryController =
      CategoryManagementController();

  List<Blog> _blogs = [];
  List<Category> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  String _errorMessage = '';

  // Light theme colors for guest view
  static const Color lightPrimary = Color(0xFFE9A319);
  static const Color lightSecondary = Color(0xFF3D8D7A);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2D3748);
  static const Color lightTextSecondary = Color(0xFF718096);
  static const Color lightBorder = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
    _fetchCategories();
  }

  Future<void> _fetchBlogs({String? categoryId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Blog> blogs =
          await _blogController.listBlogs(categoryId: categoryId);
      setState(() {
        _blogs = blogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat blog: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _categoryController.listCategories();
      if (response['success']) {
        List<dynamic> categoryData = response['data']['categories'];
        List<Category> categories =
            categoryData.map((json) => Category.fromJson(json)).toList();
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      // Silent fail for categories - tidak kritis untuk guest view
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _fetchBlogs(categoryId: _selectedCategoryId),
      _fetchCategories(),
    ]);
  }

  String _stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return htmlString;

    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String result = htmlString.replaceAll(exp, '');

    result = result
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");

    result = result
        .replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();

    return result;
  }

  void _showBlogDetail(Blog blog) {
    showDialog(
      context: context,
      builder: (context) => _buildBlogDetailDialog(blog),
    );
  }

  Widget _buildBlogDetailDialog(Blog blog) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: lightBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header dengan gambar
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                image: DecorationImage(
                  image: NetworkImage(blog.photoUrl),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {},
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMMM yyyy')
                                    .format(blog.createdAt),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories
                    if (blog.categories != null &&
                        blog.categories!.isNotEmpty) ...[
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: blog.categories!.map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: lightPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: lightPrimary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                color: lightPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _stripHtmlTags(blog.content),
                          style: const TextStyle(
                            color: lightText,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),

                    // Footer info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: lightTextSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Terakhir diperbarui: ${DateFormat('dd MMM yyyy').format(blog.updatedAt)}',
                            style: TextStyle(
                              color: lightTextSecondary,
                              fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightSurface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.article, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Blog TSTH²',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: lightPrimary,
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Category Filter
            _buildCategoryFilter(),

            // Blog List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(lightPrimary),
                      ),
                    )
                  : _errorMessage.isNotEmpty
                      ? _buildErrorWidget()
                      : _blogs.isEmpty
                          ? _buildEmptyWidget()
                          : _buildBlogList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: 'Filter berdasarkan Kategori',
          labelStyle: TextStyle(color: lightTextSecondary),
          prefixIcon: Icon(Icons.filter_list, color: lightPrimary),
        ),
        dropdownColor: lightBackground,
        style: TextStyle(color: lightText),
        value: _selectedCategoryId,
        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('Semua Kategori'),
          ),
          ..._categories.map((category) => DropdownMenuItem(
                value: category.id.toString(),
                child: Text(category.name),
              )),
        ],
        onChanged: (value) {
          setState(() {
            _selectedCategoryId = value;
          });
          _fetchBlogs(categoryId: value);
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
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
              _errorMessage,
              style: TextStyle(
                color: lightTextSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshData,
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
    );
  }

  Widget _buildEmptyWidget() {
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
              Icons.article_outlined,
              size: 64,
              color: lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Blog',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCategoryId != null
                  ? 'Tidak ada blog dalam kategori yang dipilih'
                  : 'Belum ada blog yang tersedia saat ini',
              style: TextStyle(
                color: lightTextSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _blogs.length,
      itemBuilder: (context, index) {
        final blog = _blogs[index];
        return _buildBlogCard(blog);
      },
    );
  }

  Widget _buildBlogCard(Blog blog) {
    return GestureDetector(
      onTap: () => _showBlogDetail(blog),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    blog.photoUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
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
                            Icons.image_not_supported,
                            size: 48,
                            color: lightTextSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gambar tidak dapat dimuat',
                            style: TextStyle(
                              color: lightTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(blog.createdAt),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    blog.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: lightText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Content preview
                  Text(
                    _stripHtmlTags(blog.content),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: lightTextSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Categories
                  if (blog.categories != null && blog.categories!.isNotEmpty)
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: blog.categories!.take(3).map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: lightPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: lightPrimary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              color: lightPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: lightBorder,
                        ),
                      ),
                      child: Text(
                        'Umum',
                        style: TextStyle(
                          color: lightTextSecondary,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Footer with read more
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: lightTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Diperbarui: ${DateFormat('dd/MM/yyyy').format(blog.updatedAt)}',
                            style: TextStyle(
                              color: lightTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: lightPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Baca Selengkapnya',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
