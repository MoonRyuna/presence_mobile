import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/model/month_option.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:provider/provider.dart';

class RekapKaryawanScreen extends StatefulWidget {
  final String id;

  const RekapKaryawanScreen({super.key, required this.id});

  @override
  State<RekapKaryawanScreen> createState() => _RekapKaryawanScreenState();
}

class _RekapKaryawanScreenState extends State<RekapKaryawanScreen> {
  Future<String>? _htmlData;

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

  @override
  void initState() {
    super.initState();
    fetchHtmlData(widget.id);
    initializeYearList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap'),
        centerTitle: true,
        backgroundColor: ColorConstant.lightPrimary,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedMonth,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMonth = newValue!;
                      _htmlData = null;
                    });
                    fetchHtmlData(widget.id);
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
                      _htmlData = null;
                    });
                    fetchHtmlData(widget.id);
                  },
                  items: yearList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: (MediaQuery.of(context).size.height - 150),
            child: FutureBuilder<String>(
              future: _htmlData,
              builder: (context, snapshot) {
                if (_htmlData == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData) {
                  return WebView(
                    initialUrl: Uri.dataFromString(
                      snapshot.data!,
                      mimeType: 'text/html',
                      encoding: Encoding.getByName('utf-8'),
                    ).toString(),
                    javascriptMode: JavascriptMode.unrestricted,
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  fetchHtmlData(String id) async {
    final tp = Provider.of<TokenProvider>(
      context,
      listen: false,
    );

    String token = tp.token;

    final url = '${ApiConstant.baseApi}/report/rekap_karyawan';

    print("month $selectedMonth");
    print("year $selectedYear");
    final body = {
      "user_id": id,
      "month": selectedMonth,
      "year": selectedYear,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':
            'application/json', // Set the Content-Type header to application/json
      },
      body: json.encode(body),
    );
    print("response status ${response.statusCode}");

    if (response.statusCode == 200) {
      setState(() {
        _htmlData = null;
      });

      print(response.body);
      Future.delayed(const Duration(seconds: 10)).then((_) async {
        setState(() {
          _htmlData = Future<String>.value(response.body);
        });
      });
    } else {
      throw Exception('Failed to fetch HTML data');
    }
  }
}
