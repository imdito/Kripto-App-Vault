import 'package:get/get.dart';
import 'package:kripto_app/LoginRegister/login_register_view.dart';
import 'package:kripto_app/LoginRegister/signin_up_controller.dart';
import 'package:kripto_app/homePage/detail_massage_view.dart';
import 'package:kripto_app/homePage/home_page_view.dart';
import 'package:kripto_app/homePage/home_page_controller.dart';
import 'package:kripto_app/profilePage/editProfile/edit_profile_controller.dart';
import 'package:kripto_app/profilePage/editProfile/edit_profile_view.dart';
import 'package:kripto_app/profilePage/profile_controller.dart';
import 'package:kripto_app/profilePage/profile_view.dart';
import 'package:kripto_app/steganoPage/stegano_controller.dart';
import 'package:kripto_app/steganoPage/stegano_view.dart';
import 'package:kripto_app/superEncrypt/super_encrypt_controller.dart';
import 'package:kripto_app/superEncrypt/super_encrypt_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String steganography = '/steganography';
  static const String detailMassage = '/detail-massage';
  static const String superEncrypt = '/super-encrypt';

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
      page: () => HomePageView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomePageController>(() => HomePageController());
      }),
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileView(),
      binding: BindingsBuilder(
        () {
          Get.lazyPut<ProfileController>(() => ProfileController());
        },
      ),
    ),
    GetPage(
      name: AppRoutes.editProfile, // (misal: '/edit-profile')
      page: () => EditProfileView(),
      binding: BindingsBuilder(
        () {
          Get.lazyPut<EditProfileController>(() => EditProfileController());
        },
      ),
      transition: Transition.rightToLeft, // Transisi
    ),
    GetPage(
      name: AppRoutes.steganography,
      page: () => SteganographyView(),
      binding: BindingsBuilder(
        () {
          Get.lazyPut<SteganographyController>(() => SteganographyController());
        },
      ),
    ),
    GetPage(name: AppRoutes.detailMassage, page: ()=>DetailMassageView()),
    GetPage(
      name: AppRoutes.superEncrypt, // (Buat rute baru '/crypto')
      page: () => const SuperEncryptView(),
      binding: BindingsBuilder(
        () {
        Get.lazyPut<SuperEncryptController>(() => SuperEncryptController());
        },
      ),
    ),
  ];
}

