import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../models/article_model.dart';
import '../models/news_response_model.dart';
import 'api_exception.dart';

/// Pusat komunikasi aplikasi dengan GNews API.
class NewsApiService {
  final Dio _dio;

  NewsApiService({Dio? dio}) : _dio = dio ?? _buatDio();

  /// Membuat konfigurasi Dio.
  static Dio _buatDio() {
    final baseUrl = _normalisasiBaseUrl(Env.baseUrl);

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,

        connectTimeout: const Duration(seconds: 10),

        receiveTimeout: const Duration(seconds: 15),

        queryParameters: {
          'apikey': Env.apiKey,
          'lang': 'id',
          'country': 'id',
          'max': 10,
        },
      ),
    );

    // Log hanya aktif pada mode debug.
    // API key disamarkan sebelum dicetak.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) {
            debugPrint(Env.samarkan(obj.toString()));
          },
        ),
      );
    }

    return dio;
  }

  /// Memastikan base URL memiliki garis miring di akhir.
  ///
  /// Endpoint menggunakan path relatif agar /api/v4
  /// tidak hilang ketika digabungkan dengan base URL.
  static String _normalisasiBaseUrl(String value) {
    final url = value.trim();

    if (url.isEmpty) return '';

    return url.endsWith('/') ? url : '$url/';
  }

  /// Mengambil berita berdasarkan kategori.
  Future<List<ArticleModel>> getTopHeadlines({String category = 'general'}) {
    return _ambilArtikel('top-headlines', {'category': category});
  }

  /// Mencari berita berdasarkan kata kunci.
  Future<List<ArticleModel>> searchNews(String keyword) {
    final query = keyword.trim();

    if (query.isEmpty) {
      throw ApiException('Kata kunci pencarian tidak boleh kosong.');
    }

    if (query.length > 200) {
      throw ApiException('Kata kunci pencarian maksimal 200 karakter.');
    }

    return _ambilArtikel('search', {'q': query, 'sortby': 'publishedAt'});
  }

  /// Satu pintu untuk seluruh request GNews.
  ///
  /// Semua DioException dan TypeError diterjemahkan
  /// menjadi ApiException sebelum sampai ke UI.
  Future<List<ArticleModel>> _ambilArtikel(
    String path,
    Map<String, dynamic> query,
  ) async {
    // Periksa konfigurasi sebelum melakukan request.
    if (!Env.lengkap) {
      throw ApiException(
        'Konfigurasi belum diisi. Jalankan dengan '
        '--dart-define-from-file=config/env.json',
      );
    }

    try {
      final response = await _dio.get(path, queryParameters: query);

      final data = response.data;

      // Pastikan response berbentuk JSON Map.
      if (data is! Map) {
        throw ApiException('Format data dari server tidak dikenali.');
      }

      final json = Map<String, dynamic>.from(data);

      // GNews seharusnya memberikan daftar articles.
      if (json['articles'] is! List) {
        throw ApiException('Format data dari server tidak dikenali.');
      }

      // Parsing JSON menjadi model artikel.
      return NewsResponseModel.fromJson(json).articles;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw ApiException('Struktur data dari server berbeda dari model.');
    }
  }
}
