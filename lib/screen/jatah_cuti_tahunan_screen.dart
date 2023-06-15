import 'dart:async';

import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/jatah_cuti_tahunan_model.dart';
import 'package:presence_alpha/payload/response/user/list_jatah_cuti_tahunan_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/service/user_service.dart';
import 'package:provider/provider.dart';

class JatahCutiTahunanScreen extends StatefulWidget {
  final String id;

  const JatahCutiTahunanScreen({super.key, required this.id});

  @override
  State<JatahCutiTahunanScreen> createState() => _JatahCutiTahunanScreenState();
}

class _JatahCutiTahunanScreenState extends State<JatahCutiTahunanScreen> {
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();

  List<JatahCutiTahunanModel>? _listJatahCutiTahunan = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int limit = 10;
  int page = 1;
  Timer? timeHandle;

  @override
  void initState() {
    super.initState();
    _loadListJatahCutiTahunan();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadListJatahCutiTahunan();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadListJatahCutiTahunan() async {
    if (!_hasMore) return;
    if (_isLoading) return;

    final token = Provider.of<TokenProvider>(context, listen: false).token;

    setState(() {
      _isLoading = true;
    });

    final queryParams = {
      "limit": limit.toString(),
      "page": page.toString(),
      "user_id": widget.id,
    };

    ListJatahCutiTahunanResponse response =
        await _userService.listJatahCutiTahunanResponse(queryParams, token);

    if (response.status!) {
      List<JatahCutiTahunanModel> jatahCutiTahunan =
          response.data?.result ?? [];
      setState(() {
        // concat user list
        if (_listJatahCutiTahunan != null) {
          _listJatahCutiTahunan!.addAll(jatahCutiTahunan);
        } else {
          _listJatahCutiTahunan = jatahCutiTahunan;
        }
        page++;
        _isLoading = false;
        _hasMore = (jatahCutiTahunan.length == (response.data?.limit ?? 0));
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  Widget _buildListJatahCutiTahunan() {
    return ListView.builder(
      controller: _scrollController,
      itemCount:
          _listJatahCutiTahunan != null ? _listJatahCutiTahunan!.length + 1 : 0,
      itemBuilder: (BuildContext context, int index) {
        if (index < (_listJatahCutiTahunan?.length ?? 0)) {
          JatahCutiTahunanModel? jatahCutiTahunan =
              _listJatahCutiTahunan?[index];
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
              child: ListTile(
                title: Text(
                  jatahCutiTahunan?.name ?? '',
                  style: TextStyle(
                      color: ColorConstant.lightPrimary,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text("Jatah Cuti Tahun ${jatahCutiTahunan?.year}" ?? ""),
                    const SizedBox(height: 8),
                    Text("Sisa ${jatahCutiTahunan?.annualLeave ?? ""}"),
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
        title: const Text('Jatah Cuti'),
        backgroundColor: ColorConstant.lightPrimary,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () async {
              setState(() {
                _listJatahCutiTahunan = null;
                page = 1;
                _hasMore = true;
              });

              await _loadListJatahCutiTahunan();
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
        child: _buildListJatahCutiTahunan(),
      ),
    );
  }
}
