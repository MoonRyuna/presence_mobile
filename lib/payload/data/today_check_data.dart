import 'dart:convert';

class TodayCheckData {
  String? date;
  bool? isWeekend;
  bool? isHoliday;
  List<String>? holidayTitle;
  bool? isWorkday;
  bool? alreadyCheckIn;
  bool? alreadyCheckOut;
  bool? isAbsence;
  bool? haveOvertime;
  bool? alreadyOvertimeStarted;
  bool? alreadyOvertimeEnded;
  int? countKaryawanActive;
  int? countKaryawanInactive;
  int? submissionPendingAbsence;
  int? submissionPendingOvertime;

  TodayCheckData({
    this.date,
    this.isWeekend,
    this.isHoliday,
    this.holidayTitle,
    this.isWorkday,
    this.alreadyCheckIn,
    this.alreadyCheckOut,
    this.isAbsence,
    this.haveOvertime,
    this.alreadyOvertimeStarted,
    this.alreadyOvertimeEnded,
    this.countKaryawanActive,
    this.countKaryawanInactive,
    this.submissionPendingAbsence,
    this.submissionPendingOvertime,
  });

  factory TodayCheckData.fromJson(Map<String, dynamic> json) {
    return TodayCheckData(
      date: json['date'],
      isWeekend: json['is_weekend'],
      isHoliday: json['is_holiday'],
      holidayTitle: json['holiday_title'] != null
          ? List<String>.from(json['holiday_title'])
          : null,
      isWorkday: json['is_workday'],
      alreadyCheckIn: json['already_check_in'],
      alreadyCheckOut: json['already_check_out'],
      isAbsence: json['is_absence'],
      haveOvertime: json['have_overtime'],
      alreadyOvertimeStarted: json['already_overtime_started'],
      alreadyOvertimeEnded: json['already_overtime_ended'],
      countKaryawanActive: json['count_karyawan_active'],
      countKaryawanInactive: json['count_karyawan_inactive'],
      submissionPendingAbsence: json['submission_pending_absence'],
      submissionPendingOvertime: json['submission_pending_overtime'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['is_weekend'] = isWeekend;
    data['is_holiday'] = isHoliday;
    data['holiday_title'] = holidayTitle;
    data['is_workday'] = isWorkday;
    data['already_check_in'] = alreadyCheckIn;
    data['already_check_out'] = alreadyCheckOut;
    data['is_absence'] = isAbsence;
    data['have_overtime'] = haveOvertime;
    data['already_overtime_started'] = alreadyOvertimeStarted;
    data['already_overtime_ended'] = alreadyOvertimeEnded;
    data['count_karyawan_active'] = countKaryawanActive;
    data['count_karyawan_inactive'] = countKaryawanInactive;
    data['submission_pending_absence'] = submissionPendingAbsence;
    data['submission_pending_overtime'] = submissionPendingOvertime;
    return data;
  }

  String toPlain() {
    return 'TodayCheckData{ date: $date, isWeekend: $isWeekend, isHoliday: $isHoliday, holidayTitle: $holidayTitle, isWorkday: $isWorkday, alreadyCheckIn: $alreadyCheckIn, alreadyCheckOut: $alreadyCheckOut, isAbsence: $isAbsence, haveOvertime: $haveOvertime, alreadyOvertimeStarted: $alreadyOvertimeStarted, alreadyOvertimeEnded: $alreadyOvertimeEnded }';
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
