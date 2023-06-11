import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/month_option.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/response/report/create_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/service/report_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';

class ManageReportAddScreen extends StatefulWidget {
  const ManageReportAddScreen({super.key});

  @override
  State<ManageReportAddScreen> createState() => _ManageReportAddScreenState();
}

class _ManageReportAddScreenState extends State<ManageReportAddScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

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

  List<String> yearList = [];
  int currentYear = DateTime.now().year;

  String selectedMonth = DateTime.now().month.toString();
  String selectedYear = DateTime.now().year.toString();

  String? _titleErrorText;

  @override
  void dispose() {
    _titleController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeYearList();
    _monthController.text = selectedMonth;
    _yearController.text = selectedYear;
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

  Future<void> onBuatReport() async {
    LoadingUtility.show(null);

    int errorCount = 0;

    UserModel? user = Provider.of<UserProvider>(context, listen: false).user;
    final token = Provider.of<TokenProvider>(context, listen: false).token;

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

    setState(() {
      _titleErrorText = null;
    });

    final title = _titleController.text.trim();
    final month = _monthController.text.trim();
    final year = _yearController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _titleErrorText = "Judul tidak boleh kosong";
      });
      errorCount++;
    }

    if (errorCount > 0) {
      LoadingUtility.hide();
      return;
    }

    try {
      final requestData = {
        "title": title,
        "month_report": month,
        "year_report": year,
        "generated_by": user.id,
      };

      CreateResponse response =
          await ReportService().create(requestData, token);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Report Baru"),
        backgroundColor: ColorConstant.lightPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul',
                        errorText: _titleErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: ColorConstant.lightPrimary,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Bulan',
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: ColorConstant.lightPrimary,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            value: selectedMonth,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedMonth = newValue!;
                                _monthController.text = newValue;
                              });
                            },
                            items: monthOptions.map((option) {
                              return DropdownMenuItem<String>(
                                value: option.monthNumber,
                                child: Text(option.monthName),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Tahun',
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: ColorConstant.lightPrimary,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            value: selectedYear,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedYear = newValue!;
                                _yearController.text = selectedYear;
                              });
                            },
                            items: yearList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstant.lightPrimary,
                        minimumSize: const Size.fromHeight(50), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async {
                        await onBuatReport();
                      },
                      child: const Text(
                        'Buat Report',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget profilePicture(String? imagePath) {
  String profilePictureURI =
      "https://sbcf.fr/wp-content/uploads/2018/03/sbcf-default-avatar.png";
  if (imagePath != null) {
    if (imagePath == "images/default.png") {
      profilePictureURI = "${ApiConstant.publicUrl}/$imagePath";
    } else {
      profilePictureURI = "${ApiConstant.baseUrl}/$imagePath";
    }
  }

  return Image.network(
    profilePictureURI,
    width: 100,
    height: 100,
    fit: BoxFit.cover,
  );
}
