import 'dart:io';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/absence_type_model.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/response/absence/submission_response.dart';
import 'package:presence_alpha/payload/response/absence_type/all_response.dart';
import 'package:presence_alpha/payload/response/upload_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/service/absence_service.dart';
import 'package:presence_alpha/service/absence_type_service.dart';
import 'package:presence_alpha/service/upload_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';

class AbsenceAddScreen extends StatefulWidget {
  const AbsenceAddScreen({super.key});

  @override
  State<AbsenceAddScreen> createState() => _AbsenceAddScreenState();
}

class _AbsenceAddScreenState extends State<AbsenceAddScreen> {
  final TextEditingController _absenceAtController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  File? attachment;
  String? attachmentPath;
  String? absenceTypeId;

  String? _absenceAtErrorText;
  String? _descErrorText;
  String? _absenceTypeErrorText;

  List<AbsenceTypeModel>? absenceTypeList;

  @override
  void initState() {
    super.initState();
    _absenceAtController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _descController.text = "";
  }

  @override
  void dispose() {
    _descController.dispose();
    _absenceAtController.dispose();
    super.dispose();
  }

  Future<List<AbsenceTypeModel>> getDataAbsenceType() async {
    List<AbsenceTypeModel> absenceTypes = [];
    try {
      final tp = Provider.of<TokenProvider>(
        context,
        listen: false,
      );
      String token = tp.token;
      AllResponse res = await AbsenceTypeService().all(token);

      if (res.data != null) {
        absenceTypes = res.data!;
      }
    } catch (error) {
      print('Error: $error');
    }
    return absenceTypes;
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

      if (response.data?.path == null) {
        String msg = response.message ?? "melakukan upload ke server";

        AmessageUtility.show(
          context,
          "Gagal",
          msg,
          TipType.ERROR,
        );

        setState(() {
          attachment = null;
          attachmentPath = null;
        });
        return;
      } else {
        if (response.data?.path != null) {
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
      _absenceTypeErrorText = null;
      _absenceAtErrorText = null;
      _descErrorText = null;
    });

    final absenceAt = _absenceAtController.text.trim();
    final desc = _descController.text.trim();

    if (absenceAt.isEmpty) {
      setState(() {
        _absenceAtErrorText = "Tanggal izin tidak boleh kosong";
      });
      errorCount++;
    }

    if (absenceTypeId == null) {
      setState(() {
        _absenceTypeErrorText = "Jenis izin tidak boleh kosong";
      });
      errorCount++;
    }

    if (desc.isEmpty) {
      setState(() {
        _descErrorText = "Deskripsi izin tidak boleh kosong";
      });
      errorCount++;
    }

    if (attachmentPath == null) {
      AmessageUtility.show(
        context,
        "Info",
        "Silakan masukan bukti harus izin",
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
        "absence_at": absenceAt,
        "absence_type_id": absenceTypeId,
        "desc": desc,
        "attachment": attachmentPath
      };

      SubmissionResponse response =
          await AbsenceService().submission(requestData, token);
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
          title: const Text("Ajukan Izin"),
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
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: const Text(
                          "Tanggal Izin",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _absenceAtController,
                        readOnly: true,
                        decoration: InputDecoration(
                          errorText: _absenceAtErrorText,
                          errorStyle: const TextStyle(color: Colors.red),
                          suffixIcon: const Icon(Icons.calendar_today),
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
                              _absenceAtController.text =
                                  formattedDate; //set output date to TextField value.
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: const Text(
                          "Jenis Izin",
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownSearch<AbsenceTypeModel>(
                        asyncItems: (String filter) async {
                          return getDataAbsenceType();
                        },
                        itemAsString: (AbsenceTypeModel u) => u.name.toString(),
                        onChanged: (AbsenceTypeModel? data) {
                          print(data!.toJsonString());
                          setState(() {
                            absenceTypeId = data.id.toString();
                          });
                          print("absenceTypeId $absenceTypeId");
                        },
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            errorText: _absenceTypeErrorText,
                            errorStyle: const TextStyle(color: Colors.red),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: ColorConstant.lightPrimary,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: const Text(
                          "Deskripsi Izin",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        controller: _descController,
                        decoration: InputDecoration(
                          errorText: _descErrorText,
                          errorStyle: const TextStyle(color: Colors.red),
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
                          "Sertakan Bukti Izin",
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
      ),
    );
  }
}
