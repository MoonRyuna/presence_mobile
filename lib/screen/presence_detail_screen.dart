import 'dart:convert';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/location_model.dart';
import 'package:presence_alpha/model/presence_model.dart';
import 'package:presence_alpha/model/submission_model.dart';
import 'package:presence_alpha/payload/response/presence/detail_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/service/presence_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/widget/bs_badge.dart';
import 'package:presence_alpha/widget/my_map_widget.dart';
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
  LocationModel positionCheckIn =
      LocationModel(address: "", lat: "0", lng: "0");
  LocationModel positionCheckOut =
      LocationModel(address: "", lat: "0", lng: "0");

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
        if (presenceData!.positionCheckIn != null) {
          positionCheckIn = LocationModel.fromJson(
              jsonDecode(presenceData!.positionCheckIn!));
        }

        if (presenceData!.positionCheckOut != null) {
          positionCheckOut = LocationModel.fromJson(
              jsonDecode(presenceData!.positionCheckOut!));
        }

        print("check in address: ${positionCheckIn.address}");
        print("check in lat: ${positionCheckIn.lat}");
        print("check in lng: ${positionCheckIn.lng}");
        print("check out address: ${positionCheckOut.address}");
        print("check out lat: ${positionCheckOut.lat}");
        print("check out lng: ${positionCheckOut.lng}");
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
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3.0),
                            Text(
                              CalendarUtility.formatDate(
                                  DateTime.parse(presenceData!.checkIn!)
                                      .toLocal()),
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
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  presenceData!.type! == "wfo"
                                      ? "wfo (kantor)"
                                      : "wfh (jarak jauh)",
                                  style: TextStyle(color: Colors.grey.shade600),
                                )
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                BsBadge(
                                  text:
                                      "${presenceData!.checkIn != null ? CalendarUtility.getTime(DateTime.parse(presenceData!.checkIn!).toLocal()) : '?'} - ${presenceData!.checkOut != null ? CalendarUtility.getTime(DateTime.parse(presenceData!.checkOut!).toLocal()) : '?'}",
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
                                if (presenceData!.checkIn != null &&
                                    presenceData!.checkOut != null)
                                  const SizedBox(width: 4.0),
                                if (presenceData!.checkIn != null &&
                                    presenceData!.checkOut != null)
                                  BsBadge(
                                    text:
                                        CalendarUtility.formatOvertimeInterval(
                                            presenceData!.checkIn!,
                                            presenceData!.checkOut!),
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
                              ],
                            ),
                            const SizedBox(height: 6.0),
                            Row(
                              children: [
                                if (presenceData!.late == true)
                                  BsBadge(
                                    text:
                                        "Telat ${(presenceData!.lateAmount! < 60 ? "${presenceData!.lateAmount!} menit" : "${(presenceData!.lateAmount! / 60).round()} jam")}",
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                    backgroundColor: (Colors.orange),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                  ),
                                const SizedBox(width: 4.0),
                                if (presenceData!.fullTime == true)
                                  const BsBadge(
                                    text: "Fulltime",
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                    backgroundColor: (Colors.purple),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                  ),
                                if (presenceData!.fullTime == false)
                                  BsBadge(
                                    text: (presenceData!.remainingHour! < 60
                                        ? "Tidak Fulltime (sisa ${presenceData!.remainingHour!} menit)"
                                        : "Tidak Fulltime (sisa ${(presenceData!.remainingHour! / 60).round()} jam)"),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                    backgroundColor: (Colors.purple),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6.0),
                            Row(
                              children: [
                                if (presenceData!.overtime == true)
                                  const BsBadge(
                                    text: "Lembur",
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                    backgroundColor: (Colors.lightBlue),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                  ),
                                if (presenceData!.overtime == true)
                                  const SizedBox(width: 4.0),
                                if (presenceData!.overtime == true)
                                  BsBadge(
                                    text:
                                        "${CalendarUtility.getTime(DateTime.parse(presenceData!.overtimeStartAt!).toLocal())} - ${CalendarUtility.getTime(DateTime.parse(presenceData!.overtimeEndAt!).toLocal())}  ${presenceData!.overtimeStartAt != null && presenceData!.overtimeEndAt != null ? CalendarUtility.formatOvertimeInterval(presenceData!.overtimeStartAt!, presenceData!.overtimeEndAt!) : ""}",
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                    backgroundColor: (Colors.lightBlue),
                                    padding: const EdgeInsets.symmetric(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                            child: Text(
                              'Catatan Harian: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Text(
                              presenceData!.description != null
                                  ? presenceData!.description!
                                  : "",
                              style: const TextStyle(fontSize: 14.0),
                            ),
                          )
                        ],
                      ),
                      const Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 10.0),
                            child: Text(
                              'Posisi Check In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (positionCheckIn.lat != null &&
                              positionCheckIn.lng != null)
                            MyMapWidget(
                              latitude:
                                  double.parse(positionCheckIn.lat ?? "0.0"),
                              longitude:
                                  double.parse(positionCheckIn.lng ?? "0.0"),
                              label: "check in",
                            ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                            child: Text(positionCheckIn.address!),
                          )
                        ],
                      ),
                      const Divider(),
                      if (positionCheckOut.lat != "0" &&
                          positionCheckOut.lng != "0")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 10.0),
                              child: Text(
                                'Posisi Check Out',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (positionCheckOut.lat != "0" &&
                                positionCheckOut.lng != "0")
                              MyMapWidget(
                                latitude:
                                    double.parse(positionCheckOut.lat ?? "0.0"),
                                longitude:
                                    double.parse(positionCheckOut.lng ?? "0.0"),
                                label: "check out",
                              ),
                            if (positionCheckOut.lat != "0" &&
                                positionCheckOut.lng != "0")
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                                child: Text(positionCheckOut.address!),
                              )
                          ],
                        ),
                      if (positionCheckOut.lat != "0" &&
                          positionCheckOut.lng != "0")
                        const Divider(),
                      const SizedBox(height: 16.0)
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
