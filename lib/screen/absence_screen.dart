import 'dart:convert';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/absence_model.dart';
import 'package:presence_alpha/payload/response/absence/cancel_response.dart';
import 'package:presence_alpha/payload/response/absence/list_response.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/screen/absence_add_screen.dart';
import 'package:presence_alpha/screen/absence_detail_screen.dart';
import 'package:presence_alpha/service/absence_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:presence_alpha/widget/bs_badge.dart';
import 'package:provider/provider.dart';

class AbsenceScreen extends StatefulWidget {
  const AbsenceScreen({super.key});

  @override
  State<AbsenceScreen> createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  List<AbsenceModel> absences = List<AbsenceModel>.empty();

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
        absences = List<AbsenceModel>.empty();
        page = 1;
        firstLoad = true;
        endOfList = false;
      });
      loadData();
    }
  }

  void _onRefresh() async {
    setState(() {
      absences = List<AbsenceModel>.empty();
      page = 1;
      firstLoad = true;
      endOfList = false;
    });
    loadData();
  }

  void _addAbsence() async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AbsenceAddScreen()));
    if (result == true) {
      _onRefresh();
    }
  }

  void _cancelAbsence(AbsenceModel absence) async {
    try {
      bool isConfirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Konfirmasi"),
            content: const Text(
                "Anda yakin membatalkan pengajuan yang sudah di approve?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Lanjut"),
              ),
            ],
          );
        },
      );
      if (isConfirmed == true) {
        if (!mounted) return;
        LoadingUtility.show("Sedang Proses");
        final tp = Provider.of<TokenProvider>(
          context,
          listen: false,
        );

        String token = tp.token;

        final requestData = {'absence_id': absence.id};

        CancelResponse response =
            await AbsenceService().cancel(requestData, token);
        if (!mounted) return;
        print(response.toJsonString());

        if (response.status == true) {
          AmessageUtility.show(
            context,
            "Berhasil",
            response.message!,
            TipType.COMPLETE,
          );
        } else {
          AmessageUtility.show(
            context,
            "Gagal",
            response.message!,
            TipType.ERROR,
          );
        }
      }
    } catch (error) {
      print('Error: $error');

      AmessageUtility.show(context, "Gagal", error.toString(), TipType.ERROR);
    } finally {
      _onRefresh();
      LoadingUtility.hide();
    }
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
      "start_date": "${CalendarUtility.formatDB3(_startDate)} 00:00:00",
      "end_date": "${CalendarUtility.formatDB3(_endDate)} 23:59:59",
      "limit": limit.toString(),
      "page": page.toString(),
      "order": "absence_at:desc"
    };

    print("Query Before Send ${jsonEncode(queryParams)}");

    if (firstLoad == false &&
        loadMoreRunning == false &&
        endOfList == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        loadMoreRunning = true;
      });

      ListResponse response = await AbsenceService().list(queryParams, token);
      if (!mounted) return;
      print(response.toJsonString());

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            absences = [...absences, ...?response.data?.result];
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
      ListResponse response = await AbsenceService().list(queryParams, token);
      if (!mounted) return;
      print(response.toJsonString());

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            absences = response.data!.result;
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
        title: const Text('Izin'),
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
                      condition: absences.isNotEmpty,
                      builder: (context) => ListView.builder(
                        padding: const EdgeInsets.only(top: 7.0),
                        controller: _controller,
                        itemCount: absences.length,
                        itemBuilder: (BuildContext context, int index) {
                          final absence = absences[index];
                          final absenceStatusText = {
                            "0": "Pending",
                            "1": "Approved",
                            "2": "Rejected",
                            "3": "Canceled",
                            "4": "Expired",
                          }[absence.absenceStatus];

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
                                  absence.user!.name!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2.0),
                                    Text(
                                      absence.desc != null &&
                                              absence.desc!.length > 35
                                          ? '${absence.desc!.substring(0, 35)}...'
                                          : absence.desc ?? '',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      "${absence.absenceType!.name!} ${absence.cutAnnualLeave! ? "(potong cuti)" : ""}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      CalendarUtility.formatDate(
                                          DateTime.parse(absence.absenceAt!)
                                              .toLocal()),
                                      style: TextStyle(
                                        color: Colors.grey.shade900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    BsBadge(
                                      text: absenceStatusText!,
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                      backgroundColor: (absence
                                                  .absenceStatus! ==
                                              "0"
                                          ? Colors.blue
                                          : absence.absenceStatus! == "1"
                                              ? Colors.green
                                              : (absence.absenceStatus! ==
                                                          "2" ||
                                                      absence.absenceStatus! ==
                                                          "3")
                                                  ? Colors.red
                                                  : Colors.grey),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 4.0,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  onSelected: (result) async {
                                    debugPrint(result);
                                    if (result == "detail") {
                                      bool result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AbsenceDetailScreen(
                                            id: absence.id.toString(),
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _onRefresh();
                                      }
                                    } else if (result == "batalkan") {
                                      _cancelAbsence(absence);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry>[
                                    if (absence.absenceStatus == "1")
                                      const PopupMenuItem(
                                        value: "batalkan",
                                        child: Text('Batalkan'),
                                      ),
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
          FloatingActionButton(
            onPressed: _addAbsence,
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
