import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

import 'package:get/get.dart';

import '../routes/app_routes.dart';

class SearchView extends StatefulWidget {
  final String keyword;

  const SearchView({super.key, required this.keyword});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final NewsApiService _service = NewsApiService();

  late Future<List<ArticleModel>> _futureSearch;

  @override
  void initState() {
    super.initState();

    final keyword = widget.keyword.trim();

    _futureSearch = keyword.isEmpty
        ? Future.value(<ArticleModel>[])
        : _service.searchNews(keyword);
  }

  /// Membuat Future baru ketika pengguna mencoba kembali.
  void _muatUlang() {
    final keyword = widget.keyword.trim();

    if (keyword.isEmpty) return;

    setState(() {
      _futureSearch = _service.searchNews(keyword);
    });
  }

  /// Refresh hasil pencarian.
  Future<void> _onRefresh() async {
    final keyword = widget.keyword.trim();

    if (keyword.isEmpty) return;

    late Future<List<ArticleModel>> future;

    setState(() {
      future = _service.searchNews(keyword);
      _futureSearch = future;
    });

    try {
      await future;
    } catch (_) {
      // Error ditangani FutureBuilder.
    }
  }

  /// Tampilan untuk loading dan error.
  Widget _buildStateList(Widget child) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [SizedBox(height: 340, child: Center(child: child))],
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
        title: const Text(
          'Hasil Pencarian',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informasi kata kunci.
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Berita yang dicari',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '"${widget.keyword}"',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.accent,

              child: FutureBuilder<List<ArticleModel>>(
                future: _futureSearch,

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
                            'Sedang mencari berita...',
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            widget.keyword.trim().isEmpty
                                ? 'Kata Pencarian Tidak Tersedia'
                                : 'Berita Tidak Ditemukan',

                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            widget.keyword.trim().isEmpty
                                ? 'Silakan kembali ke halaman utama '
                                      'dan lakukan pencarian kembali.'
                                : 'Tidak ada berita yang sesuai '
                                      'dengan kata kunci pencarian.',

                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
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
