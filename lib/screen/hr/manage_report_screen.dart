import 'dart:io';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/report_model.dart';
import 'package:presence_alpha/payload/response/base_response.dart';
import 'package:presence_alpha/payload/response/report/download_response.dart';
import 'package:presence_alpha/payload/response/report/list_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/screen/hr/manage_report_add_screen.dart';
import 'package:presence_alpha/service/report_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';

class ManageReportScreen extends StatefulWidget {
  const ManageReportScreen({super.key});

  @override
  State<ManageReportScreen> createState() => _ManageReportScreenState();
}

class _ManageReportScreenState extends State<ManageReportScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  List<ReportModel> reports = List<ReportModel>.empty();

  int limit = 10;
  int page = 1;
  String savePath = '/storage/emulated/0/Download/';
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
        primary: Color.fromRGBO(183, 28, 28, 1),
        onPrimary: Colors.white,
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
        reports = List<ReportModel>.empty();
        page = 1;
        firstLoad = true;
        endOfList = false;
      });
      loadData();
    }
  }

  void _onRefresh() async {
    setState(() {
      reports = List<ReportModel>.empty();
      page = 1;
      firstLoad = true;
      endOfList = false;
    });
    loadData();
  }

  void _addReport() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageReportAddScreen()),
    );
    if (result == true) {
      _onRefresh();
    }
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
    };

    if (firstLoad == false &&
        loadMoreRunning == false &&
        endOfList == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        loadMoreRunning = true;
      });

      ListResponse response = await ReportService().list(queryParams, token);
      if (!mounted) return;

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            reports = [...reports, ...?response.data?.result];
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
      ListResponse response = await ReportService().list(queryParams, token);
      if (!mounted) return;

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            reports = response.data!.result;
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

  Future<void> _generateReport(ReportModel report) async {
    LoadingUtility.show(null);

    final token = Provider.of<TokenProvider>(context, listen: false).token;

    try {
      BaseResponse response = await ReportService().generate(report.id!, token);

      if (!mounted) return;

      if (response.status != true) {
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

  Future<void> downloadFile(String url, String savePath) async {
    final response = await http.get(Uri.parse(url));

    final file = File(savePath);
    await file.writeAsBytes(response.bodyBytes);
  }

  Future<void> _downloadReport(ReportModel report) async {
    LoadingUtility.show(null);

    final token = Provider.of<TokenProvider>(context, listen: false).token;

    try {
      DownloadResponse response =
          await ReportService().download(report.id!, token);

      if (!mounted) return;

      if (response.status != true) {
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

      var url = ApiConstant.baseUrl + response.data!.url!;
      var filename = url.substring(url.lastIndexOf("/") + 1);
      await downloadFile(url, savePath + filename);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Bulanan'),
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
                      condition: reports.isNotEmpty,
                      builder: (context) => ListView.builder(
                        padding: const EdgeInsets.only(top: 7.0),
                        controller: _controller,
                        itemCount: reports.length,
                        itemBuilder: (BuildContext context, int index) {
                          final report = reports[index];

                          final title = report.title ?? '';

                          final totalEmployee = report.totalEmployee ?? 0;

                          final reportDate =
                              DateTime.parse(report.endDate ?? '');
                          final date =
                              DateFormat('MMMM yyyy', 'id').format(reportDate);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 0,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: ListTile(
                                title: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2.0),
                                    Text(
                                      date,
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      "Total Karyawan: $totalEmployee",
                                      style: TextStyle(
                                        color: Colors.grey.shade900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  onSelected: (result) async {
                                    switch (result) {
                                      case "generate":
                                        await _generateReport(report);
                                        break;
                                      case "download":
                                        await _downloadReport(report);
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry>[
                                    const PopupMenuItem(
                                      value: "generate",
                                      child: Text('Generate'),
                                    ),
                                    const PopupMenuItem(
                                      value: "download",
                                      child: Text("Download"),
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
            onPressed: _addReport,
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
