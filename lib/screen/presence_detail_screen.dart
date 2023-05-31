import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/presence_model.dart';
import 'package:presence_alpha/model/submission_model.dart';
import 'package:presence_alpha/payload/response/presence/detail_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/service/presence_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/widget/bs_badge.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

class PresenceDetailScreen extends StatefulWidget {
  final String id;

  const PresenceDetailScreen({required this.id, super.key});

  @override
  State<PresenceDetailScreen> createState() => _PresenceDetailScreenState();
}

class _PresenceDetailScreenState extends State<PresenceDetailScreen> {
  PresenceModel? presenceData;
  bool loading = true;

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

    DetailResponse res1 = await PresenceService().detail(id, token);
    debugPrint("presence data ${res1.toJsonString()}");

    if (res1.status == true) {
      setState(() {
        presenceData = res1.data;
      });
    }

    if (res1.status == false) {
      debugPrint("err1 ${res1.message}");
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
                              presenceData!.user!.name!,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              presenceData!.description!,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              CalendarUtility.formatDate(
                                  DateTime.parse(presenceData!.checkIn!)),
                              style: TextStyle(
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                Icon(
                                  presenceData!.type == "wfh"
                                      ? Icons.home_work_outlined
                                      : Icons.business,
                                  size: 15,
                                ),
                                const SizedBox(width: 4.0),
                                Text(presenceData!.type!)
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                BsBadge(
                                  text:
                                      "IN ${presenceData!.checkIn != null ? CalendarUtility.getTime(DateTime.parse(presenceData!.checkIn!)) : '-'}",
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                  backgroundColor: (Colors.green),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                BsBadge(
                                  text:
                                      "OUT ${presenceData!.checkOut != null ? CalendarUtility.getTime(DateTime.parse(presenceData!.checkOut!)) : '-'}",
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                  backgroundColor: (Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                ),
                                if (presenceData!.late == true)
                                  const SizedBox(width: 4.0),
                                if (presenceData!.late == true)
                                  const BsBadge(
                                    text: "TELAT",
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                    backgroundColor: (Colors.orange),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                  ),
                                if (presenceData!.overtime == true)
                                  const SizedBox(width: 4.0),
                                if (presenceData!.overtime == true)
                                  const BsBadge(
                                    text: "LEMBUR",
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                    backgroundColor: (Colors.blue),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
