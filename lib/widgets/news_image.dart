import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class NewsImage extends StatelessWidget {
  final String? url;
  final double height;

  const NewsImage({super.key, required this.url, this.height = 190});

  Widget _placeholder() {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.background,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _errorWidget() {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.background,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return _errorWidget();
    }

    if (kIsWeb) {
      return Image.network(
        url!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,

        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,

        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder();
        },

        errorBuilder: (context, error, stackTrace) {
          return _errorWidget();
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,

      placeholder: (context, url) {
        return _placeholder();
      },

      errorWidget: (context, url, error) {
        return _errorWidget();
      },
    );
  }
}
