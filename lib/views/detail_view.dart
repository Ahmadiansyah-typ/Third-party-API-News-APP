import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article_model.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/news_image.dart';

class DetailView extends StatelessWidget {
  final ArticleModel? article;

  const DetailView({super.key, required this.article});

  /// Membuka halaman berita asli.
  Future<void> _bukaSumber(BuildContext context) async {
    final url = article?.url;

    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan berita tidak tersedia.')),
      );
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan berita tidak valid.')),
      );
      return;
    }

    try {
      final berhasil = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!berhasil && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka sumber berita.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat membuka berita.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pengamanan apabila halaman dibuka tanpa ArticleModel.
    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Berita')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Data Berita Tidak Tersedia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan kembali dan pilih artikel dari '
                  'daftar berita.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final data = article!;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Detail Berita',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar berita.
            NewsImage(url: data.urlToImage, height: 260),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi sumber berita.
                  Row(
                    children: [
                      const Icon(
                        Icons.newspaper_outlined,
                        color: AppColors.accent,
                        size: 19,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          data.author ?? 'Sumber berita',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        DateFormatter.formatDate(data.publishedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Judul artikel.
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.35,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Deskripsi artikel.
                  if (data.description != null &&
                      data.description!.trim().isNotEmpty) ...[
                    Text(
                      data.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  const Divider(),

                  const SizedBox(height: 16),

                  const Text(
                    'Isi Berita',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    data.content?.trim().isNotEmpty == true
                        ? data.content!
                        : 'Konten lengkap tidak tersedia. '
                              'Silakan buka sumber berita asli '
                              'untuk membaca selengkapnya.',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Tombol menuju sumber asli.
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: data.url == null || data.url!.trim().isEmpty
                          ? null
                          : () => _bukaSumber(context),

                      icon: const Icon(Icons.open_in_new),

                      label: const Text('Baca Berita Selengkapnya'),

                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
