import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/screen/jatah_cuti_tahunan_screen.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
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
          actions: [
            user.accountType == "karyawan"
                ? PopupMenuButton(
                    onSelected: (value) {
                      if (value == "jatah_cuti_tahunan") {
                        if (user.id != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  JatahCutiTahunanScreen(id: user.id!),
                            ),
                          );
                        } else {
                          AmessageUtility.show(
                            context,
                            "Gagal",
                            "User ID tidak ditemukan",
                            TipType.ERROR,
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "jatah_cuti_tahunan",
                        child: Row(
                          children: const [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Jatah Cuti Tahunan",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
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
        height: 100,
        fit: BoxFit.cover,
      );
    }

    String profilePictureURI = "${ApiConstant.baseUrl}/$imagePath";

    return SizedBox(
      width: 100,
      height: 100,
      child: CachedNetworkImage(
        imageUrl: profilePictureURI,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/default.png',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        fit: BoxFit.cover,
      ),
    );
  }
}
