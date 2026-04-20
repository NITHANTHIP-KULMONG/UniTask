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

  @override
  String get tasksLoading => 'กำลังโหลดงาน...';

  @override
  String tasksLoadFailed(Object error) {
    return 'โหลดงานไม่สำเร็จ\n$error';
  }

  @override
  String get tasksAssignmentsTitle => 'งานที่ได้รับมอบหมาย';

  @override
  String get tasksAssignmentsSubtitle => 'งานและการสอบของคุณ';

  @override
  String tasksSectionToday(int count) {
    return 'วันนี้ $count';
  }

  @override
  String tasksSectionUpcoming(int count) {
    return 'เร็วๆ นี้ $count';
  }

  @override
  String tasksSectionDone(int count) {
    return 'เสร็จสิ้น $count';
  }

  @override
  String get tasksFilterAll => 'ทั้งหมด';

  @override
  String get tasksEmptyTitle => 'ไม่มีงานสำหรับตัวกรองนี้';

  @override
  String get tasksEmptySubtitle => 'พักผ่อนให้สบาย!';

  @override
  String get taskActionEdit => 'แก้ไข';

  @override
  String get taskActionMoveTodo => 'ย้ายไปที่ต้องทำ';

  @override
  String get taskActionMoveDone => 'ย้ายไปที่เสร็จสิ้น';

  @override
  String get taskDeleteTitle => 'ลบงาน';

  @override
  String taskDeleteMessage(Object title) {
    return 'ต้องการลบ \"$title\" หรือไม่? การกระทำนี้ไม่สามารถย้อนกลับได้';
  }

  @override
  String get taskTooltipMarkTodo => 'ทำเครื่องหมายว่าต้องทำ';

  @override
  String get taskTooltipMarkDone => 'ทำเครื่องหมายว่าเสร็จสิ้น';

  @override
  String taskDeleted(Object title) {
    return 'ลบงานแล้ว: $title';
  }

  @override
  String get taskCompleted => 'ทำเครื่องหมายว่าเสร็จสิ้น';

  @override
  String get taskMarkedTodo => 'ทำเครื่องหมายว่าต้องทำ';

  @override
  String get commonUndo => 'เลิกทำ';

  @override
  String get taskTooltipActions => 'การดำเนินการงาน';

  @override
  String get taskBadgeDone => 'เสร็จสิ้น';

  @override
  String get taskBadgeNoDate => 'ไม่มีวันที่';

  @override
  String get taskBadgeToday => 'วันนี้';

  @override
  String get taskBadgeOverdue => 'เลยกำหนด';

  @override
  String get taskBadgeUpcoming => 'กำลังจะมาถึง';

  @override
  String taskSubtitleDue(Object date) {
    return 'ครบกำหนด $date';
  }

  @override
  String get commonAdd => 'เพิ่ม';

  @override
  String get commonMore => 'เพิ่มเติม';

  @override
  String get profileLoading => 'กำลังโหลดโปรไฟล์...';

  @override
  String get profileDeletingAccount => 'กำลังลบบัญชี...';

  @override
  String get profileAccountDeleted => 'ลบบัญชีเรียบร้อยแล้ว';

  @override
  String get profileReauthBeforeDelete => 'โปรดเข้าสู่ระบบใหม่ก่อนลบบัญชี';

  @override
  String profileSignOutFailed(Object error) {
    return 'ออกจากระบบไม่สำเร็จ: $error';
  }

  @override
  String profileDurationSeconds(int seconds) {
    return '$secondsวินาที';
  }

  @override
  String profileDurationHoursMinutes(int hours, int minutes) {
    return '$hoursชม $minutesนาที';
  }

  @override
  String profileDurationMinutes(int minutes) {
    return '$minutesนาที';
  }

  @override
  String profileMinutesOption(int minutes) {
    return '$minutes นาที';
  }

  @override
  String profileMinutesShort(int minutes) {
    return '$minutesนาที';
  }

  @override
  String get subjectsNewSubject => 'วิชาใหม่';

  @override
  String subjectsLoadFailed(Object error) {
    return 'โหลดวิชาไม่สำเร็จ\\n$error';
  }

  @override
  String get subjectsSearchHint => 'ค้นหาวิชา';

  @override
  String get subjectsEmptyTitle => 'ยังไม่มีวิชา';

  @override
  String get subjectsEmptyMessage => 'แตะปุ่ม + เพื่อเพิ่มวิชาแรกของคุณ';

  @override
  String get subjectsNoMatchTitle => 'ไม่พบวิชาที่ตรงกัน';

  @override
  String get subjectsNoMatchMessage => 'ลองใช้คำค้นหาอื่นเพื่อค้นหาวิชาของคุณ';

  @override
  String subjectsAssignmentCount(int count) {
    return '$count งาน';
  }

  @override
  String get subjectsAddTitle => 'เพิ่มวิชา';

  @override
  String get subjectsEditTitle => 'แก้ไขวิชา';

  @override
  String subjectsCreated(Object name) {
    return '\"$name\" ถูกสร้างแล้ว';
  }

  @override
  String subjectsCreateFailed(Object error) {
    return 'สร้างวิชาไม่สำเร็จ: $error';
  }

  @override
  String subjectsUpdated(Object name) {
    return '\"$name\" ถูกอัปเดตแล้ว';
  }

  @override
  String subjectsUpdateFailed(Object error) {
    return 'อัปเดตวิชาไม่สำเร็จ: $error';
  }

  @override
  String get subjectsDeleteTitle => 'ลบวิชา';

  @override
  String subjectsDeleteMessage(Object name) {
    return 'ลบ \"$name\" หรือไม่? การกระทำนี้ไม่สามารถย้อนกลับได้';
  }

  @override
  String subjectsDeleted(Object name) {
    return '\"$name\" ถูกลบแล้ว';
  }

  @override
  String subjectsDeleteFailed(Object error) {
    return 'ลบวิชาไม่สำเร็จ: $error';
  }

  @override
  String get subjectsNameLabel => 'ชื่อวิชา';

  @override
  String get subjectsColorLabel => 'สี';

  @override
  String get taskEditTitle => 'แก้ไขงาน';

  @override
  String get taskEditNotFound => 'ไม่พบงาน';

  @override
  String get taskEditHeader => 'แก้ไขงาน';

  @override
  String get taskEditSubtitle => 'อัปเดตรายละเอียดและบันทึกการเปลี่ยนแปลง';

  @override
  String get taskFormTitleLabel => 'ชื่อเรื่อง';

  @override
  String get taskFormTitleHint => 'ต้องทำอะไรบ้าง?';

  @override
  String get taskFormTitleRequired => 'ต้องระบุชื่อเรื่อง';

  @override
  String get taskFormDescriptionLabel => 'รายละเอียด';

  @override
  String get taskFormDescriptionHint => 'บันทึกเพิ่มเติม (ไม่บังคับ)';

  @override
  String get taskFormSubjectRequired => 'ต้องเลือกวิชา';

  @override
  String get taskFormSelectSubject => 'เลือกวิชา';

  @override
  String get taskFormFutureDateRequired => 'โปรดเลือกวันและเวลาในอนาคต';

  @override
  String taskFormCreateFailed(Object error) {
    return 'สร้างงานไม่สำเร็จ: $error';
  }

  @override
  String get taskFormCreateTaskTitle => 'งานใหม่';

  @override
  String get taskFormNoDueDateTap => 'ไม่มีวันครบกำหนด (แตะเพื่อตั้งค่า)';

  @override
  String get taskFormCreating => 'กำลังสร้าง...';

  @override
  String get taskDueDateLabel => 'วันครบกำหนด';

  @override
  String get taskNoDueDate => 'ไม่มีวันครบกำหนด';

  @override
  String get taskClearDueDate => 'ล้างวันครบกำหนด';

  @override
  String get taskSaving => 'กำลังบันทึก...';

  @override
  String get taskSaveChanges => 'บันทึกการเปลี่ยนแปลง';

  @override
  String taskSaveFailed(Object error) {
    return 'บันทึกการเปลี่ยนแปลงไม่สำเร็จ: $error';
  }

  @override
  String get taskDetailTitle => 'รายละเอียดงาน';

  @override
  String get taskDetailMissing => 'ไม่พบงานนี้แล้ว';

  @override
  String get taskStatusLabel => 'สถานะ';

  @override
  String get taskMovedToTodo => 'ย้ายไปที่ต้องทำแล้ว';

  @override
  String get taskMarkedCompleted => 'ทำเครื่องหมายว่าเสร็จสิ้นแล้ว';

  @override
  String get taskMarkAsTodo => 'ทำเครื่องหมายเป็นต้องทำ';

  @override
  String get taskMarkAsCompleted => 'ทำเครื่องหมายว่าเสร็จสิ้น';

  @override
  String get taskStatusCompleted => 'เสร็จสิ้น';

  @override
  String get taskStatusPending => 'รอดำเนินการ';

  @override
  String get taskStatusInProgress => 'กำลังดำเนินการ';

  @override
  String get timerTooltipSettings => 'การตั้งค่า';

  @override
  String get timerTooltipHistory => 'ประวัติ';

  @override
  String get timerToday => 'วันนี้';

  @override
  String timerDailySummary(int count, Object duration) {
    return 'โพโมโดโร $count รอบ • $duration';
  }

  @override
  String get timerSubjectLabel => 'วิชา';

  @override
  String get timerStartFocus => 'เริ่มโฟกัส';

  @override
  String get timerResume => 'ทำต่อ';

  @override
  String get timerPause => 'พัก';

  @override
  String get timerSkip => 'ข้าม';

  @override
  String get timerReset => 'รีเซ็ต';

  @override
  String get timerSettingsTitle => 'ตั้งค่าตัวจับเวลา';

  @override
  String get timerSettingsWorkMinutesLabel => 'โฟกัส (นาที)';

  @override
  String get timerSettingsShortBreakMinutesLabel => 'พักสั้น (นาที)';

  @override
  String get timerSettingsLongBreakMinutesLabel => 'พักยาว (นาที)';

  @override
  String get timerSettingsRoundsLabel => 'จำนวนรอบก่อนพักยาว';

  @override
  String get timerPhaseReady => 'พร้อม';

  @override
  String get timerPhasePaused => 'หยุดชั่วคราว';

  @override
  String get timerPhaseFocus => 'โฟกัส';

  @override
  String get timerPhaseShortBreak => 'พักสั้น';

  @override
  String get timerPhaseLongBreak => 'พักยาว';

  @override
  String timerDurationHoursMinutes(int hours, int minutes) {
    return '$hoursชม $minutesนาที';
  }

  @override
  String timerDurationMinutesSeconds(int minutes, int seconds) {
    return '$minutesนาที $secondsวินาที';
  }

  @override
  String timerDurationMinutesOnly(int minutes) {
    return '$minutesนาที';
  }

  @override
  String get timerHistoryTitle => 'ประวัติการจับเวลา';

  @override
  String get timerHistoryEmpty =>
      'ยังไม่มีประวัติการเรียน\\nทำโพโมโดโรให้จบเพื่อดูประวัติ';

  @override
  String timerHistorySummary(int count, Object duration) {
    return '$count รอบ • $duration';
  }

  @override
  String get timerHistoryUnknownSubject => 'วิชาไม่ทราบชื่อ';

  @override
  String get profileLanguageCodeEn => 'EN';

  @override
  String get profileLanguageCodeTh => 'TH';

  @override
  String get commonSubmit => 'ส่ง';

  @override
  String get authCheckingSession => 'กำลังตรวจสอบเซสชัน...';

  @override
  String authGenericError(Object error) {
    return 'ข้อผิดพลาดการยืนยันตัวตน: $error';
  }

  @override
  String authUnexpectedError(Object error) {
    return 'เกิดข้อผิดพลาดบางอย่าง\\n$error';
  }

  @override
  String get authUnexpected => 'เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองอีกครั้ง';

  @override
  String get authInvalidCredentials => 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';

  @override
  String get authForgotPassword => 'ลืมรหัสผ่าน?';

  @override
  String get authForgotPasswordTitle => 'ลืมรหัสผ่าน';

  @override
  String get authEmailLabel => 'อีเมล';

  @override
  String get authEmailHintGeneral => 'name@example.com';

  @override
  String get authEmailHintAcademic => 'name@university.edu';

  @override
  String get authEmailRequired => 'จำเป็นต้องกรอกอีเมล';

  @override
  String get authEmailInvalid => 'กรุณากรอกอีเมลให้ถูกต้อง';

  @override
  String get authPasswordLabel => 'รหัสผ่าน';

  @override
  String get authPasswordHint => 'กรอกรหัสผ่านของคุณ';

  @override
  String get authPasswordRequired => 'จำเป็นต้องกรอกรหัสผ่าน';

  @override
  String get authPasswordMinLength => 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';

  @override
  String get authLogin => 'เข้าสู่ระบบ';

  @override
  String get authOr => 'หรือ';

  @override
  String get authContinueWithGoogle => 'ดำเนินการต่อด้วย Google';

  @override
  String get authNoAccountRegister => 'ยังไม่มีบัญชีใช่ไหม? สมัครสมาชิก';

  @override
  String get authWelcomeBack => 'ยินดีต้อนรับกลับ';

  @override
  String get authSignInSubtitle => 'เข้าสู่ระบบเพื่อจัดการงานของคุณต่อ';

  @override
  String get authGoogleSignInFailedGeneric =>
      'เข้าสู่ระบบด้วย Google ไม่สำเร็จ กรุณาลองอีกครั้ง';

  @override
  String get authErrorInvalidEmail => 'รูปแบบอีเมลไม่ถูกต้อง';

  @override
  String get authErrorUserDisabled => 'บัญชีนี้ถูกปิดใช้งาน';

  @override
  String get authErrorTooManyRequests =>
      'พยายามหลายครั้งเกินไป กรุณารอสักครู่แล้วลองใหม่';

  @override
  String authErrorLoginFailed(Object code) {
    return 'เข้าสู่ระบบไม่สำเร็จ ($code) กรุณาลองอีกครั้ง';
  }

  @override
  String get authErrorGooglePopupBlocked =>
      'ป๊อปอัปการเข้าสู่ระบบถูกบล็อก กรุณาอนุญาตป๊อปอัปสำหรับเว็บไซต์นี้';

  @override
  String get authErrorGoogleCancelled => 'ยกเลิกการเข้าสู่ระบบแล้ว';

  @override
  String get authErrorGoogleAccountExists =>
      'มีบัญชีนี้อยู่แล้วโดยใช้วิธีเข้าสู่ระบบอื่น';

  @override
  String authErrorGoogleFailed(Object code) {
    return 'เข้าสู่ระบบด้วย Google ไม่สำเร็จ ($code) กรุณาลองอีกครั้ง';
  }

  @override
  String get authResetLinkSent => 'ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลแล้ว';

  @override
  String get authResetFailedGeneric =>
      'ไม่สามารถส่งอีเมลรีเซ็ตรหัสผ่านได้ กรุณาลองอีกครั้ง';

  @override
  String get authErrorResetUserNotFound => 'ไม่พบบัญชีผู้ใช้นี้';

  @override
  String authErrorResetFailed(Object code) {
    return 'ส่งอีเมลรีเซ็ตรหัสผ่านไม่สำเร็จ ($code)';
  }

  @override
  String get authSendResetEmail => 'ส่งอีเมลรีเซ็ต';

  @override
  String get authResetPasswordTitle => 'รีเซ็ตรหัสผ่านของคุณ';

  @override
  String get authResetPasswordSubtitle =>
      'กรอกอีเมลเพื่อรับลิงก์สำหรับรีเซ็ตรหัสผ่าน';

  @override
  String get registerTitle => 'สร้างบัญชีของคุณ';

  @override
  String get registerSubtitle =>
      'ตั้งค่า UniTask ของคุณให้พร้อมใช้งานภายในไม่ถึงหนึ่งนาที';

  @override
  String get registerPasswordHint => 'อย่างน้อย 6 ตัวอักษร';

  @override
  String get registerConfirmPasswordLabel => 'ยืนยันรหัสผ่าน';

  @override
  String get registerConfirmPasswordHint => 'กรอกรหัสผ่านอีกครั้ง';

  @override
  String get registerConfirmPasswordRequired => 'กรุณายืนยันรหัสผ่าน';

  @override
  String get registerConfirmPasswordMismatch => 'รหัสผ่านไม่ตรงกัน';

  @override
  String get registerCreateAccount => 'สร้างบัญชี';

  @override
  String get registerAlreadyHaveAccount => 'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ';

  @override
  String get registerErrorWeakPassword =>
      'รหัสผ่านไม่ปลอดภัยพอ กรุณาใช้ความยาวอย่างน้อย 6 ตัวอักษร';

  @override
  String get registerErrorEmailAlreadyInUse => 'อีเมลนี้มีบัญชีใช้งานอยู่แล้ว';

  @override
  String get registerErrorOperationNotAllowed =>
      'ระบบปิดการสมัครด้วยอีเมล/รหัสผ่านอยู่ในขณะนี้';

  @override
  String registerErrorFailed(Object code) {
    return 'สมัครสมาชิกไม่สำเร็จ ($code) กรุณาลองอีกครั้ง';
  }

  @override
  String get adminDashboardTitle => 'แดชบอร์ดผู้ดูแลระบบ';

  @override
  String get adminRoleAdmin => 'ผู้ดูแลระบบ';

  @override
  String get adminRoleUser => 'ผู้ใช้';

  @override
  String get adminTabUsers => 'ผู้ใช้';

  @override
  String get adminTabAllTasks => 'งานทั้งหมด';

  @override
  String adminSignedInAs(Object email) {
    return 'เข้าสู่ระบบในชื่อ $email';
  }

  @override
  String adminUsersLoadFailed(Object error) {
    return 'โหลดผู้ใช้ไม่สำเร็จ\\n$error';
  }

  @override
  String get adminUsersEmpty => 'ไม่พบผู้ใช้';

  @override
  String adminTasksLoadFailed(Object error) {
    return 'โหลดงานไม่สำเร็จ\\n$error';
  }

  @override
  String get adminTasksEmpty => 'ไม่พบงาน';

  @override
  String adminTaskOwner(Object ownerPrefix) {
    return 'เจ้าของ: $ownerPrefix…';
  }

  @override
  String get assignmentSelectSubjectError => 'กรุณาเลือกวิชา';

  @override
  String get assignmentTitleRequiredError => 'กรุณากรอกชื่องาน';

  @override
  String get assignmentWeightRangeError => 'น้ำหนักต้องอยู่ระหว่าง 1-100';

  @override
  String get assignmentCreated => 'สร้างงานเรียบร้อยแล้ว';

  @override
  String assignmentCreateFailed(Object error) {
    return 'สร้างงานไม่สำเร็จ: $error';
  }

  @override
  String get assignmentAddTitle => 'เพิ่มงาน';

  @override
  String get assignmentNeedSubjectFirst => 'กรุณาสร้างวิชาก่อน';

  @override
  String get assignmentCreateSubjectAction => 'สร้างวิชา';

  @override
  String get assignmentSubjectLabel => 'วิชา';

  @override
  String get assignmentWeightLabel => 'น้ำหนัก %';

  @override
  String get landingOpenApp => 'เปิดแอป';

  @override
  String get landingBadgeNextGen => 'ประสิทธิภาพยุคใหม่';

  @override
  String get landingHeroTitle => 'จัดการงานของคุณ\\nให้ฉลาดและเร็วขึ้น';

  @override
  String get landingHeroSubtitle =>
      'จัดระเบียบงาน ติดตามความคืบหน้า และไม่พลาดกำหนดส่งด้วยเวิร์กโฟลว์ที่สวยงาม';

  @override
  String get landingStartNow => 'เริ่มเลย';

  @override
  String get landingLearnMore => 'เรียนรู้เพิ่มเติม';

  @override
  String get landingFeatureTaskManagementTitle => 'การจัดการงาน';

  @override
  String get landingFeatureTaskManagementDescription =>
      'สร้างและจัดระเบียบงานได้อย่างมีประสิทธิภาพ';

  @override
  String get landingFeatureRealtimeSyncTitle => 'ซิงก์แบบเรียลไทม์';

  @override
  String get landingFeatureRealtimeSyncDescription =>
      'อัปเดตทันทีบนทุกอุปกรณ์ของคุณ';

  @override
  String get landingFeatureSmartRemindersTitle => 'การแจ้งเตือนอัจฉริยะ';

  @override
  String get landingFeatureSmartRemindersDescription =>
      'ไม่พลาดกำหนดส่งด้วยการแจ้งเตือนที่ชาญฉลาด';

  @override
  String get landingFeaturePremiumUiTitle => 'UI ระดับพรีเมียม';

  @override
  String get landingFeaturePremiumUiDescription =>
      'โฟกัสได้ดีขึ้นด้วยอินเทอร์เฟซที่สะอาดและทันสมัย';

  @override
  String get landingFeaturesTitle => 'ทุกอย่างที่คุณต้องการ';

  @override
  String get landingFeaturesSubtitle =>
      'ฟีเจอร์ทรงพลังเพื่อการทำงานอย่างมีประสิทธิภาพสูงสุด';

  @override
  String get landingShowcaseTitle => 'สวยทั้งภายในและภายนอก';

  @override
  String get landingShowcaseSubtitle =>
      'สัมผัสแอปที่ใช้งานดีพอๆ กับหน้าตาที่สวยงาม';

  @override
  String get landingShowcaseScreenDashboard => 'ภาพรวมแดชบอร์ด';

  @override
  String get landingShowcaseScreenAssignments => 'บอร์ดงาน';

  @override
  String get landingShowcaseScreenFocus => 'โหมดโฟกัส';

  @override
  String get landingFaqQuestionFree => 'แอปนี้ใช้ฟรีไหม?';

  @override
  String get landingFaqAnswerFree => 'ใช่ ฟีเจอร์หลักของ UniTask ใช้งานได้ฟรี';

  @override
  String get landingFaqQuestionSync => 'ซิงก์ข้ามอุปกรณ์ได้ไหม?';

  @override
  String get landingFaqAnswerSync =>
      'ได้ ข้อมูลจะซิงก์แบบเรียลไทม์บนทุกอุปกรณ์';

  @override
  String get landingFaqQuestionOffline => 'ใช้งานออฟไลน์ได้ไหม?';

  @override
  String get landingFaqAnswerOffline =>
      'ได้ คุณสามารถใช้งานออฟไลน์และซิงก์อัตโนมัติเมื่อกลับมาออนไลน์';

  @override
  String get landingFaqTitle => 'คำถามที่พบบ่อย';

  @override
  String get landingFaqSubtitle => 'ทุกสิ่งที่คุณต้องรู้เกี่ยวกับ UniTask';

  @override
  String get landingBottomTitle => 'พร้อมยกระดับประสิทธิภาพของคุณหรือยัง?';

  @override
  String get landingBottomSubtitle =>
      'เข้าร่วมกับผู้ใช้นับพันที่จัดการงานได้อย่างมีประสิทธิภาพ';

  @override
  String get landingPhoneTitleToday => 'วันนี้';

  @override
  String get landingPhoneTaskDesignReview => 'รีวิวดีไซน์';

  @override
  String get landingPhoneTaskDevelopment => 'พัฒนา';

  @override
  String get landingPhoneTaskSyncTeam => 'ซิงก์ทีม';

  @override
  String get landingPhoneNewTask => 'งานใหม่';
}
