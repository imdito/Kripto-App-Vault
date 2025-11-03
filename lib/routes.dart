import 'package:get/get.dart';
import 'package:kripto_app/LoginRegister/login_register_view.dart';
import 'package:kripto_app/LoginRegister/signin_up_controller.dart';
import 'package:kripto_app/fileEncryptPage/file_encrypt_controller.dart';
import 'package:kripto_app/fileEncryptPage/file_encrypt_view.dart';
import 'package:kripto_app/homePage/detailMessage/detail_massage_view.dart';
import 'package:kripto_app/homePage/home_page_view.dart';
import 'package:kripto_app/homePage/home_page_controller.dart';
import 'package:kripto_app/profilePage/editProfile/edit_profile_controller.dart';
import 'package:kripto_app/profilePage/editProfile/edit_profile_view.dart';
import 'package:kripto_app/profilePage/profile_controller.dart';
import 'package:kripto_app/profilePage/profile_view.dart';
import 'package:kripto_app/sendMessage/history/history_controller.dart';
import 'package:kripto_app/sendMessage/history/history_view.dart';
import 'package:kripto_app/sendMessage/send_message_controller.dart';
import 'package:kripto_app/sendMessage/send_message_view.dart';
import 'package:kripto_app/steganoPage/stegano_controller.dart';
import 'package:kripto_app/steganoPage/stegano_view.dart';
import 'package:kripto_app/superEncrypt/super_encrypt_controller.dart';
import 'package:kripto_app/superEncrypt/super_encrypt_view.dart';

import 'homePage/detailMessage/detail_message_controller.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String steganography = '/steganography';
  static const String detailMassage = '/detail-message';
  static const String superEncrypt = '/super-encrypt';
  static const String fileEncrypt = '/file-encrypt';
  static const String sendPage = '/send-page';
  static const String sentHistory = '/sent-history';

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
    GetPage(name: AppRoutes.detailMassage, page: ()=>DetailMassageView(), binding: BindingsBuilder(() {
      Get.lazyPut<DetailMessageController>(() => DetailMessageController());
    }),),
    GetPage(
      name: AppRoutes.superEncrypt, // (Buat rute baru '/crypto')
      page: () => const SuperEncryptView(),
      binding: BindingsBuilder(
        () {
        Get.lazyPut<SuperEncryptController>(() => SuperEncryptController());
        },
      ),
    ),
    GetPage(
      name: AppRoutes.fileEncrypt, // (Buat rute baru '/crypto')
      page: () => const FileEncryptView(),
      binding: BindingsBuilder(
            () {
          Get.lazyPut<FileEncryptController>(() => FileEncryptController());
        },
      ),
    ),
    GetPage(name: AppRoutes.sendPage,
        page: ()=>SendMessageView(),
        binding: BindingsBuilder(
              (){
            Get.lazyPut<SendMessageController>(()=>SendMessageController());
      }
    )),
    GetPage(name: AppRoutes.sentHistory, page:()=> HistoryView(), binding: BindingsBuilder(() {
      Get.lazyPut<HistoryController>(() => HistoryController());
    }),),
  ];
}

