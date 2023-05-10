import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';

class OvertimeDetailScreen extends StatefulWidget {
  final String id;

  const OvertimeDetailScreen({required this.id, super.key});

  @override
  State<OvertimeDetailScreen> createState() => _OvertimeDetailScreenState();
}

class _OvertimeDetailScreenState extends State<OvertimeDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> overtime = {
      "id": 52,
      "user_id": "3",
      "overtime_at": "2023-05-10T00:00:00.000Z",
      "overtime_status": "0",
      "desc": "Pekerjaan perlu di lemburkan",
      "attachment": "public\\images\\image-1683731077869-259886403.jpeg",
      "user": {
        "id": "3",
        "user_code": "12.001",
        "username": "ari",
        "name": "Ari Ardiansyah"
      },
      "data": [
        {
          "id": 6,
          "submission_type": "new",
          "submission_at": "2023-04-28T01:53:28.044Z",
          "submission_status": "0",
          "submission_ref_table": "overtime",
          "submission_ref_id": "3",
          "authorization_by": null,
          "authorization_at": null,
          "authorizer": null
        }
      ]
    };

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pemohon: ${overtime['user']['name']}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tanggal Lembur:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${overtime['overtime_at']}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Status Lembur:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${overtime['overtime_status'] == '0' ? 'Pending' : overtime['overtime_status'] == '1' ? 'Approved' : overtime['overtime_status'] == '2' ? 'Rejected' : overtime['overtime_status'] == '3' ? 'Canceled' : overtime['overtime_status'] == '4' ? 'Expired' : ''}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Deskripsi:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${overtime['desc']}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Lampiran:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        "${ApiConstant.baseUrl}/${overtime['attachment']}",
                        width: 100,
                        height: 100,
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Daftar Pengajuan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: overtime['data'].length,
                  itemBuilder: (context, index) {
                    final pengajuan = overtime['data'][index];
                    return ListTile(
                      title: Text('ID Pengajuan: ${pengajuan['id']}'),
                      subtitle: Text(
                          'Tipe Pengajuan: ${pengajuan['submission_type']}'),
                      trailing: Text(
                          'Status Pengajuan: ${pengajuan['submission_status'] == '0' ? 'Belum Disetujui' : 'Disetujui'}'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
