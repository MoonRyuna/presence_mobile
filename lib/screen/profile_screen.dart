import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/screen/hr/manage_karyawan_detail_screen.dart';
import 'package:presence_alpha/screen/login_screen.dart';
import 'package:presence_alpha/screen/ubah_password_screen.dart';
import 'package:presence_alpha/screen/ubah_profile_screen.dart';
import 'package:presence_alpha/storage/app_storage.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? accountType;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    // Call userProvider to get user data and update the userData variable
    user = Provider.of<UserProvider>(context, listen: false).user;
    accountType = user?.accountType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: accountType == "admin" || accountType == "hrd"
          ? AppBar(
              title: const Text("Profile"),
              backgroundColor: ColorConstant.lightPrimary,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              profileInfo(),
              profileActions(context, user: user),
            ],
          ),
        ),
      ),
    );
  }
}

Widget profileInfo() {
  return Stack(
    alignment: Alignment.topCenter,
    children: <Widget>[
      SizedBox(
        height: 240.0,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: <Widget>[
              ClipOval(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, _) => profilePicture(
                    userProvider.user?.profilePicture,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Consumer<UserProvider>(
                builder: (context, userProvider, _) => Text(
                  userProvider.user?.name ?? "N/A",
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Consumer<UserProvider>(
                builder: (context, userProvider, _) => Text(
                  userProvider.user?.accountType ?? "N/A",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget profileActions(BuildContext context, {UserModel? user}) {
  return Column(
    children: <Widget>[
      Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              if (user == null) {
                AmessageUtility.show(
                  context,
                  "Gagal",
                  "Data Profile Tidak Ditemukan",
                  TipType.ERROR,
                );
              } else {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ManageKaryawanDetailScreen(user: user),
                  ),
                );
              }
            },
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: const Text(
              'Ubah Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UbahProfileScreen(),
                ),
              );
            },
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListTile(
            leading: const Icon(Icons.lock),
            title: const Text(
              'Ubah Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UbahPasswordScreen(),
                ),
              );
            },
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppStorage.localStorage.deleteItem("usr");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ),
      ),
    ],
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
