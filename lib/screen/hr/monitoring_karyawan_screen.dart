import 'dart:async';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/payload/data/karyawan_data.dart';
import 'package:presence_alpha/payload/response/list_monitoring_karyawan_response.dart';
import 'package:presence_alpha/payload/response/monitoring_karyawan_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/screen/hr/location_karyawan_screen.dart';
import 'package:presence_alpha/service/user_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:provider/provider.dart';

class MonitoringKaryawanScreen extends StatefulWidget {
  const MonitoringKaryawanScreen({super.key});

  @override
  State<MonitoringKaryawanScreen> createState() =>
      _MonitoringKaryawanScreenState();
}

class _MonitoringKaryawanScreenState extends State<MonitoringKaryawanScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();

  MonitoringKaryawanResponse? _userList;
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
    String? uAccountType =
        Provider.of<UserProvider>(context, listen: false).user?.accountType;

    setState(() {
      _isLoading = true;
    });

    String accountType = "";
    if (uAccountType != null && uAccountType == "hrd") accountType = "karyawan";

    ListMonitoringKaryawanResponse response =
        await _userService.getMonitoringKaryawan(
      date: CalendarUtility.dateNow(),
      name: _searchController.text,
      page: _currentPage,
      limit: 10,
      token: token,
    );

    if (response.status!) {
      MonitoringKaryawanResponse users =
          response.data ?? MonitoringKaryawanResponse();

      print(users.toJsonString());
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
          KaryawanData? user = _userList?.result[index];
          // print(user?.toJsonString());
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
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ClipOval(
                      child: profilePicture(
                        user?.profilePicture,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      onTap: () async {
                        if (user != null) {
                          if (user.checkIn != null) {
                            bool result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationKaryawanScreen(
                                  id: user.userId!,
                                  type: user.type!,
                                  name: user.name!,
                                  profilePicture: user.profilePicture!,
                                  date: CalendarUtility.dateNow(),
                                ),
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
                              "Karyawan belum bisa di monitoring",
                              TipType.ERROR,
                            );
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
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              user?.name ?? '',
                              style: TextStyle(
                                  color: ColorConstant.lightPrimary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              user?.type != null
                                  ? user?.type == "wfo"
                                      ? "WFO (Kantor)"
                                      : "WFH (Jarak Jauh)"
                                  : "Belum Presensi",
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          if (user?.checkIn != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.arrow_circle_down_outlined,
                                  size: 20,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "IN ${CalendarUtility.getTime(
                                    DateTime.parse(user!.checkIn!),
                                  )}",
                                ),
                              ],
                            ),
                          if (user?.checkIn == null)
                            Row(
                              children: const [
                                Icon(
                                  Icons.arrow_circle_down_outlined,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 5),
                                Text("IN -"),
                              ],
                            ),
                          const SizedBox(height: 8, width: 8),
                          if (user?.checkOut != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.arrow_circle_up_outlined,
                                  size: 20,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "OUT ${CalendarUtility.getTime(
                                    DateTime.parse(user!.checkOut!),
                                  )}",
                                ),
                              ],
                            ),
                          if (user?.checkOut == null)
                            Row(
                              children: const [
                                Icon(
                                  Icons.arrow_circle_up_outlined,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 5),
                                Text("OUT -"),
                              ],
                            ),
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
        title: const Text('Pemantauan Karyawan'),
        backgroundColor: ColorConstant.lightPrimary,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
            Container(
              padding: const EdgeInsets.all(4.0),
              width: MediaQuery.of(context).size.width,
              color: Colors.green.withOpacity(0.8),
              child: Center(
                child: Text(
                  CalendarUtility.dateNow2(),
                  style: const TextStyle(color: Colors.white),
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
