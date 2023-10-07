import 'dart:async';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/model/users_model.dart';
import 'package:presence_alpha/payload/response/user_list_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/screen/hr/manage_karyawan_add_screen.dart';
import 'package:presence_alpha/screen/hr/manage_karyawan_detail_screen.dart';
import 'package:presence_alpha/screen/hr/manage_karyawan_edit_screen.dart';
import 'package:presence_alpha/screen/rekap_karyawan_screen.dart';
import 'package:presence_alpha/service/user_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
    String? uAccountType =
        Provider.of<UserProvider>(context, listen: false).user?.accountType;

    setState(() {
      _isLoading = true;
    });

    String accountType = "";
    if (uAccountType != null && uAccountType == "hrd") accountType = "karyawan";

    UserListResponse response = await _userService.getUserList(
      name: _searchController.text,
      page: _currentPage,
      limit: 10,
      accountType: accountType,
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

  Future<void> _onResetDeviceUnique(String id) async {
    bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text(
              "Apakah anda yakin ingin mereset device_unique perangkat karyawan ini?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );

    if (isConfirmed == null || isConfirmed == false) {
      return;
    }

    LoadingUtility.show(null);

    final token = Provider.of<TokenProvider>(context, listen: false).token;

    if (!mounted) return;
    try {
      final requestData = {
        "user_id": id,
      };

      final response =
          await UserService().resetDeviceUnique(requestData, token);
      if (!mounted) return;

      if (response.status != true || response.data == null) {
        LoadingUtility.hide();
        AmessageUtility.show(
          context,
          "Gagal",
          response.message!,
          TipType.ERROR,
        );
        return;
      }

      LoadingUtility.hide();
      AmessageUtility.show(
        context,
        "Berhasil",
        response.message!,
        TipType.COMPLETE,
      );
    } catch (e) {
      LoadingUtility.hide();
      AmessageUtility.show(
        context,
        "Gagal",
        e.toString(),
        TipType.ERROR,
      );
    }
  }

  Future<void> _onDeleteUser(String id, int index) async {
    bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content:
              const Text("Apakah anda yakin ingin menghapus karyawan ini?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );

    if (isConfirmed == null || isConfirmed == false) {
      return;
    }

    LoadingUtility.show(null);

    final user = Provider.of<UserProvider>(context, listen: false).user;
    final token = Provider.of<TokenProvider>(context, listen: false).token;

    if (!mounted) return;
    if (user == null || user.id == null) {
      LoadingUtility.hide();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return;
    }

    try {
      final requestData = {
        "deleted_by": user.id,
      };

      final response = await UserService().deleteUser(requestData, id, token);
      if (!mounted) return;

      if (response.status != true || response.data == null) {
        LoadingUtility.hide();
        AmessageUtility.show(
          context,
          "Gagal",
          response.message!,
          TipType.ERROR,
        );
        return;
      }

      LoadingUtility.hide();
      AmessageUtility.show(
        context,
        "Berhasil",
        response.message!,
        TipType.COMPLETE,
      );

      setState(() {
        _userList?.result.removeAt(index);
      });
    } catch (e) {
      LoadingUtility.hide();
      AmessageUtility.show(
        context,
        "Gagal",
        e.toString(),
        TipType.ERROR,
      );
    }
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
            child: Slidable(
              startActionPane: ActionPane(
                motion: const BehindMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      if (user != null && user.id != null) {
                        await _onResetDeviceUnique(user.id!);
                      } else {
                        AmessageUtility.show(
                          context,
                          "Gagal",
                          "Info user tidak diketahui",
                          TipType.ERROR,
                        );
                      }
                    },
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.refresh,
                    label: 'Reset DEVICE UNIQUE',
                  ),
                  SlidableAction(
                    onPressed: (context) async {
                      if (user != null) {
                        bool result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ManageKaryawanEditScreen(user: user),
                          ),
                        );

                        if (result) {
                          setState(() {
                            _userList = null;
                            _currentPage = 1;
                            _hasMore = true;
                          });

                          await _loadUserList();
                        }
                      } else {
                        AmessageUtility.show(
                          context,
                          "Gagal",
                          "Info user tidak diketahui",
                          TipType.ERROR,
                        );
                      }
                    },
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      if (user != null && user.id != null) {
                        await _onDeleteUser(user.id!, index);
                      } else {
                        AmessageUtility.show(
                          context,
                          "Gagal",
                          "Info user tidak diketahui",
                          TipType.ERROR,
                        );
                      }
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                  if (user != null &&
                      user.accountType != null &&
                      user.accountType?.toLowerCase() == "karyawan")
                    SlidableAction(
                      onPressed: (context) async {
                        if (user != null && user.id != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RekapKaryawanScreen(id: user.id!),
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
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      icon: Icons.data_thresholding_outlined,
                      label: 'Rekap',
                    ),
                ],
              ),
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
                        onTap: () async {
                          if (user != null) {
                            bool result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ManageKaryawanDetailScreen(user: user),
                              ),
                            );

                            if (result) {
                              setState(() {
                                _userList = null;
                                _currentPage = 1;
                                _hasMore = true;
                              });

                              await _loadUserList();
                            }
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () async {
              bool result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageKaryawanAddScreen(),
                ),
              );

              if (result) {
                setState(() {
                  _userList = null;
                  _currentPage = 1;
                  _hasMore = true;
                });

                await _loadUserList();
              }
            },
            backgroundColor: ColorConstant.lightPrimary,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () async {
              setState(() {
                _userList = null;
                _currentPage = 1;
                _hasMore = true;
              });

              await _loadUserList();
            },
            heroTag: "btnRefresh",
            backgroundColor: ColorConstant.lightPrimary,
            child: const Icon(Icons.refresh),
          ),
        ],
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
  if (imagePath == null) {
    return Image.asset(
      'assets/images/default.png',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  String profilePictureURI = "${ApiConstant.baseUrl}/$imagePath";

  return SizedBox(
    width: 50,
    height: 50,
    child: CachedNetworkImage(
      imageUrl: profilePictureURI,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/default.png',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      fit: BoxFit.cover,
    ),
  );
}
