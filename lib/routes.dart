import 'package:get/get.dart';
import 'package:kripto_app/LoginRegister/login_register_view.dart';
import 'package:kripto_app/LoginRegister/signin_up_controller.dart';
import 'package:kripto_app/homePage/home_page_view.dart';
import 'package:kripto_app/homePage/home_page_controller.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => Registerview(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SignInUpController>(() => SignInUpController());
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePageView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomePageController>(() => HomePageController());
      }),
    ),
  ];
}

