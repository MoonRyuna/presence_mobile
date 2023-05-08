import 'dart:io';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/response/overtime/submission_response.dart';
import 'package:presence_alpha/payload/response/upload_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/service/overtime_service.dart';
import 'package:presence_alpha/service/upload_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';

class OvertimeAddScreen extends StatefulWidget {
  const OvertimeAddScreen({super.key});

  @override
  State<OvertimeAddScreen> createState() => _OvertimeAddScreenState();
}

class _OvertimeAddScreenState extends State<OvertimeAddScreen> {
  final TextEditingController _overtimeAtController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  File? attachment;
  String? attachmentPath;

  String? _overtimeAtErrorText;
  String? _descErrorText;

  @override
  void initState() {
    super.initState();
    _overtimeAtController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    _descController.text = "Pekerjaan perlu di lemburkan";
  }

  @override
  void dispose() {
    _descController.dispose();
    _overtimeAtController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        attachment = File(pickedFile.path);
      }
    });

    if (attachment?.path != null) {
      await uploadAttachment();
    }
  }

  Future<void> uploadAttachment() async {
    LoadingUtility.show("Melakukan Upload");
    try {
      final tp = Provider.of<TokenProvider>(
        context,
        listen: false,
      );
      String token = tp.token;

      if (attachment?.path == null) {
        AmessageUtility.show(
          context,
          "Info",
          "Tidak memilih file",
          TipType.INFO,
        );
        return;
      }

      final mimeType = MediaType('image', 'jpeg');
      MultipartFile file = await http.MultipartFile.fromPath(
        'image',
        attachment!.path,
        contentType: mimeType,
      );

      UploadResponse response = await UploadService().image(file, token);
      if (!mounted) return;

      if (response.data!.path == null) {
        AmessageUtility.show(
          context,
          "Gagal",
          "melakukan upload ke server",
          TipType.ERROR,
        );
        return;
      } else {
        if (response.data!.path != null) {
          setState(() {
            attachmentPath = response.data!.path;
          });
        }

        print("file upload $attachmentPath");
      }
    } catch (error) {
      print('Error: $error');

      AmessageUtility.show(context, "Gagal", error.toString(), TipType.ERROR);
    } finally {
      LoadingUtility.hide();
    }
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: _pickAttachment,
      child: Container(
        width: double.infinity,
        height: 150.0,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
          border: attachment != null
              ? Border.all(color: Colors.grey, width: 2.0)
              : null,
        ),
        child: attachment != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Image.file(
                  attachment!,
                  fit: BoxFit.cover,
                ),
              )
            : const Center(
                child: Icon(Icons.add_a_photo),
              ),
      ),
    );
  }

  Future<void> onAjukan() async {
    LoadingUtility.show(null);

    int errorCount = 0;

    UserModel? user = Provider.of<UserProvider>(context, listen: false).user;
    final token = Provider.of<TokenProvider>(context, listen: false).token;

    if (user == null || user.id == null) {
      LoadingUtility.hide();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return;
    }

    setState(() {
      _overtimeAtErrorText = null;
      _descErrorText = null;
    });

    final overtimeAt = _overtimeAtController.text.trim();
    final desc = _descController.text.trim();

    if (overtimeAt.isEmpty) {
      setState(() {
        _overtimeAtErrorText = "Tanggal lembur tidak boleh kosong";
      });
      errorCount++;
    }

    if (desc.isEmpty) {
      setState(() {
        _descErrorText = "Deskripsi lembur tidak boleh kosong";
      });
      errorCount++;
    }

    if (attachmentPath == null) {
      AmessageUtility.show(
        context,
        "Info",
        "Silakan masukan bukti harus lembur",
        TipType.INFO,
      );
      errorCount++;
    }

    if (errorCount > 0) {
      LoadingUtility.hide();
      return;
    }

    try {
      final requestData = {
        "user_id": user.id,
        "overtime_at": overtimeAt,
        "desc": desc,
        "attachment": attachmentPath
      };

      SubmissionResponse response =
          await OvertimeService().submission(requestData, token);
      if (!mounted) return;

      if (response.status != true) {
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
        title: const Text("Ajukan Lembur"),
        backgroundColor: ColorConstant.lightPrimary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _overtimeAtController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Lembur',
                        errorText: _overtimeAtErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: const Icon(Icons.calendar_today),
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
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );

                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          setState(() {
                            _overtimeAtController.text =
                                formattedDate; //set output date to TextField value.
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      maxLines: 4,
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Lembur',
                        errorText: _descErrorText,
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
                    Container(
                      alignment: Alignment.bottomLeft,
                      child: const Text(
                        "Sertakan Bukti Harus Lembur Dari Atasan/PIC",
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildImagePreview(),
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
                        await onAjukan();
                      },
                      child: const Text(
                        'Ajukan',
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
