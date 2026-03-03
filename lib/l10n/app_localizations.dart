import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th')
  ];

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get commonSignOut;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get navTimer;

  /// No description provided for @navSubjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get navSubjects;

  /// No description provided for @subjectRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a subject first'**
  String get subjectRequiredTitle;

  /// No description provided for @subjectRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please add a subject before creating a task.'**
  String get subjectRequiredMessage;

  /// No description provided for @subjectRequiredAction.
  ///
  /// In en, this message translates to:
  /// **'Go to Subjects'**
  String get subjectRequiredAction;

  /// No description provided for @taskCreateBlockedNoAuth.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again before creating a task.'**
  String get taskCreateBlockedNoAuth;

  /// No description provided for @timerSubjectRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'Timer sessions must be linked to a subject.'**
  String get timerSubjectRequiredDescription;

  /// No description provided for @timerGoToSubjectsSnack.
  ///
  /// In en, this message translates to:
  /// **'Opening Subjects...'**
  String get timerGoToSubjectsSnack;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String dashboardGreeting(Object name);

  /// No description provided for @dashboardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard.\\n{error}'**
  String dashboardLoadFailed(Object error);

  /// No description provided for @dashboardTodoLabel.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get dashboardTodoLabel;

  /// No description provided for @dashboardDoingLabel.
  ///
  /// In en, this message translates to:
  /// **'Doing'**
  String get dashboardDoingLabel;

  /// No description provided for @dashboardDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dashboardDoneLabel;

  /// No description provided for @dashboardDoneProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} done'**
  String dashboardDoneProgress(int done, int total);

  /// No description provided for @dashboardQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashboardQuickActionsTitle;

  /// No description provided for @dashboardActionNewTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get dashboardActionNewTask;

  /// No description provided for @dashboardActionSubjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get dashboardActionSubjects;

  /// No description provided for @dashboardActionTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get dashboardActionTimer;

  /// No description provided for @dashboardSummaryLine.
  ///
  /// In en, this message translates to:
  /// **'{subjects} subjects • {pomodoros} pomodoros • {studyTime}'**
  String dashboardSummaryLine(int subjects, int pomodoros, Object studyTime);

  /// No description provided for @dashboardActiveTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Tasks'**
  String get dashboardActiveTasksTitle;

  /// No description provided for @dashboardAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get dashboardAllCaughtUp;

  /// No description provided for @dashboardNoActiveTasks.
  ///
  /// In en, this message translates to:
  /// **'No active tasks. Create one to get started.'**
  String get dashboardNoActiveTasks;

  /// No description provided for @dashboardCreateTask.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get dashboardCreateTask;

  /// No description provided for @dashboardViewAllTasks.
  ///
  /// In en, this message translates to:
  /// **'View all tasks'**
  String get dashboardViewAllTasks;

  /// No description provided for @dashboardStatusTodo.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get dashboardStatusTodo;

  /// No description provided for @dashboardStatusDoing.
  ///
  /// In en, this message translates to:
  /// **'Doing'**
  String get dashboardStatusDoing;

  /// No description provided for @dashboardStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dashboardStatusDone;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {error}'**
  String profileLoadFailed(Object error);

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// No description provided for @profileSectionStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get profileSectionStats;

  /// No description provided for @profileSectionActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get profileSectionActions;

  /// No description provided for @profileSetYourName.
  ///
  /// In en, this message translates to:
  /// **'Set your name'**
  String get profileSetYourName;

  /// No description provided for @profileProviderGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get profileProviderGoogle;

  /// No description provided for @profileProviderEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Email / Password'**
  String get profileProviderEmailPassword;

  /// No description provided for @profileAdminBadge.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get profileAdminBadge;

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileTheme;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileStudyDuration.
  ///
  /// In en, this message translates to:
  /// **'Study Duration'**
  String get profileStudyDuration;

  /// No description provided for @profileStudyDurationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min per session'**
  String profileStudyDurationSubtitle(int minutes);

  /// No description provided for @profileWeekStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Week Starts On'**
  String get profileWeekStartsOn;

  /// No description provided for @profileWeekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get profileWeekdayMonday;

  /// No description provided for @profileWeekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get profileWeekdaySaturday;

  /// No description provided for @profileWeekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get profileWeekdaySunday;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEn;

  /// No description provided for @profileLanguageTh.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get profileLanguageTh;

  /// No description provided for @profileLanguageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String profileLanguageChanged(Object language);

  /// No description provided for @profileStatStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Study Time'**
  String get profileStatStudyTime;

  /// No description provided for @profileStatCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get profileStatCompleted;

  /// No description provided for @profileStatJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get profileStatJoined;

  /// No description provided for @profileEditDisplayNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Display Name'**
  String get profileEditDisplayNameTitle;

  /// No description provided for @profileDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileDisplayNameLabel;

  /// No description provided for @profileDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get profileDisplayNameHint;

  /// No description provided for @profileDisplayNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Display name updated'**
  String get profileDisplayNameUpdated;

  /// No description provided for @profileDisplayNameUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update name: {error}'**
  String profileDisplayNameUpdateFailed(Object error);

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data will be deleted.'**
  String get profileDeleteAccountMessage;

  /// No description provided for @profileDeleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get profileDeleteForever;

  /// No description provided for @profileDeleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {error}'**
  String profileDeleteAccountFailed(Object error);

  /// No description provided for @profileChangeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get profileChangeAvatar;

  /// No description provided for @profileTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get profileTakePhoto;

  /// No description provided for @profileChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get profileChooseFromGallery;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get profileAvatarUpdated;

  /// No description provided for @profileAvatarUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile photo: {error}'**
  String profileAvatarUpdateFailed(Object error);

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @profileChangePasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Send reset email to secure password change'**
  String get profileChangePasswordDescription;

  /// No description provided for @profileSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get profileSendResetEmail;

  /// No description provided for @profilePasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}'**
  String profilePasswordResetSent(Object email);

  /// No description provided for @profilePasswordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email: {error}'**
  String profilePasswordResetFailed(Object error);

  /// No description provided for @profileChangePasswordUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Password change is only available for email/password accounts.'**
  String get profileChangePasswordUnavailable;

  /// No description provided for @profileChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get profileChangeEmail;

  /// No description provided for @profileChangeEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Re-authenticate, then send verification to new email'**
  String get profileChangeEmailDescription;

  /// No description provided for @profileCurrentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get profileCurrentPasswordLabel;

  /// No description provided for @profileNewEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get profileNewEmailLabel;

  /// No description provided for @profileFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get profileFieldRequired;

  /// No description provided for @profileInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get profileInvalidEmail;

  /// No description provided for @profileSendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Verification'**
  String get profileSendVerificationEmail;

  /// No description provided for @profileEmailVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification sent to {email}. Confirm it to finish changing your email.'**
  String profileEmailVerificationSent(Object email);

  /// No description provided for @profileEmailChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start email change: {error}'**
  String profileEmailChangeFailed(Object error);

  /// No description provided for @profileAuthWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'The current password is incorrect.'**
  String get profileAuthWrongPassword;

  /// No description provided for @profileAuthInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'The provided credentials are invalid.'**
  String get profileAuthInvalidCredential;

  /// No description provided for @profileAuthEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'That email is already in use.'**
  String get profileAuthEmailInUse;

  /// No description provided for @profileAuthInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email format is invalid.'**
  String get profileAuthInvalidEmail;

  /// No description provided for @profileAuthRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again and retry this action.'**
  String get profileAuthRequiresRecentLogin;

  /// No description provided for @profileAuthNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get profileAuthNetwork;

  /// No description provided for @profileAuthTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait and retry.'**
  String get profileAuthTooManyRequests;

  /// No description provided for @profileAuthUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get profileAuthUserDisabled;

  /// No description provided for @profileAuthGeneric.
  ///
  /// In en, this message translates to:
  /// **'Auth error: {code}'**
  String profileAuthGeneric(Object code);

  /// No description provided for @profileChangeEmailUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Email change with password re-authentication is only available for email/password accounts.'**
  String get profileChangeEmailUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
