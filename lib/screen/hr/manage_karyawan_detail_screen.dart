import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:provider/provider.dart';

class ManageKaryawanDetailScreen extends StatelessWidget {
  const ManageKaryawanDetailScreen({Key? key, required this.user})
      : super(key: key);

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          title: const Text("Detail Karyawan"),
          backgroundColor: ColorConstant.lightPrimary,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: 200.0,
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: <Widget>[
                      ClipOval(
                        child: user.profilePicture != null
                            ? profilePicture(user.profilePicture)
                            : Consumer<UserProvider>(
                                builder: (context, userProvider, _) =>
                                    profilePicture(
                                        userProvider.user?.profilePicture),
                              ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        "@${user.username ?? ""}",
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: <Widget>[
                      buildCard("Nama", user.name),
                      buildCard("Email", user.email),
                      buildCard("Jabatan", user.accountType),
                      buildCard("Alamat", user.address),
                      buildCard("No. HP", user.phoneNumber),
                      buildCard("Tentang", user.description),
                      buildCard(
                        "Bisa Remote",
                        (user.canWfh ?? false) ? "Ya" : "Tidak",
                      ),
                      buildCard(
                        "Bergabung Sejak",
                        DateFormat("d MMMM y").format(
                          DateTime.parse(user.startedWorkAt ?? "").toLocal(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard(String title, String? subtitle) {
    return Card(
      elevation: 0,
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle ?? ""),
      ),
    );
  }

  Widget profilePicture(String? imagePath) {
    if (imagePath == null) {
      return Image.asset(
        'assets/images/default.png',
        width: 100,
      );
    }

    String profilePictureURI = "${ApiConstant.baseUrl}/$imagePath";

    return Image.network(
      profilePictureURI,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/default.png',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
