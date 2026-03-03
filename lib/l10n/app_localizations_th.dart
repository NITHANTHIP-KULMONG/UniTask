// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get commonCancel => 'ยกเลิก';

  @override
  String get commonSave => 'บันทึก';

  @override
  String get commonRetry => 'ลองใหม่';

  @override
  String get commonDelete => 'ลบ';

  @override
  String get commonSignOut => 'ออกจากระบบ';

  @override
  String get navDashboard => 'แดชบอร์ด';

  @override
  String get navTasks => 'งาน';

  @override
  String get navTimer => 'ตัวจับเวลา';

  @override
  String get navSubjects => 'วิชา';

  @override
  String get subjectRequiredTitle => 'เพิ่มวิชาก่อน';

  @override
  String get subjectRequiredMessage => 'กรุณาเพิ่มวิชาก่อนสร้างงาน';

  @override
  String get subjectRequiredAction => 'ไปที่วิชา';

  @override
  String get taskCreateBlockedNoAuth => 'กรุณาเข้าสู่ระบบใหม่ก่อนสร้างงาน';

  @override
  String get timerSubjectRequiredDescription =>
      'การจับเวลาแต่ละครั้งต้องผูกกับวิชา';

  @override
  String get timerGoToSubjectsSnack => 'กำลังเปิดหน้าวิชา...';

  @override
  String dashboardGreeting(Object name) {
    return 'สวัสดี $name';
  }

  @override
  String dashboardLoadFailed(Object error) {
    return 'โหลดแดชบอร์ดไม่สำเร็จ\\n$error';
  }

  @override
  String get dashboardTodoLabel => 'ต้องทำ';

  @override
  String get dashboardDoingLabel => 'กำลังทำ';

  @override
  String get dashboardDoneLabel => 'เสร็จแล้ว';

  @override
  String dashboardDoneProgress(int done, int total) {
    return 'เสร็จ $done / $total';
  }

  @override
  String get dashboardQuickActionsTitle => 'การทำงานด่วน';

  @override
  String get dashboardActionNewTask => 'งานใหม่';

  @override
  String get dashboardActionSubjects => 'วิชา';

  @override
  String get dashboardActionTimer => 'ตัวจับเวลา';

  @override
  String dashboardSummaryLine(int subjects, int pomodoros, Object studyTime) {
    return '$subjects วิชา • โพโมโดโร $pomodoros รอบ • $studyTime';
  }

  @override
  String get dashboardActiveTasksTitle => 'งานที่กำลังทำ';

  @override
  String get dashboardAllCaughtUp => 'เรียบร้อยทั้งหมด!';

  @override
  String get dashboardNoActiveTasks =>
      'ไม่มีงานที่กำลังทำ สร้างงานใหม่เพื่อเริ่มต้น';

  @override
  String get dashboardCreateTask => 'สร้างงาน';

  @override
  String get dashboardViewAllTasks => 'ดูงานทั้งหมด';

  @override
  String get dashboardStatusTodo => 'ต้องทำ';

  @override
  String get dashboardStatusDoing => 'กำลังทำ';

  @override
  String get dashboardStatusDone => 'เสร็จแล้ว';

  @override
  String get profileTitle => 'โปรไฟล์';

  @override
  String profileLoadFailed(Object error) {
    return 'โหลดโปรไฟล์ไม่สำเร็จ: $error';
  }

  @override
  String get profileSectionAccount => 'บัญชี';

  @override
  String get profileSectionPreferences => 'การตั้งค่า';

  @override
  String get profileSectionStats => 'สถิติ';

  @override
  String get profileSectionActions => 'การดำเนินการ';

  @override
  String get profileSetYourName => 'ตั้งชื่อของคุณ';

  @override
  String get profileProviderGoogle => 'Google';

  @override
  String get profileProviderEmailPassword => 'อีเมล / รหัสผ่าน';

  @override
  String get profileAdminBadge => 'ผู้ดูแลระบบ';

  @override
  String get profileTheme => 'ธีม';

  @override
  String get profileThemeLight => 'สว่าง';

  @override
  String get profileThemeSystem => 'ตามระบบ';

  @override
  String get profileThemeDark => 'มืด';

  @override
  String get profileStudyDuration => 'ระยะเวลาเรียน';

  @override
  String profileStudyDurationSubtitle(int minutes) {
    return '$minutes นาทีต่อรอบ';
  }

  @override
  String get profileWeekStartsOn => 'วันเริ่มสัปดาห์';

  @override
  String get profileWeekdayMonday => 'วันจันทร์';

  @override
  String get profileWeekdaySaturday => 'วันเสาร์';

  @override
  String get profileWeekdaySunday => 'วันอาทิตย์';

  @override
  String get profileLanguage => 'ภาษา';

  @override
  String get profileLanguageEn => 'อังกฤษ';

  @override
  String get profileLanguageTh => 'ไทย';

  @override
  String profileLanguageChanged(Object language) {
    return 'เปลี่ยนภาษาเป็น $language';
  }

  @override
  String get profileStatStudyTime => 'เวลาเรียน';

  @override
  String get profileStatCompleted => 'เสร็จสิ้น';

  @override
  String get profileStatJoined => 'เริ่มใช้';

  @override
  String get profileEditDisplayNameTitle => 'แก้ไขชื่อที่แสดง';

  @override
  String get profileDisplayNameLabel => 'ชื่อที่แสดง';

  @override
  String get profileDisplayNameHint => 'ใส่ชื่อของคุณ';

  @override
  String get profileDisplayNameUpdated => 'อัปเดตชื่อเรียบร้อยแล้ว';

  @override
  String profileDisplayNameUpdateFailed(Object error) {
    return 'อัปเดตชื่อไม่สำเร็จ: $error';
  }

  @override
  String get profileDeleteAccount => 'ลบบัญชี';

  @override
  String get profileDeleteAccountTitle => 'ลบบัญชี';

  @override
  String get profileDeleteAccountMessage =>
      'การดำเนินการนี้ถาวรและไม่สามารถยกเลิกได้ ข้อมูลทั้งหมดของคุณจะถูกลบ';

  @override
  String get profileDeleteForever => 'ลบถาวร';

  @override
  String profileDeleteAccountFailed(Object error) {
    return 'ลบบัญชีไม่สำเร็จ: $error';
  }

  @override
  String get profileChangeAvatar => 'เปลี่ยนรูปโปรไฟล์';

  @override
  String get profileTakePhoto => 'ถ่ายรูป';

  @override
  String get profileChooseFromGallery => 'เลือกจากคลังรูป';

  @override
  String get profileAvatarUpdated => 'อัปเดตรูปโปรไฟล์แล้ว';

  @override
  String profileAvatarUpdateFailed(Object error) {
    return 'อัปเดตรูปโปรไฟล์ไม่สำเร็จ: $error';
  }

  @override
  String get profileChangePassword => 'เปลี่ยนรหัสผ่าน';

  @override
  String get profileChangePasswordDescription =>
      'ส่งอีเมลรีเซ็ตรหัสผ่านเพื่อเปลี่ยนอย่างปลอดภัย';

  @override
  String get profileSendResetEmail => 'ส่งอีเมลรีเซ็ต';

  @override
  String profilePasswordResetSent(Object email) {
    return 'ส่งอีเมลรีเซ็ตรหัสผ่านไปที่ $email แล้ว';
  }

  @override
  String profilePasswordResetFailed(Object error) {
    return 'ส่งอีเมลรีเซ็ตไม่สำเร็จ: $error';
  }

  @override
  String get profileChangePasswordUnavailable =>
      'การเปลี่ยนรหัสผ่านใช้ได้เฉพาะบัญชีอีเมล/รหัสผ่านเท่านั้น';

  @override
  String get profileChangeEmail => 'เปลี่ยนอีเมล';

  @override
  String get profileChangeEmailDescription =>
      'ยืนยันตัวตนอีกครั้ง แล้วส่งอีเมลยืนยันไปยังอีเมลใหม่';

  @override
  String get profileCurrentPasswordLabel => 'รหัสผ่านปัจจุบัน';

  @override
  String get profileNewEmailLabel => 'อีเมลใหม่';

  @override
  String get profileFieldRequired => 'จำเป็นต้องกรอกข้อมูล';

  @override
  String get profileInvalidEmail => 'กรุณากรอกอีเมลให้ถูกต้อง';

  @override
  String get profileSendVerificationEmail => 'ส่งอีเมลยืนยัน';

  @override
  String profileEmailVerificationSent(Object email) {
    return 'ส่งอีเมลยืนยันไปที่ $email แล้ว กรุณายืนยันเพื่อเปลี่ยนอีเมลให้เสร็จสมบูรณ์';
  }

  @override
  String profileEmailChangeFailed(Object error) {
    return 'เริ่มการเปลี่ยนอีเมลไม่สำเร็จ: $error';
  }

  @override
  String get profileAuthWrongPassword => 'รหัสผ่านปัจจุบันไม่ถูกต้อง';

  @override
  String get profileAuthInvalidCredential => 'ข้อมูลยืนยันตัวตนไม่ถูกต้อง';

  @override
  String get profileAuthEmailInUse => 'อีเมลนี้ถูกใช้งานแล้ว';

  @override
  String get profileAuthInvalidEmail => 'รูปแบบอีเมลไม่ถูกต้อง';

  @override
  String get profileAuthRequiresRecentLogin =>
      'กรุณาเข้าสู่ระบบใหม่แล้วลองอีกครั้ง';

  @override
  String get profileAuthNetwork => 'เครือข่ายมีปัญหา กรุณาลองอีกครั้ง';

  @override
  String get profileAuthTooManyRequests =>
      'ลองบ่อยเกินไป กรุณารอสักครู่แล้วลองใหม่';

  @override
  String get profileAuthUserDisabled => 'บัญชีนี้ถูกปิดใช้งาน';

  @override
  String profileAuthGeneric(Object code) {
    return 'ข้อผิดพลาดการยืนยันตัวตน: $code';
  }

  @override
  String get profileChangeEmailUnavailable =>
      'การเปลี่ยนอีเมลแบบยืนยันด้วยรหัสผ่านใช้ได้เฉพาะบัญชีอีเมล/รหัสผ่านเท่านั้น';
}
