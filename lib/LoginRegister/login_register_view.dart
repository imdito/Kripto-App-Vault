import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kripto_app/LoginRegister/signin_up_controller.dart';

class Registerview extends StatelessWidget {
  final loginemailC = TextEditingController();
  final regisemailC = TextEditingController();
  final loginpasswordC = TextEditingController();
  final regispasswordC = TextEditingController();
  final regisconfirmPasswordC = TextEditingController();
  final regisusernameC = TextEditingController();
  final controller = Get.put(SignInUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kripto App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white70
          ),
        ),
        centerTitle: true,
        toolbarHeight: 159,
        backgroundColor: Color(0xFF117f4e),
      ),
      body: Center(
        child: SafeArea(
          child: SizedBox(
            width: 280,
            child: Column(
              children: [
                SizedBox(height: 40),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: MaterialStateProperty.resolveWith<
                              Color?>((Set<MaterialState> states) {
                            return Colors.transparent;
                          }),
                          tabs: [
                            Tab(child: Text("Masuk")),
                            Tab(child: Text("Daftar")),
                          ],
                        ),
                        Expanded(

                          child: TabBarView(
                            children: [
                              SingleChildScrollView(
                                key: PageStorageKey('tab-masuk'),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20),
                                      Text(
                                        "Masuk",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(height: 40),
                                      TextField(
                                        controller: loginemailC,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Email',
                                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      TextField(
                                        controller: loginpasswordC,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Sandi',
                                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Container(
                                        width: double.infinity,
                                        child: TextButton(
                                          onPressed: () {
                                            final email = loginemailC.text;
                                            final password = loginpasswordC.text;
                                            if (!GetUtils.isEmail(email)) {
                                              Get.snackbar(
                                                "Login Gagal",
                                                "Format email yang Anda masukkan tidak valid.",
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                              );
                                            } else if (password.isEmpty) {
                                              Get.snackbar(
                                                "Login Gagal",
                                                "Password tidak boleh kosong.",
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                              );
                                            } else {
                                              controller.signIn(
                                                loginemailC.text,
                                                loginpasswordC.text,
                                              );
                                            }
                                          },
                                          child: Text(
                                            "Masuk",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Color.fromRGBO(
                                              1,
                                              130,
                                              65,
                                              1.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                6,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                key: PageStorageKey('tab-daftar'),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20),
                                      Text(
                                        "Daftar Akun",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(height: 40),
                                      TextField(
                                        controller: regisusernameC,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'username',
                                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      TextField(
                                        controller: regisemailC,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Email',
                                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      TextField(
                                        controller: regispasswordC,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Password',
                                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      TextField(
                                        controller: regisconfirmPasswordC,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Confirm Password',
                                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Container(
                                        width: double.infinity,
                                        child: TextButton(
                                          onPressed: () {
                                            final email = regisemailC.text;
                                            final password = regispasswordC.text;
                                            final confirmPassword =
                                                regisconfirmPasswordC.text;
                                            if (!GetUtils.isEmail(email)) {
                                              Get.snackbar(
                                                "Registrasi Gagal",
                                                "Format email yang Anda masukkan tidak valid.",
                                                snackPosition:
                                                SnackPosition.BOTTOM,
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                              );
                                            } else if (password !=
                                                confirmPassword) {
                                              Get.snackbar(
                                                "Registrasi Gagal",
                                                "Password dan Konfirmasi Password tidak sama.",
                                                snackPosition:
                                                SnackPosition.BOTTOM,
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                              );
                                            } else {
                                              controller.signUp(
                                                regisemailC.text,
                                                regisusernameC.text,
                                                regispasswordC.text,
                                                regisconfirmPasswordC.text,
                                              );
                                            }
                                          },
                                          child: Text(
                                            "Daftar",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Color.fromRGBO(
                                              1,
                                              130,
                                              65,
                                              1.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                6,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

