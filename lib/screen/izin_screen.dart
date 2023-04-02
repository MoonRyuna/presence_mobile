import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/color_constant.dart';

class IzinScreen extends StatefulWidget {
  const IzinScreen({Key? key}) : super(key: key);

  @override
  State<IzinScreen> createState() => _IzinScreenState();
}

class _IzinScreenState extends State<IzinScreen> {
  final List<Izin> _izinList = [
    Izin("1", "Cuti Tahunan", "2022-01-01", "2022-01-03"),
    Izin("2", "Sakit", "2022-01-10", "2022-01-12"),
    Izin("3", "Cuti Bersama", "2022-01-20", "2022-01-21"),
  ];

  String _selectedMonth = "January";
  String _selectedYear = "2022";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.lightPrimary,
        title: const Text("List Izin"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedMonth,
                  items: <String>[
                    'January',
                    'February',
                    'March',
                    'April',
                    'May',
                    'June',
                    'July',
                    'August',
                    'September',
                    'October',
                    'November',
                    'December'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedMonth = newValue!;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: _selectedYear,
                  items: <String>[
                    '2022',
                    '2023',
                    '2024',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedYear = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _izinList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.assignment),
                  title: Text(_izinList[index].jenisIzin),
                  subtitle: Text(
                      "${_izinList[index].tanggalMulai} - ${_izinList[index].tanggalSelesai}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _izinList.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Izin {
  final String id;
  final String jenisIzin;
  final String tanggalMulai;
  final String tanggalSelesai;

  Izin(this.id, this.jenisIzin, this.tanggalMulai, this.tanggalSelesai);
}
