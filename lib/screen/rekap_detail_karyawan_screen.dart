import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/date_range_model.dart';
import 'package:presence_alpha/model/month_option.dart';
import 'package:presence_alpha/model/rekap_detail_karyawan_model.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/response/report/rekap_detail_karyawan_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/service/report_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';

class RekapDetailKaryawanScreen extends StatefulWidget {
  final String id;
  final String month;
  final String year;

  const RekapDetailKaryawanScreen(
      {super.key, required this.id, required this.month, required this.year});

  @override
  State<RekapDetailKaryawanScreen> createState() =>
      _RekapDetailKaryawanScreenState();
}

class _RekapDetailKaryawanScreenState extends State<RekapDetailKaryawanScreen> {
  List<MonthOption> monthOptions = [
    MonthOption('1', 'Januari'),
    MonthOption('2', 'Februari'),
    MonthOption('3', 'Maret'),
    MonthOption('4', 'April'),
    MonthOption('5', 'Mei'),
    MonthOption('6', 'Juni'),
    MonthOption('7', 'Juli'),
    MonthOption('8', 'Agustus'),
    MonthOption('9', 'September'),
    MonthOption('10', 'Oktober'),
    MonthOption('11', 'November'),
    MonthOption('12', 'Desember'),
    // Tambahkan opsi bulan lainnya sesuai kebutuhan
  ];

  List<RekapDetailKaryawanModel> rekapDetailList =
      List<RekapDetailKaryawanModel>.empty();
  DateRangeModel dateRange = DateRangeModel();
  UserModel user = UserModel();

  List<String> yearList = [];
  int currentYear = DateTime.now().year;

  String selectedMonth = DateTime.now().month.toString();
  String selectedYear = DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.month;
    selectedYear = widget.year;
    initializeYearList();
    fetchRekapDetail(selectedMonth, selectedYear, widget.id);
  }

  String getMonthName(String month) {
    final DateTime dateTime = DateFormat('M').parse(month);
    final String monthName = DateFormat('MMMM', 'id_ID').format(dateTime);
    return monthName;
  }

  void initializeYearList() {
    int currentYear = DateTime.now().year;

    for (int i = currentYear - 5; i <= currentYear + 5; i++) {
      yearList.add(i.toString());
    }
  }

  Future<void> fetchRekapDetail(String month, String year, String id) async {
    LoadingUtility.show("Memuat Rekap");
    final tp = Provider.of<TokenProvider>(
      context,
      listen: false,
    );

    String token = tp.token;

    try {
      final body = {
        "user_id": id,
        "month": selectedMonth,
        "year": selectedYear,
      };

      RekapDetailKaryawanResponse response =
          await ReportService().rekapDetailKaryawan(body, token);
      if (!mounted) return;

      if (response.status != true || response.data == null) {
        LoadingUtility.hide();
        AmessageUtility.show(
          context,
          "Gagal",
          response.message!,
          TipType.ERROR,
        );
        return;
      }

      setState(() {
        rekapDetailList = response.data?.list ?? [];
        dateRange = response.data?.date ?? DateRangeModel();
        user = response.data?.user ?? UserModel();
      });

      AmessageUtility.show(
        context,
        "Berhasil",
        response.message!,
        TipType.COMPLETE,
      );

      LoadingUtility.hide();
    } catch (e) {
      LoadingUtility.hide();
      print("error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Detail'),
        centerTitle: true,
        backgroundColor: ColorConstant.lightPrimary,
        elevation: 0,
      ),
      backgroundColor: ColorConstant.bgOpt,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: selectedMonth,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMonth = newValue!;
                      });
                      fetchRekapDetail(selectedMonth, selectedYear, widget.id);
                    },
                    items: monthOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option.monthNumber,
                        child: Text(option.monthName),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: selectedYear,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue!;
                      });
                      fetchRekapDetail(selectedMonth, selectedYear, widget.id);
                    },
                    items:
                        yearList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${dateRange.startDate ?? ''} - ${dateRange.endDate ?? ''}",
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(user.name ?? "")],
              ),
              const SizedBox(height: 16),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rekapDetailList.length,
              itemBuilder: (context, index) {
                final formattedDate = DateFormat('dd MMMM yyyy', 'id_ID')
                    .format(DateTime.parse(rekapDetailList[index].date ?? ""));
                return Container(
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
                  margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: ListTile(
                    title: Text(formattedDate),
                    subtitle: Text(rekapDetailList[index].description ?? ""),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
