import 'dart:convert';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/presence_model.dart';
import 'package:presence_alpha/payload/response/presence/list_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/service/presence_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/widget/bs_badge.dart';
import 'package:provider/provider.dart';

class ManagePresenceScreen extends StatefulWidget {
  const ManagePresenceScreen({super.key});

  @override
  State<ManagePresenceScreen> createState() => _ManagePresenceScreenState();
}

class _ManagePresenceScreenState extends State<ManagePresenceScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  List<PresenceModel> presences = List<PresenceModel>.empty();

  int limit = 10;
  int page = 1;
  bool firstLoad = true;
  bool endOfList = false;
  bool loadMoreRunning = false;
  bool firstLoadRunning = false;

  late ScrollController _controller;

  void _openDatePicker() async {
    final DateTime currentDate = DateTime.now();
    final DateTime firstDate =
        currentDate.subtract(const Duration(days: 365 * 5));
    final DateTime lastDate = currentDate.add(const Duration(days: 365 * 5));
    final ThemeData theme = ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color.fromRGBO(183, 28, 28, 1), // ubah warna header
        onPrimary: Colors.white, // ubah warna teks header
      ),
    );

    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );
    if (pickedDateRange != null &&
        pickedDateRange != DateTimeRange(start: _startDate, end: _endDate)) {
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
        presences = List<PresenceModel>.empty();
        page = 1;
        firstLoad = true;
        endOfList = false;
      });
      loadData();
    }
  }

  void _onRefresh() async {
    setState(() {
      presences = List<PresenceModel>.empty();
      page = 1;
      firstLoad = true;
      endOfList = false;
    });
    loadData();
  }

  void loadData() async {
    final tp = Provider.of<TokenProvider>(
      context,
      listen: false,
    );

    String token = tp.token;

    final queryParams = {
      "start_date": "${CalendarUtility.formatDB3(_startDate)} 00:00:00",
      "end_date": "${CalendarUtility.formatDB3(_endDate)} 23:59:59",
      "limit": limit.toString(),
      "page": page.toString(),
      "order": "check_in:desc"
    };

    print("Query Before Send ${jsonEncode(queryParams)}");

    if (firstLoad == false &&
        loadMoreRunning == false &&
        endOfList == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        loadMoreRunning = true;
      });

      ListResponse response = await PresenceService().list(queryParams, token);
      if (!mounted) return;
      print(response.toJsonString());

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            presences = [...presences, ...?response.data?.result];
          }

          if (response.data!.nextPage == 0) {
            endOfList = true;
          } else {
            endOfList = false;
            page = response.data!.nextPage;
          }

          loadMoreRunning = false;
        });
      } else {
        AmessageUtility.show(
          context,
          "Gagal",
          response.message!,
          TipType.ERROR,
        );
      }
    }

    if (firstLoad == true) {
      setState(() {
        firstLoadRunning = true;
      });
      ListResponse response = await PresenceService().list(queryParams, token);
      if (!mounted) return;
      print(response.toJsonString());

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            presences = response.data!.result;
          }

          if (response.data!.nextPage == 0) {
            endOfList = true;
          } else {
            endOfList = false;
            page = response.data!.nextPage;
          }
          firstLoad = false;
          firstLoadRunning = false;
        });
      } else {
        AmessageUtility.show(
          context,
          "Gagal",
          response.message!,
          TipType.ERROR,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(const Duration(days: 7));
    _endDate = DateTime.now();

    loadData();
    _controller = ScrollController()..addListener(loadData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kehadiran'),
        centerTitle: true,
        backgroundColor: ColorConstant.lightPrimary,
        elevation: 0,
      ),
      body: Container(
        color: ColorConstant.bgOpt,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range),
                      const SizedBox(width: 5),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: firstLoadRunning
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ConditionalBuilder(
                      condition: presences.isNotEmpty,
                      builder: (context) => ListView.builder(
                        padding: const EdgeInsets.only(top: 7.0),
                        controller: _controller,
                        itemCount: presences.length,
                        itemBuilder: (BuildContext context, int index) {
                          final presence = presences[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 0),
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
                              child: ListTile(
                                title: Text(
                                  presence.user!.name!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6.0),
                                    Text(
                                      CalendarUtility.formatDate(
                                          DateTime.parse("2023-01-02")),
                                      style: TextStyle(
                                        color: Colors.grey.shade900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Row(
                                      children: const [
                                        BsBadge(
                                          text: "IN 08:00:00",
                                          textStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                          backgroundColor: (Colors.green),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 4.0,
                                          ),
                                        ),
                                        SizedBox(width: 4.0),
                                        BsBadge(
                                          text: "OUT -",
                                          textStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                          backgroundColor: (Colors.red),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 4.0,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  onSelected: (result) async {
                                    debugPrint(result);
                                    if (result == "detail") {
                                      // bool result = await Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         PresenceDetailScreen(
                                      //       id: presence.id.toString(),
                                      //     ),
                                      //   ),
                                      // );
                                      // if (result == true) {
                                      //   _onRefresh();
                                      // }
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry>[
                                    const PopupMenuItem(
                                      value: "detail",
                                      child: Text("Detail"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      fallback: (context) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.air, size: 80),
                          SizedBox(height: 16),
                          Text(
                            "Belum Ada Data",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
            ),
            if (loadMoreRunning == true)
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (endOfList == true)
              Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                color: ColorConstant.bgOpt,
                child: const Center(
                  child: Text('You have fetched all of the content'),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _openDatePicker,
            heroTag: "btnDatePicker",
            backgroundColor: ColorConstant.lightPrimary,
            child: const Icon(Icons.date_range),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _onRefresh,
            heroTag: "btnRefresh",
            backgroundColor: ColorConstant.lightPrimary,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
