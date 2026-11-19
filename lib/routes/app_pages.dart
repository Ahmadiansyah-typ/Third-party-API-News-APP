import 'package:get/get.dart';

import '../models/article_model.dart';
import '../views/home_view.dart';
import '../views/search_view.dart';
import '../views/detail_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.home;

  static final List<GetPage> routes = [
    GetPage(name: AppRoutes.home, page: () => const HomeView()),

    GetPage(
      name: AppRoutes.search,
      page: () {
        final keyword = Get.parameters['keyword']?.trim() ?? '';

        return SearchView(keyword: keyword);
      },
    ),

    GetPage(
      name: AppRoutes.detail,
      page: () {
        final arguments = Get.arguments;

        return DetailView(
          article: arguments is ArticleModel ? arguments : null,
        );
      },
    ),
  ];
}
