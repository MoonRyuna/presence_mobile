import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/month_option.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RekapKaryawanScreen extends StatefulWidget {
  final String id;

  const RekapKaryawanScreen({super.key, required this.id});

  @override
  State<RekapKaryawanScreen> createState() => _RekapKaryawanScreenState();
}

class _RekapKaryawanScreenState extends State<RekapKaryawanScreen> {
  WebViewController? _webViewController;

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
            height: (MediaQuery.of(context).size.height - 135),
            child: WebView(
              gestureNavigationEnabled: false,
              zoomEnabled: false,
              backgroundColor: Colors.white,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController = webViewController;
              },
            ),
          ),
        ],
      ),
    );
  }

  fetchHtmlData(String id) async {
    LoadingUtility.show("Memuat Rekap");
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
      await _webViewController?.loadHtmlString(response.body);
      LoadingUtility.hide();
    } else {
      await _webViewController?.loadHtmlString(
          '<h1 style="text-align: center;">Gagal mendapatkan data rekap</h1>');
      LoadingUtility.hide();
    }
  }
}
