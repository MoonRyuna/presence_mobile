import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/absence_model.dart';
import 'package:presence_alpha/model/submission_model.dart';
import 'package:presence_alpha/payload/response/absence/detail_response.dart';
import 'package:presence_alpha/payload/response/absence/list_submission.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/service/absence_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/widget/bs_badge.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AbsenceDetailScreen extends StatefulWidget {
  final String id;

  const AbsenceDetailScreen({required this.id, super.key});

  @override
  State<AbsenceDetailScreen> createState() => _AbsenceDetailScreenState();
}

class _AbsenceDetailScreenState extends State<AbsenceDetailScreen> {
  AbsenceModel? absenceData;
  List<SubmissionModel>? submissionList;
  bool loading = true;
  final absenceStatusText = {
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

    DetailResponse res1 = await AbsenceService().detail(id, token);
    debugPrint("absence data ${res1.toJsonString()}");

    ListSubmissionResponse res2 =
        await AbsenceService().listSubmission(id, token);
    debugPrint("submission list ${res2.toJsonString()}");

    if (res1.status == true) {
      setState(() {
        absenceData = res1.data;
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
                              absenceData!.user!.name!,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              absenceData!.desc!,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              absenceData!.absenceType!.name!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              CalendarUtility.formatDate(
                                  DateTime.parse(absenceData!.absenceAt!)
                                      .toLocal()),
                              style: TextStyle(
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            BsBadge(
                              text: absenceStatusText[
                                      absenceData!.absenceStatus!]!
                                  .toUpperCase(),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 11,
                              ),
                              backgroundColor: (absenceData!.absenceStatus! ==
                                      "0"
                                  ? Colors.blue
                                  : absenceData!.absenceStatus! == "1"
                                      ? Colors.green
                                      : (absenceData!.absenceStatus! == "2" ||
                                              absenceData!.absenceStatus! ==
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
                              "Bukti Izin",
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Image.network(
                              "${ApiConstant.baseUrl}/${absenceData!.attachment!}",
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                                    title = "Pengajuan Izin";
                                    idicatorColor = Colors.green;
                                    backgroundColor =
                                        Colors.green.withOpacity(0.2);
                                  } else if (submission.submissionType ==
                                      "cancel") {
                                    title = "Pembatalan Izin";
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
                                              'Tanggal Pengajuan: ${CalendarUtility.formatDate(DateTime.parse(submission.submissionAt!).toLocal())}'),
                                          Text(
                                              'Status: ${submissionStatusText[submission.submissionStatus]!}'),
                                          const SizedBox(height: 2),
                                          const SizedBox(height: 8),
                                          if (submission.authorizationAt !=
                                              null)
                                            Text(
                                                'Disetujui pada: ${CalendarUtility.formatDate(DateTime.parse(submission.authorizationAt!).toLocal())}'),
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
