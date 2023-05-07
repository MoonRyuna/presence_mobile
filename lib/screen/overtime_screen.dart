import 'dart:convert';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/overtime_model.dart';
import 'package:presence_alpha/payload/response/overtime/list_response.dart';
import 'package:presence_alpha/payload/test_overtime.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/screen/overtime_add_screen.dart';
import 'package:presence_alpha/service/overtime_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:provider/provider.dart';

class OvertimeScreen extends StatefulWidget {
  const OvertimeScreen({super.key});

  @override
  State<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  List<OvertimeModel> overtimes = List<OvertimeModel>.empty();

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
        overtimes = List<OvertimeModel>.empty();
        page = 1;
        firstLoad = true;
        endOfList = false;
      });
      loadData();
    }
  }

  void _addOvertime() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OvertimeAddScreen()),
    );
  }

  void _cancelOvertime(Overtime overtime) {
    // TODO: implement cancelOvertime
  }

  void loadData() async {
    final tp = Provider.of<TokenProvider>(
      context,
      listen: false,
    );
    final up = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    String? userId = up.user?.id;
    String token = tp.token;

    final queryParams = {
      "user_id": userId.toString(),
      "start_date": CalendarUtility.formatDB2(_startDate),
      "end_date": CalendarUtility.formatDB2(_endDate),
      "limit": limit.toString(),
      "page": page.toString(),
      "order": "overtime_at:desc"
    };

    print("Query Before Send ${jsonEncode(queryParams)}");

    if (firstLoad == false &&
        loadMoreRunning == false &&
        endOfList == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        loadMoreRunning = true;
      });

      ListResponse response = await OvertimeService().list(queryParams, token);
      if (!mounted) return;
      print(response.toJsonString());

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            overtimes = [...overtimes, ...?response.data?.result];
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
      ListResponse response = await OvertimeService().list(queryParams, token);
      if (!mounted) return;
      print(response.toJsonString());

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            overtimes = response.data!.result;
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
        title: const Text('Lembur'),
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
                      condition: overtimes.isNotEmpty,
                      builder: (context) => ListView.builder(
                        padding: const EdgeInsets.only(top: 7.0),
                        controller: _controller,
                        itemCount: overtimes.length,
                        itemBuilder: (BuildContext context, int index) {
                          final overtime = overtimes[index];
                          final overtimeStatusText = {
                            "0": "Pending",
                            "1": "Approved",
                            "2": "Rejected",
                            "3": "Canceled",
                            "4": "Expired",
                          }[overtime.overtimeStatus];

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
                                title: Text(overtime.user!.name!),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2.0),
                                    Text(
                                      overtime.desc != null &&
                                              overtime.desc!.length > 40
                                          ? '${overtime.desc!.substring(0, 40)}...'
                                          : overtime.desc ?? '',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      "Lembur pada ${DateFormat.yMMMd().format(DateTime.parse(overtime.overtimeAt!))}",
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      "Status: $overtimeStatusText",
                                      style: TextStyle(
                                        color: overtime.overtimeStatus == "1"
                                            ? Colors.green
                                            : (overtime.overtimeStatus == "2" ||
                                                    overtime.overtimeStatus ==
                                                        "3")
                                                ? Colors.red
                                                : null,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry>[
                                    const PopupMenuItem(
                                      child: Text('Batalkan'),
                                    ),
                                    const PopupMenuItem(
                                      child: Text('Detail'),
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
          FloatingActionButton(
            onPressed: _addOvertime,
            heroTag: "btnAdd",
            backgroundColor: ColorConstant.lightPrimary,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _openDatePicker,
            heroTag: "btnDatePicker",
            backgroundColor: ColorConstant.lightPrimary,
            child: const Icon(Icons.date_range),
          ),
        ],
      ),
    );
  }
}
