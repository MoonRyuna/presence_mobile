import 'dart:io';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/office_config_model.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/response/update_office_config_response.dart';
import 'package:presence_alpha/payload/response/upload_response.dart';
import 'package:presence_alpha/provider/office_config_provide.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/service/office_config_service.dart';
import 'package:presence_alpha/service/upload_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';

class UbahPengaturanKantorScreen extends StatefulWidget {
  const UbahPengaturanKantorScreen({super.key});

  @override
  State<UbahPengaturanKantorScreen> createState() =>
      _UbahPengaturanKantorScreenState();
}

class _UbahPengaturanKantorScreenState
    extends State<UbahPengaturanKantorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _cutOffDateController = TextEditingController();
  final TextEditingController _amountOfAnnualLeaveController =
      TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _themeController =
      TextEditingController(); // select

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _nameErrorText;
  String? _radiusErrorText;
  String? _cutOffDateErrorText;
  String? _amountOfAnnualLeaveErrorText;
  String? _startTimeErrorText;
  String? _endTimeErrorText;
  String? _themeErrorText;

  File? _image;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final office =
        Provider.of<OfficeConfigProvider>(context, listen: false).officeConfig;

    if (office != null) {
      _nameController.text = office.name ?? "";
      _radiusController.text = office.radius.toString();
      _cutOffDateController.text = office.cutOffDate.toString();
      _amountOfAnnualLeaveController.text =
          office.amountOfAnnualLeave.toString();
      _themeController.text = office.theme ?? "";

      // split work schedule by "-" trim them and take the first as start time and the second as end time
      final workSchedule =
          office.workSchedule?.split("-").map((e) => e.trim()).toList();
      _startTime = TimeOfDay(
        hour: int.parse(workSchedule![0].split(":")[0]),
        minute: int.parse(workSchedule[0].split(":")[1]),
      );
      _endTime = TimeOfDay(
        hour: int.parse(workSchedule[1].split(":")[0]),
        minute: int.parse(workSchedule[1].split(":")[1]),
      );

      _startTimeController.text = _formatTime(_startTime!);
      _endTimeController.text = _formatTime(_endTime!);

      _imagePath = office.logo;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _radiusController.dispose();
    _cutOffDateController.dispose();
    _amountOfAnnualLeaveController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _themeController.dispose();

    super.dispose();
  }

  Future pickImage() async {
    final ImagePicker imagePicker = ImagePicker();

    final XFile? imagePicked =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (imagePicked != null) {
      setState(() {
        _image = File(imagePicked.path);
      });
    }

    if (_image?.path != null) {
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    LoadingUtility.show("Melakukan Upload");
    try {
      final tp = Provider.of<TokenProvider>(
        context,
        listen: false,
      );
      String token = tp.token;

      if (_image?.path == null) {
        AmessageUtility.show(
          context,
          "Info",
          "Tidak memilih file",
          TipType.INFO,
        );
        return;
      }

      final mimeType = MediaType('image', 'jpeg');
      MultipartFile file = await MultipartFile.fromPath(
        'image',
        _image!.path,
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
          _image = null;
          _imagePath = null;
        });
        return;
      } else {
        if (response.data?.path != null) {
          setState(() {
            _imagePath = response.data!.path;
          });
        }

        print("file upload $_imagePath");
      }
    } catch (error) {
      print('Error: $error');

      AmessageUtility.show(context, "Gagal", error.toString(), TipType.ERROR);
    } finally {
      LoadingUtility.hide();
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        _startTimeController.text = _formatTime(picked);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
        _endTimeController.text = _formatTime(picked);
      });
    }
  }

  // format time to 25 hours format
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");

    return "$hour:$minute";
  }

  Future<void> onUbahPengaturan() async {
    LoadingUtility.show(null);

    int errorCount = 0;

    UserModel? user = Provider.of<UserProvider>(context, listen: false).user;
    OfficeConfigModel? office =
        Provider.of<OfficeConfigProvider>(context, listen: false).officeConfig;
    final token = Provider.of<TokenProvider>(context, listen: false).token;

    if (user == null || user.id == null || office == null) {
      LoadingUtility.hide();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return;
    }

    setState(() {
      _nameErrorText = null;
      _radiusErrorText = null;
      _cutOffDateErrorText = null;
      _amountOfAnnualLeaveErrorText = null;
      _startTimeErrorText = null;
      _endTimeErrorText = null;
      _themeErrorText = null;
    });

    final name = _nameController.text.trim();
    final radius = _radiusController.text.trim();
    final cutOffDate = _cutOffDateController.text.trim();
    final amountOfAnnualLeave = _amountOfAnnualLeaveController.text.trim();
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();
    final workSchedule = "$startTime - $endTime";
    final theme = _themeController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _nameErrorText = "Nama kantor tidak boleh kosong";
      });
      errorCount++;
    }

    if (radius.isEmpty) {
      setState(() {
        _radiusErrorText = "Radius tidak boleh kosong";
      });
      errorCount++;
    }

    if (cutOffDate.isEmpty) {
      setState(() {
        _cutOffDateErrorText = "Tanggal cut off tidak boleh kosong";
      });
      errorCount++;
    }

    if (amountOfAnnualLeave.isEmpty) {
      setState(() {
        _amountOfAnnualLeaveErrorText = "Jumlah cuti tidak boleh kosong";
      });
      errorCount++;
    }

    if (startTime.isEmpty) {
      setState(() {
        _startTimeErrorText = "Jam mulai tidak boleh kosong";
      });
      errorCount++;
    }

    if (endTime.isEmpty) {
      setState(() {
        _endTimeErrorText = "Jam selesai tidak boleh kosong";
      });
      errorCount++;
    }

    if (theme.isEmpty) {
      setState(() {
        _themeErrorText = "Tema tidak boleh kosong";
      });
      errorCount++;
    }

    if (errorCount > 0) {
      LoadingUtility.hide();
      return;
    }

    try {
      final requestData = {
        "name": name,
        "radius": radius,
        "cut_off_date": cutOffDate,
        "amount_of_annual_leave": amountOfAnnualLeave,
        "work_schedule": workSchedule,
        "theme": theme,
        "logo": _imagePath ?? "images/default-logo.png",
        "latitude": office.latitude,
        "longitude": office.longitude,
        "updated_by": user.id,
      };

      UpdateOfficeConfigResponse response = await OfficeConfigService()
          .updateConfig(requestData, office.id!.toString(), token);

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

      OfficeConfigProvider? up =
          Provider.of<OfficeConfigProvider>(context, listen: false);

      up.officeConfig = response.data;
    } catch (e) {
      LoadingUtility.hide();
      AmessageUtility.show(
        context,
        "Gagal",
        e.toString(),
        TipType.ERROR,
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Pengaturan Kantor"),
        backgroundColor: ColorConstant.lightPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 150.0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        await pickImage();
                      },
                      child: _imagePath != null
                          ? officeLogo(_imagePath)
                          : Consumer<OfficeConfigProvider>(
                              builder: (context, officeConfig, _) => officeLogo(
                                officeConfig.officeConfig?.logo,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama',
                        errorText: _nameErrorText,
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
                    TextField(
                      controller: _radiusController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Radius (Meter)',
                        errorText: _radiusErrorText,
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
                    TextField(
                      controller: _cutOffDateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cut Off Date',
                        errorText: _cutOffDateErrorText,
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
                    TextField(
                      controller: _amountOfAnnualLeaveController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount Of Annual Leave',
                        errorText: _amountOfAnnualLeaveErrorText,
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
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _startTimeController,
                            readOnly: true,
                            onTap: () => _selectStartTime(context),
                            decoration: InputDecoration(
                              labelText: 'Jam Masuk',
                              errorText: _startTimeErrorText,
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
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _endTimeController,
                            readOnly: true,
                            onTap: () => _selectEndTime(context),
                            decoration: InputDecoration(
                              labelText: 'Jam Pulang',
                              errorText: _endTimeErrorText,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Tema Aplikasi',
                        errorText: _themeErrorText,
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
                      alignment: Alignment.topCenter,
                      value: _themeController.text,
                      items: [_themeController.text]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {},
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstant.lightPrimary,
                        minimumSize: const Size.fromHeight(50), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async {
                        await onUbahPengaturan();
                      },
                      child: const Text(
                        'Ubah pengaturan',
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

Widget officeLogo(String? imagePath) {
  String profilePictureURI =
      "https://sbcf.fr/wp-content/uploads/2018/03/sbcf-default-avatar.png";
  if (imagePath != null) {
    if (imagePath == "images/default-logo.png") {
      profilePictureURI = "${ApiConstant.publicUrl}/$imagePath";
    } else {
      profilePictureURI = "${ApiConstant.baseUrl}/$imagePath";
    }
  }

  return Image.network(
    profilePictureURI,
    width: 200,
  );
}
