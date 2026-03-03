// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSignOut => 'Sign Out';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navTimer => 'Timer';

  @override
  String get navSubjects => 'Subjects';

  @override
  String get subjectRequiredTitle => 'Add a subject first';

  @override
  String get subjectRequiredMessage =>
      'Please add a subject before creating a task.';

  @override
  String get subjectRequiredAction => 'Go to Subjects';

  @override
  String get taskCreateBlockedNoAuth =>
      'Please sign in again before creating a task.';

  @override
  String get timerSubjectRequiredDescription =>
      'Timer sessions must be linked to a subject.';

  @override
  String get timerGoToSubjectsSnack => 'Opening Subjects...';

  @override
  String dashboardGreeting(Object name) {
    return 'Hi, $name';
  }

  @override
  String dashboardLoadFailed(Object error) {
    return 'Failed to load dashboard.\\n$error';
  }

  @override
  String get dashboardTodoLabel => 'To Do';

  @override
  String get dashboardDoingLabel => 'Doing';

  @override
  String get dashboardDoneLabel => 'Done';

  @override
  String dashboardDoneProgress(int done, int total) {
    return '$done / $total done';
  }

  @override
  String get dashboardQuickActionsTitle => 'Quick Actions';

  @override
  String get dashboardActionNewTask => 'New Task';

  @override
  String get dashboardActionSubjects => 'Subjects';

  @override
  String get dashboardActionTimer => 'Timer';

  @override
  String dashboardSummaryLine(int subjects, int pomodoros, Object studyTime) {
    return '$subjects subjects • $pomodoros pomodoros • $studyTime';
  }

  @override
  String get dashboardActiveTasksTitle => 'Active Tasks';

  @override
  String get dashboardAllCaughtUp => 'All caught up!';

  @override
  String get dashboardNoActiveTasks =>
      'No active tasks. Create one to get started.';

  @override
  String get dashboardCreateTask => 'Create Task';

  @override
  String get dashboardViewAllTasks => 'View all tasks';

  @override
  String get dashboardStatusTodo => 'To Do';

  @override
  String get dashboardStatusDoing => 'Doing';

  @override
  String get dashboardStatusDone => 'Done';

  @override
  String get profileTitle => 'Profile';

  @override
  String profileLoadFailed(Object error) {
    return 'Failed to load profile: $error';
  }

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileSectionPreferences => 'Preferences';

  @override
  String get profileSectionStats => 'Stats';

  @override
  String get profileSectionActions => 'Actions';

  @override
  String get profileSetYourName => 'Set your name';

  @override
  String get profileProviderGoogle => 'Google';

  @override
  String get profileProviderEmailPassword => 'Email / Password';

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get profileTheme => 'Theme';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileStudyDuration => 'Study Duration';

  @override
  String profileStudyDurationSubtitle(int minutes) {
    return '$minutes min per session';
  }

  @override
  String get profileWeekStartsOn => 'Week Starts On';

  @override
  String get profileWeekdayMonday => 'Monday';

  @override
  String get profileWeekdaySaturday => 'Saturday';

  @override
  String get profileWeekdaySunday => 'Sunday';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileLanguageTh => 'Thai';

  @override
  String profileLanguageChanged(Object language) {
    return 'Language changed to $language';
  }

  @override
  String get profileStatStudyTime => 'Study Time';

  @override
  String get profileStatCompleted => 'Completed';

  @override
  String get profileStatJoined => 'Joined';

  @override
  String get profileEditDisplayNameTitle => 'Edit Display Name';

  @override
  String get profileDisplayNameLabel => 'Display Name';

  @override
  String get profileDisplayNameHint => 'Enter your name';

  @override
  String get profileDisplayNameUpdated => 'Display name updated';

  @override
  String profileDisplayNameUpdateFailed(Object error) {
    return 'Failed to update name: $error';
  }

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileDeleteAccountTitle => 'Delete Account';

  @override
  String get profileDeleteAccountMessage =>
      'This action is permanent and cannot be undone. All your data will be deleted.';

  @override
  String get profileDeleteForever => 'Delete Forever';

  @override
  String profileDeleteAccountFailed(Object error) {
    return 'Failed to delete account: $error';
  }

  @override
  String get profileChangeAvatar => 'Change profile photo';

  @override
  String get profileTakePhoto => 'Take Photo';

  @override
  String get profileChooseFromGallery => 'Choose from Gallery';

  @override
  String get profileAvatarUpdated => 'Profile photo updated';

  @override
  String profileAvatarUpdateFailed(Object error) {
    return 'Failed to update profile photo: $error';
  }

  @override
  String get profileChangePassword => 'Change Password';

  @override
  String get profileChangePasswordDescription =>
      'Send reset email to secure password change';

  @override
  String get profileSendResetEmail => 'Send Reset Email';

  @override
  String profilePasswordResetSent(Object email) {
    return 'Password reset email sent to $email';
  }

  @override
  String profilePasswordResetFailed(Object error) {
    return 'Failed to send reset email: $error';
  }

  @override
  String get profileChangePasswordUnavailable =>
      'Password change is only available for email/password accounts.';

  @override
  String get profileChangeEmail => 'Change Email';

  @override
  String get profileChangeEmailDescription =>
      'Re-authenticate, then send verification to new email';

  @override
  String get profileCurrentPasswordLabel => 'Current Password';

  @override
  String get profileNewEmailLabel => 'New Email';

  @override
  String get profileFieldRequired => 'This field is required.';

  @override
  String get profileInvalidEmail => 'Enter a valid email address.';

  @override
  String get profileSendVerificationEmail => 'Send Verification';

  @override
  String profileEmailVerificationSent(Object email) {
    return 'Verification sent to $email. Confirm it to finish changing your email.';
  }

  @override
  String profileEmailChangeFailed(Object error) {
    return 'Failed to start email change: $error';
  }

  @override
  String get profileAuthWrongPassword => 'The current password is incorrect.';

  @override
  String get profileAuthInvalidCredential =>
      'The provided credentials are invalid.';

  @override
  String get profileAuthEmailInUse => 'That email is already in use.';

  @override
  String get profileAuthInvalidEmail => 'The email format is invalid.';

  @override
  String get profileAuthRequiresRecentLogin =>
      'Please sign in again and retry this action.';

  @override
  String get profileAuthNetwork => 'Network error. Please try again.';

  @override
  String get profileAuthTooManyRequests =>
      'Too many attempts. Please wait and retry.';

  @override
  String get profileAuthUserDisabled => 'This account has been disabled.';

  @override
  String profileAuthGeneric(Object code) {
    return 'Auth error: $code';
  }

  @override
  String get profileChangeEmailUnavailable =>
      'Email change with password re-authentication is only available for email/password accounts.';
}
