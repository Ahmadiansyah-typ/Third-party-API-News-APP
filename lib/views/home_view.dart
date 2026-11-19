import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NewsApiService _service = NewsApiService();

  static const Map<String, String> _categories = {
    'technology': 'Teknologi',
    'science': 'Sains',
    'business': 'Bisnis',
    'nation': 'Nasional',
    'world': 'Dunia',
    'general': 'Utama',
  };

  String _selectedCategory = 'technology';

  late Future<List<ArticleModel>> _futureNews;

  // Cache Future setiap kategori.
  final Map<String, Future<List<ArticleModel>>> _categoryCache = {};

  @override
  void initState() {
    super.initState();

    _futureNews = _futureUntukKategori(_selectedCategory);
  }

  /// Mengambil Future dari cache kategori.
  Future<List<ArticleModel>> _futureUntukKategori(String category) {
    return _categoryCache.putIfAbsent(
      category,
      () => _service.getTopHeadlines(category: category),
    );
  }

  /// Mengganti kategori aktif.
  void _gantiKategori(String category) {
    if (category == _selectedCategory) return;

    setState(() {
      _selectedCategory = category;

      _futureNews = _futureUntukKategori(category);
    });
  }

  /// Retry: membuat Future baru dan memperbarui cache.
  void _muatUlang() {
    final future = _service.getTopHeadlines(category: _selectedCategory);

    setState(() {
      _categoryCache[_selectedCategory] = future;
      _futureNews = future;
    });
  }

  /// Pull-to-refresh.
  Future<void> _onRefresh() async {
    late Future<List<ArticleModel>> future;

    setState(() {
      future = _service.getTopHeadlines(category: _selectedCategory);

      _categoryCache[_selectedCategory] = future;
      _futureNews = future;
    });

    try {
      await future;
    } catch (_) {
      // Error akan ditampilkan oleh FutureBuilder.
    }
  }

  /// Membuka dialog pencarian.

  Future<void> _bukaDialogPencarian() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final navigator = Navigator.of(context, rootNavigator: true);

    // Membuat dialog sebagai route agar kita bisa
    // menunggu sampai animasi penutupannya selesai.
    final dialogRoute = DialogRoute<String>(
      context: context,
      barrierDismissible: true,

      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Row(
            children: [
              Icon(Icons.search, color: AppColors.accent),
              SizedBox(width: 10),
              Text('Cari Berita'),
            ],
          ),

          content: Form(
            key: formKey,

            child: TextFormField(
              controller: controller,
              autofocus: true,
              maxLength: 200,
              textInputAction: TextInputAction.search,

              decoration: InputDecoration(
                hintText: 'Contoh: Artificial Intelligence',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kata kunci tidak boleh kosong';
                }

                if (value.trim().length > 200) {
                  return 'Maksimal 200 karakter';
                }

                return null;
              },

              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() == true) {
                  FocusScope.of(dialogContext).unfocus();

                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),

            FilledButton.icon(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  FocusScope.of(dialogContext).unfocus();

                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },

              icon: const Icon(Icons.search),
              label: const Text('Cari'),

              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        );
      },
    );

    try {
      // Menunggu hasil dialog.
      final keyword = await navigator.push<String>(dialogRoute);

      // PENTING:
      // Tunggu sampai animasi reverse selesai dan
      // overlay dialog benar-benar dilepas.
      await dialogRoute.completed;

      if (!mounted || keyword == null || keyword.isEmpty) {
        return;
      }

      // Setelah dialog benar-benar tertutup,
      // baru buka SearchView menggunakan GetX.
      Get.toNamed(AppRoutes.search, parameters: {'keyword': keyword});
    } finally {
      controller.dispose();
    }
  }

  /// Tampilan untuk loading, error, dan empty state.
  Widget _buildStateList(Widget child) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.all(24),

      children: [SizedBox(height: 340, child: Center(child: child))],
    );
  }

  /// Membuat pilihan kategori.
  Widget _buildCategoryChips() {
    return Container(
      height: 64,

      color: AppColors.surface,

      padding: const EdgeInsets.symmetric(vertical: 8),

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(horizontal: 16),

        itemCount: _categories.length,

        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },

        itemBuilder: (context, index) {
          final category = _categories.keys.elementAt(index);

          return ChoiceChip(
            label: Text(_categories[category]!),

            selected: category == _selectedCategory,

            onSelected: (selected) {
              if (selected) {
                _gantiKategori(category);
              }
            },

            selectedColor: AppColors.primary,

            backgroundColor: AppColors.background,

            labelStyle: TextStyle(
              color: category == _selectedCategory
                  ? Colors.white
                  : AppColors.textPrimary,

              fontWeight: FontWeight.w600,

              fontSize: 13,
            ),

            side: BorderSide.none,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

        elevation: 0,

        title: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 30),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TeknoToday',

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                Text(
                  'INDONESIA',

                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Tombol pencarian pada AppBar.
        actions: [
          IconButton(
            tooltip: 'Cari berita',

            onPressed: () {
              _bukaDialogPencarian();
            },

            icon: const Icon(Icons.search_rounded, size: 27),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          _buildCategoryChips(),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,

              color: AppColors.accent,

              child: FutureBuilder<List<ArticleModel>>(
                future: _futureNews,

                builder: (context, snapshot) {
                  // 1. LOADING STATE
                  if (snapshot.connectionState != ConnectionState.done) {
                    return _buildStateList(
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.accent),

                          SizedBox(height: 16),

                          Text(
                            'Sedang memuat berita...',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  // 2. ERROR STATE
                  if (snapshot.hasError) {
                    return _buildStateList(
                      ErrorView(
                        message: snapshot.error.toString(),
                        onRetry: _muatUlang,
                      ),
                    );
                  }

                  final articles = snapshot.data ?? [];

                  // 3. EMPTY STATE
                  if (articles.isEmpty) {
                    return _buildStateList(
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),

                          SizedBox(height: 16),

                          Text(
                            'Belum Ada Berita',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Belum ada berita untuk kategori ini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  // 4. DATA STATE
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),

                    padding: const EdgeInsets.all(16),

                    itemCount: articles.length,

                    itemBuilder: (context, index) {
                      final article = articles[index];

                      return ArticleCard(
                        article: article,

                        onTap: () {
                          Get.toNamed(AppRoutes.detail, arguments: article);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
