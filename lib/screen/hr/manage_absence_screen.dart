import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/submission_admin_model.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/response/absence/list_submission_admin_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/screen/absence_detail_screen.dart';
import 'package:presence_alpha/service/absence_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:presence_alpha/widget/bs_badge.dart';
import 'package:provider/provider.dart';

class ManageAbsenceScreen extends StatefulWidget {
  const ManageAbsenceScreen({super.key});

  @override
  State<ManageAbsenceScreen> createState() => _ManageAbsenceScreenState();
}

class _ManageAbsenceScreenState extends State<ManageAbsenceScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  List<SubmissionAdminModel> absences = List<SubmissionAdminModel>.empty();

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
        absences = List<SubmissionAdminModel>.empty();
        page = 1;
        firstLoad = true;
        endOfList = false;
      });
      loadData();
    }
  }

  void _onRefresh() async {
    setState(() {
      absences = List<SubmissionAdminModel>.empty();
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
    };

    if (firstLoad == false &&
        loadMoreRunning == false &&
        endOfList == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        loadMoreRunning = true;
      });

      ListSubmissionAdminResponse response =
          await AbsenceService().listSubmissionAdmin(queryParams, token);
      if (!mounted) return;

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            absences = [...absences, ...?response.data?.result];
          }

          if (response.data!.nextPage == null || response.data!.nextPage == 0) {
            endOfList = true;
          } else {
            endOfList = false;
            page = response.data!.nextPage!;
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
      ListSubmissionAdminResponse response =
          await AbsenceService().listSubmissionAdmin(queryParams, token);
      if (!mounted) return;

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            absences = response.data!.result;
          }

          if (response.data!.nextPage == null || response.data!.nextPage == 0) {
            endOfList = true;
          } else {
            endOfList = false;
            page = response.data!.nextPage!;
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

  Future<void> _onApprove(int id) async {
    bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text(
              "Apakah anda yakin ingin menyetujui pengajuan absensi ini?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );

    if (isConfirmed == null || isConfirmed == false) {
      return;
    }

    LoadingUtility.show(null);

    final tp = Provider.of<TokenProvider>(
      context,
      listen: false,
    );

    UserModel? user = Provider.of<UserProvider>(context, listen: false).user;
    String token = tp.token;

    if (user == null || user.id == null) {
      if (!mounted) return;
      LoadingUtility.hide();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return;
    }

    try {
      final queryParams = {
        "submission_id": id.toString(),
        "authorization_by": user.id
      };

      final response = await AbsenceService().approve(queryParams, token);
      if (!mounted) return;

      if (response.status == true) {
        AmessageUtility.show(
          context,
          "Berhasil",
          response.message!,
          TipType.COMPLETE,
        );
        _onRefresh();
      } else {
        AmessageUtility.show(
          context,
          "Gagal",
          response.message!,
          TipType.ERROR,
        );
      }
    } catch (e) {
      AmessageUtility.show(
        context,
        "Gagal",
        e.toString(),
        TipType.ERROR,
      );
    } finally {
      LoadingUtility.hide();
    }
  }

  Future<void> _onReject(int id) async {
    bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text(
              "Apakah anda yakin ingin menolak pengajuan absensi ini?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );

    if (isConfirmed == null || isConfirmed == false) {
      return;
    }

    LoadingUtility.show(null);

    final tp = Provider.of<TokenProvider>(
      context,
      listen: false,
    );

    UserModel? user = Provider.of<UserProvider>(context, listen: false).user;
    String token = tp.token;

    if (user == null || user.id == null) {
      if (!mounted) return;
      LoadingUtility.hide();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return;
    }

    try {
      final queryParams = {
        "submission_id": id.toString(),
        "authorization_by": user.id
      };

      final response = await AbsenceService().reject(queryParams, token);
      if (!mounted) return;

      if (response.status == true) {
        AmessageUtility.show(
          context,
          "Berhasil",
          response.message!,
          TipType.COMPLETE,
        );
        _onRefresh();
      } else {
        AmessageUtility.show(
          context,
          "Gagal",
          response.message!,
          TipType.ERROR,
        );
      }
    } catch (e) {
      AmessageUtility.show(
        context,
        "Gagal",
        e.toString(),
        TipType.ERROR,
      );
    } finally {
      LoadingUtility.hide();
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
        title: const Text('Persetujuan Izin'),
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
                          final submissionStatusText = {
                            "0": "Pending",
                            "1": "Approved",
                            "2": "Rejected",
                            "4": "Expired",
                          }[absence.submissionStatus];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 0),
                            child: Slidable(
                              enabled: absence.submissionStatus == "0",
                              startActionPane: ActionPane(
                                motion: const BehindMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) async {
                                      await _onApprove(absence.id!);
                                    },
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    icon: Icons.check,
                                    label: 'Setuju',
                                  ),
                                  SlidableAction(
                                    onPressed: (context) async {
                                      await _onReject(absence.id!);
                                    },
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.close,
                                    label: 'Tolak',
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 0,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: ListTile(
                                  onTap: () async {
                                    bool result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AbsenceDetailScreen(
                                          id: absence.submissionRefId
                                              .toString(),
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _onRefresh();
                                    }
                                  },
                                  title: Text(
                                    absence.name!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2.0),
                                      Text(
                                        absence.description != null &&
                                                absence.description!.length > 35
                                            ? '${absence.description!.substring(0, 35)}...'
                                            : absence.description ?? '',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        absence.absenceType!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.withOpacity(0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        CalendarUtility.formatDate(
                                            DateTime.parse(absence.absenceAt!)),
                                        style: TextStyle(
                                          color: Colors.grey.shade900,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        "Tanggal Pengajuan: ${CalendarUtility.formatDate(DateTime.parse(absence.submissionAt!))}",
                                        style: TextStyle(
                                          color: Colors.grey.shade900,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6.0),
                                      Row(
                                        children: [
                                          BsBadge(
                                            text:
                                                (absence.submissionType == "new"
                                                        ? "pengajuan"
                                                        : "pembatalan")
                                                    .toUpperCase(),
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                            backgroundColor:
                                                (absence.submissionType! ==
                                                        "new"
                                                    ? Colors.green
                                                    : absence.submissionType! ==
                                                            "cancel"
                                                        ? Colors.red
                                                        : Colors.grey),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 4.0,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          BsBadge(
                                            text: submissionStatusText!
                                                .toUpperCase(),
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                            backgroundColor: (absence
                                                        .submissionStatus! ==
                                                    "0"
                                                ? Colors.blue
                                                : absence.submissionStatus! ==
                                                        "1"
                                                    ? Colors.green
                                                    : (absence.submissionStatus! ==
                                                                "2" ||
                                                            absence.submissionStatus! ==
                                                                "3")
                                                        ? Colors.red
                                                        : Colors.grey),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 4.0,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
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
