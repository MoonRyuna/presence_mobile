import 'dart:ffi';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/overtime_model.dart';
import 'package:presence_alpha/model/submission_model.dart';
import 'package:presence_alpha/payload/response/overtime/detail_response.dart';
import 'package:presence_alpha/payload/response/overtime/list_submission.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/service/overtime_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/widget/bs_badge.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OvertimeDetailScreen extends StatefulWidget {
  final String id;

  const OvertimeDetailScreen({required this.id, super.key});

  @override
  State<OvertimeDetailScreen> createState() => _OvertimeDetailScreenState();
}

class _OvertimeDetailScreenState extends State<OvertimeDetailScreen> {
  OvertimeModel? overtimeData;
  List<SubmissionModel>? submissionList;
  bool loading = true;
  final overtimeStatusText = {
    "0": "Pending",
    "1": "Approved",
    "2": "Rejected",
    "3": "Canceled",
    "4": "Expired",
  };

  final submissionStatusText = {
    "0": "Pending",
    "1": "Approved",
    "2": "Rejected",
    "4": "Expired",
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadData() async {
    final tp = Provider.of<TokenProvider>(
      context,
      listen: false,
    );
    String token = tp.token;
    String id = widget.id;

    DetailResponse res1 = await OvertimeService().detail(id, token);
    debugPrint("overtime data ${res1.toJsonString()}");

    ListSubmissionResponse res2 =
        await OvertimeService().listSubmission(id, token);
    debugPrint("submission list ${res2.toJsonString()}");

    if (res1.status == true) {
      setState(() {
        overtimeData = res1.data;
      });
    }

    if (res2.status == true) {
      setState(() {
        submissionList = res2.data;
      });
    }

    if (res1.status == false || res2.status == false) {
      debugPrint("err1 ${res1.message}");
      debugPrint("err2 ${res2.message}");
      if (!mounted) return;
      AmessageUtility.show(
        context,
        "Gagal",
        "Fetch data dari server",
        TipType.ERROR,
      );
    }

    setState(() {
      loading = false;
    });
  }

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
          title: const Text("Detail"),
          backgroundColor: ColorConstant.lightPrimary,
          centerTitle: true,
        ),
        body: SafeArea(
          child: loading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10.0),
                            Text(
                              overtimeData!.user!.name!,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              overtimeData!.desc!,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              CalendarUtility.formatDate(
                                  DateTime.parse(overtimeData!.overtimeAt!)),
                              style: TextStyle(
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            BsBadge(
                              text: overtimeStatusText[
                                      overtimeData!.overtimeStatus!]!
                                  .toUpperCase(),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 11,
                              ),
                              backgroundColor: (overtimeData!.overtimeStatus! ==
                                      "0"
                                  ? Colors.blue
                                  : overtimeData!.overtimeStatus! == "1"
                                      ? Colors.green
                                      : (overtimeData!.overtimeStatus! == "2" ||
                                              overtimeData!.overtimeStatus! ==
                                                  "3")
                                          ? Colors.red
                                          : Colors.grey),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "Bukti Harus Lembur Dari Atasan/PIC",
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Image.network(
                              "${ApiConstant.baseUrl}/${overtimeData!.attachment!}",
                              width: MediaQuery.of(context).size.width - 32,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                            child: Text(
                              'Riwayat Pengajuan',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: submissionList!.asMap().entries.map(
                                (entry) {
                                  int index = entry.key;
                                  SubmissionModel submission = entry.value;
                                  Color idicatorColor = Colors.blue;
                                  Color backgroundColor =
                                      Colors.blue.withOpacity(0.2);
                                  String title = "";

                                  if (submission.submissionType == "new") {
                                    title = "Pengajuan Lembur";
                                    idicatorColor = Colors.green;
                                    backgroundColor =
                                        Colors.green.withOpacity(0.2);
                                  } else if (submission.submissionType ==
                                      "cancel") {
                                    title = "Pembatalan Lembur";
                                    idicatorColor = Colors.red;
                                    backgroundColor =
                                        Colors.red.withOpacity(0.2);
                                  }

                                  return TimelineTile(
                                    alignment: TimelineAlign.start,
                                    isFirst: index == 0,
                                    indicatorStyle: IndicatorStyle(
                                      width: 10,
                                      color: idicatorColor,
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    endChild: Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 80,
                                      ),
                                      padding: const EdgeInsets.all(16.0),
                                      color: backgroundColor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                              'Tanggal Pengajuan: ${CalendarUtility.formatDate(DateTime.parse(submission.submissionAt!))}'),
                                          Text(
                                              'Status: ${submissionStatusText[submission.submissionStatus]!}'),
                                          const SizedBox(height: 2),
                                          const SizedBox(height: 8),
                                          if (submission.authorizationAt !=
                                              null)
                                            Text(
                                                'Disetujui pada: ${CalendarUtility.formatDate(DateTime.parse(submission.authorizationAt!))}'),
                                          if (submission.authorizer?.name !=
                                              null)
                                            Text(
                                                'Disetujui oleh: ${submission.authorizer?.name}'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ).toList(),
                              // TimelineTile(
                              //   alignment: TimelineAlign.start,
                              //   indicatorStyle: const IndicatorStyle(
                              //     width: 10,
                              //     color: Colors.red,
                              //     padding: EdgeInsets.all(8),
                              //   ),
                              //   endChild: Container(
                              //     constraints: const BoxConstraints(
                              //       minHeight: 80,
                              //     ),
                              //     padding: const EdgeInsets.all(16.0),
                              //     color: Colors.red.withOpacity(0.2),
                              //     child: Column(
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.start,
                              //       children: const [
                              //         Text(
                              //           'Pembatalan Lembur',
                              //           style: TextStyle(
                              //             fontSize: 15,
                              //             fontWeight: FontWeight.bold,
                              //           ),
                              //         ),
                              //         SizedBox(height: 8),
                              //         Text('Tanggal Pengajuan: 11 Mei 2023'),
                              //         Text('Disetujui oleh: Meta Lia'),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
