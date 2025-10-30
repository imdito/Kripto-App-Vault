import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_register_view.dart';

class SignInUpController extends GetxController {
  var isLoading = false.obs;

  void signIn(String email, String password) {
    isLoading.value = true;
    // Implement sign in logic
    isLoading.value = false;
  }

  void signUp(String email, String password, String confirmPassword) {
    isLoading.value = true;
    // Implement sign up logic
    isLoading.value = false;
  }
}

