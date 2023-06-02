import 'dart:async';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/model/users_model.dart';
import 'package:presence_alpha/payload/response/user_list_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/screen/hr/manage_karyawan_add_screen.dart';
import 'package:presence_alpha/screen/hr/manage_karyawan_detail_screen.dart';
import 'package:presence_alpha/service/user_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:provider/provider.dart';

class ManageKaryawanScreen extends StatefulWidget {
  const ManageKaryawanScreen({super.key});

  @override
  State<ManageKaryawanScreen> createState() => _ManageKaryawanScreenState();
}

class _ManageKaryawanScreenState extends State<ManageKaryawanScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();

  UsersModel? _userList;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  Timer? timeHandle;

  @override
  void initState() {
    super.initState();
    _loadUserList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadUserList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserList() async {
    if (!_hasMore) return;
    if (_isLoading) return;

    final token = Provider.of<TokenProvider>(context, listen: false).token;

    setState(() {
      _isLoading = true;
    });

    UserListResponse response = await _userService.getUserList(
      name: _searchController.text,
      page: _currentPage,
      limit: 10,
      token: token,
    );

    if (response.status!) {
      UsersModel users = response.data ?? UsersModel();
      setState(() {
        // concat user list
        if (_userList != null) {
          _userList!.result.addAll(users.result);
        } else {
          _userList = users;
        }
        _currentPage++;
        _isLoading = false;
        _hasMore = (users.result.length == (response.data?.limit ?? 0));
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _searchUser(String query) async {
    if (timeHandle != null) {
      timeHandle!.cancel();
    }

    timeHandle = Timer(const Duration(seconds: 1), () async {
      setState(() {
        _userList = null;
        _currentPage = 1;
        _hasMore = true;
      });

      await _loadUserList();
    });
  }

  Widget _buildUserList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _userList != null ? _userList!.result.length + 1 : 0,
      itemBuilder: (BuildContext context, int index) {
        if (index < (_userList?.result.length ?? 0)) {
          UserModel? user = _userList?.result[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: const Offset(0.0, 0.5), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0, 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: profilePicture(
                      user?.profilePicture,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      onTap: () {
                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ManageKaryawanDetailScreen(user: user),
                            ),
                          );
                        } else {
                          AmessageUtility.show(
                            context,
                            "Gagal",
                            "Info user tidak diketahui",
                            TipType.ERROR,
                          );
                        }
                      },
                      title: Text(
                        user?.name ?? '',
                        style: TextStyle(
                            color: ColorConstant.lightPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(user?.phoneNumber ?? ""),
                          const SizedBox(height: 8),
                          Text(user?.address ?? ""),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (_hasMore) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karyawan'),
        backgroundColor: ColorConstant.lightPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ManageKaryawanAddScreen()),
          );
        },
        backgroundColor: ColorConstant.lightPrimary,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: ColorConstant.bgOpt,
        ),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _searchUser,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Cari nama karyawan',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Expanded(
              child: _buildUserList(),
            ),
          ],
        ),
      ),
    );
  }
}

Widget profilePicture(String? imagePath) {
  String profilePictureURI =
      "https://sbcf.fr/wp-content/uploads/2018/03/sbcf-default-avatar.png";
  if (imagePath != null) {
    if (imagePath == "images/default.png") {
      profilePictureURI = "${ApiConstant.publicUrl}/$imagePath";
    } else {
      profilePictureURI = "${ApiConstant.baseUrl}/$imagePath";
    }
  }

  return Image.network(
    profilePictureURI,
    width: 50,
    height: 50,
    fit: BoxFit.cover,
  );
}
