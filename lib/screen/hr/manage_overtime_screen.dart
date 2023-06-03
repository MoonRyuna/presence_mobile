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
import 'package:presence_alpha/screen/overtime_detail_screen.dart';
import 'package:presence_alpha/service/overtime_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:presence_alpha/widget/bs_badge.dart';
import 'package:provider/provider.dart';

class ManageOvertimeScreen extends StatefulWidget {
  const ManageOvertimeScreen({super.key});

  @override
  State<ManageOvertimeScreen> createState() => _ManageOvertimeScreenState();
}

class _ManageOvertimeScreenState extends State<ManageOvertimeScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  List<SubmissionAdminModel> overtimes = List<SubmissionAdminModel>.empty();

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
        overtimes = List<SubmissionAdminModel>.empty();
        page = 1;
        firstLoad = true;
        endOfList = false;
      });
      loadData();
    }
  }

  void _onRefresh() async {
    setState(() {
      overtimes = List<SubmissionAdminModel>.empty();
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
      await OvertimeService().listSubmissionAdmin(queryParams, token);
      if (!mounted) return;

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            overtimes = [...overtimes, ...?response.data?.result];
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
      await OvertimeService().listSubmissionAdmin(queryParams, token);
      if (!mounted) return;

      if (response.status == true) {
        setState(() {
          if (response.data?.result != null) {
            overtimes = response.data!.result;
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
            "Apakah anda yakin ingin menyetujui lembur ini?",
          ),
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

    UserModel? user = Provider
        .of<UserProvider>(context, listen: false)
        .user;
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

      final response = await OvertimeService().approve(queryParams, token);
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
            "Apakah anda yakin ingin menolak lembur ini?",
          ),
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

    UserModel? user = Provider
        .of<UserProvider>(context, listen: false)
        .user;
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

      final response = await OvertimeService().reject(queryParams, token);
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
    _controller = ScrollController()
      ..addListener(loadData);
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
                        '${DateFormat('dd/MM/yyyy').format(
                            _startDate)} - ${DateFormat('dd/MM/yyyy').format(
                            _endDate)}',
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
                builder: (context) =>
                    ListView.builder(
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
                        }[overtime.submissionStatus];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7, horizontal: 0),
                          child: Slidable(
                            startActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    await _onApprove(overtime.id!);
                                  },
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  icon: Icons.check,
                                  label: 'Approve',
                                ),
                                SlidableAction(
                                  onPressed: (context) async {
                                    await _onReject(overtime.id!);
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.close,
                                  label: 'Reject',
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 0,
                              ),
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
                                onTap: () async {
                                  bool result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OvertimeDetailScreen(
                                            id: overtime.id.toString(),
                                          ),
                                    ),
                                  );
                                  if (result == true) {
                                    _onRefresh();
                                  }
                                },
                                title: Text(
                                  overtime.name!,
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
                                      overtime.description != null &&
                                          overtime.description!.length >
                                              35
                                          ? '${overtime.description!.substring(
                                          0, 35)}...'
                                          : overtime.description ?? '',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      CalendarUtility.formatDate(
                                          DateTime.parse(
                                              overtime.overtimeAt!)),
                                      style: TextStyle(
                                        color: Colors.grey.shade900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    BsBadge(
                                      text: overtimeStatusText!.toUpperCase(),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                      backgroundColor: (overtime
                                          .submissionStatus! ==
                                          "0"
                                          ? Colors.blue
                                          : overtime.submissionStatus! == "1"
                                          ? Colors.green
                                          : (overtime.submissionStatus! ==
                                          "2" ||
                                          overtime.submissionStatus! ==
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
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                fallback: (context) =>
                    Column(
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
