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

  /// No description provided for @tasksLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading tasks...'**
  String get tasksLoading;

  /// No description provided for @tasksLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tasks.\n{error}'**
  String tasksLoadFailed(Object error);

  /// No description provided for @tasksAssignmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get tasksAssignmentsTitle;

  /// No description provided for @tasksAssignmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your assignments and exams'**
  String get tasksAssignmentsSubtitle;

  /// No description provided for @tasksSectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today {count}'**
  String tasksSectionToday(int count);

  /// No description provided for @tasksSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming {count}'**
  String tasksSectionUpcoming(int count);

  /// No description provided for @tasksSectionDone.
  ///
  /// In en, this message translates to:
  /// **'Done {count}'**
  String tasksSectionDone(int count);

  /// No description provided for @tasksFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tasksFilterAll;

  /// No description provided for @tasksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this filter.'**
  String get tasksEmptyTitle;

  /// No description provided for @tasksEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your free time!'**
  String get tasksEmptySubtitle;

  /// No description provided for @taskActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get taskActionEdit;

  /// No description provided for @taskActionMoveTodo.
  ///
  /// In en, this message translates to:
  /// **'Move to To Do'**
  String get taskActionMoveTodo;

  /// No description provided for @taskActionMoveDone.
  ///
  /// In en, this message translates to:
  /// **'Move to Done'**
  String get taskActionMoveDone;

  /// No description provided for @taskDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get taskDeleteTitle;

  /// No description provided for @taskDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This cannot be undone.'**
  String taskDeleteMessage(Object title);

  /// No description provided for @taskTooltipMarkTodo.
  ///
  /// In en, this message translates to:
  /// **'Mark as to-do'**
  String get taskTooltipMarkTodo;

  /// No description provided for @taskTooltipMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get taskTooltipMarkDone;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted: {title}'**
  String taskDeleted(Object title);

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get taskCompleted;

  /// No description provided for @taskMarkedTodo.
  ///
  /// In en, this message translates to:
  /// **'Task marked as to-do'**
  String get taskMarkedTodo;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get commonUndo;

  /// No description provided for @taskTooltipActions.
  ///
  /// In en, this message translates to:
  /// **'Task actions'**
  String get taskTooltipActions;

  /// No description provided for @taskBadgeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskBadgeDone;

  /// No description provided for @taskBadgeNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get taskBadgeNoDate;

  /// No description provided for @taskBadgeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get taskBadgeToday;

  /// No description provided for @taskBadgeOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get taskBadgeOverdue;

  /// No description provided for @taskBadgeUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get taskBadgeUpcoming;

  /// No description provided for @taskSubtitleDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String taskSubtitleDue(Object date);

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get commonMore;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get profileLoading;

  /// No description provided for @profileDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get profileDeletingAccount;

  /// No description provided for @profileAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get profileAccountDeleted;

  /// No description provided for @profileReauthBeforeDelete.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again before deleting your account.'**
  String get profileReauthBeforeDelete;

  /// No description provided for @profileSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed: {error}'**
  String profileSignOutFailed(Object error);

  /// No description provided for @profileDurationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String profileDurationSeconds(int seconds);

  /// No description provided for @profileDurationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String profileDurationHoursMinutes(int hours, int minutes);

  /// No description provided for @profileDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String profileDurationMinutes(int minutes);

  /// No description provided for @profileMinutesOption.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String profileMinutesOption(int minutes);

  /// No description provided for @profileMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String profileMinutesShort(int minutes);

  /// No description provided for @subjectsNewSubject.
  ///
  /// In en, this message translates to:
  /// **'New Subject'**
  String get subjectsNewSubject;

  /// No description provided for @subjectsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subjects.\\n{error}'**
  String subjectsLoadFailed(Object error);

  /// No description provided for @subjectsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search subjects'**
  String get subjectsSearchHint;

  /// No description provided for @subjectsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No subjects yet'**
  String get subjectsEmptyTitle;

  /// No description provided for @subjectsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first subject.'**
  String get subjectsEmptyMessage;

  /// No description provided for @subjectsNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching subjects'**
  String get subjectsNoMatchTitle;

  /// No description provided for @subjectsNoMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword to find your subject.'**
  String get subjectsNoMatchMessage;

  /// No description provided for @subjectsAssignmentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No assignments} one{1 assignment} other{{count} assignments}}'**
  String subjectsAssignmentCount(int count);

  /// No description provided for @subjectsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Subject'**
  String get subjectsAddTitle;

  /// No description provided for @subjectsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Subject'**
  String get subjectsEditTitle;

  /// No description provided for @subjectsCreated.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" created'**
  String subjectsCreated(Object name);

  /// No description provided for @subjectsCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create subject: {error}'**
  String subjectsCreateFailed(Object error);

  /// No description provided for @subjectsUpdated.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" updated'**
  String subjectsUpdated(Object name);

  /// No description provided for @subjectsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update subject: {error}'**
  String subjectsUpdateFailed(Object error);

  /// No description provided for @subjectsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Subject'**
  String get subjectsDeleteTitle;

  /// No description provided for @subjectsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String subjectsDeleteMessage(Object name);

  /// No description provided for @subjectsDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted'**
  String subjectsDeleted(Object name);

  /// No description provided for @subjectsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete subject: {error}'**
  String subjectsDeleteFailed(Object error);

  /// No description provided for @subjectsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject name'**
  String get subjectsNameLabel;

  /// No description provided for @subjectsColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get subjectsColorLabel;

  /// No description provided for @taskEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Assignment'**
  String get taskEditTitle;

  /// No description provided for @taskEditNotFound.
  ///
  /// In en, this message translates to:
  /// **'Task not found.'**
  String get taskEditNotFound;

  /// No description provided for @taskEditHeader.
  ///
  /// In en, this message translates to:
  /// **'Edit assignment'**
  String get taskEditHeader;

  /// No description provided for @taskEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update details and save changes.'**
  String get taskEditSubtitle;

  /// No description provided for @taskFormTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskFormTitleLabel;

  /// No description provided for @taskFormTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What needs to be done?'**
  String get taskFormTitleHint;

  /// No description provided for @taskFormTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required.'**
  String get taskFormTitleRequired;

  /// No description provided for @taskFormDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskFormDescriptionLabel;

  /// No description provided for @taskFormDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Optional notes'**
  String get taskFormDescriptionHint;

  /// No description provided for @taskFormSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Subject is required.'**
  String get taskFormSubjectRequired;

  /// No description provided for @taskFormSelectSubject.
  ///
  /// In en, this message translates to:
  /// **'Select Subject'**
  String get taskFormSelectSubject;

  /// No description provided for @taskFormFutureDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a future date and time.'**
  String get taskFormFutureDateRequired;

  /// No description provided for @taskFormCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create task: {error}'**
  String taskFormCreateFailed(Object error);

  /// No description provided for @taskFormCreateTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get taskFormCreateTaskTitle;

  /// No description provided for @taskFormNoDueDateTap.
  ///
  /// In en, this message translates to:
  /// **'No due date (Tap to set)'**
  String get taskFormNoDueDateTap;

  /// No description provided for @taskFormCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get taskFormCreating;

  /// No description provided for @taskDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get taskDueDateLabel;

  /// No description provided for @taskNoDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get taskNoDueDate;

  /// No description provided for @taskClearDueDate.
  ///
  /// In en, this message translates to:
  /// **'Clear due date'**
  String get taskClearDueDate;

  /// No description provided for @taskSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get taskSaving;

  /// No description provided for @taskSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get taskSaveChanges;

  /// No description provided for @taskSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes: {error}'**
  String taskSaveFailed(Object error);

  /// No description provided for @taskDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignment Detail'**
  String get taskDetailTitle;

  /// No description provided for @taskDetailMissing.
  ///
  /// In en, this message translates to:
  /// **'Task no longer exists.'**
  String get taskDetailMissing;

  /// No description provided for @taskStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get taskStatusLabel;

  /// No description provided for @taskMovedToTodo.
  ///
  /// In en, this message translates to:
  /// **'Moved to To Do'**
  String get taskMovedToTodo;

  /// No description provided for @taskMarkedCompleted.
  ///
  /// In en, this message translates to:
  /// **'Marked as completed'**
  String get taskMarkedCompleted;

  /// No description provided for @taskMarkAsTodo.
  ///
  /// In en, this message translates to:
  /// **'Mark as To Do'**
  String get taskMarkAsTodo;

  /// No description provided for @taskMarkAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get taskMarkAsCompleted;

  /// No description provided for @taskStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskStatusCompleted;

  /// No description provided for @taskStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskStatusPending;

  /// No description provided for @taskStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get taskStatusInProgress;

  /// No description provided for @timerTooltipSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get timerTooltipSettings;

  /// No description provided for @timerTooltipHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get timerTooltipHistory;

  /// No description provided for @timerToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timerToday;

  /// No description provided for @timerDailySummary.
  ///
  /// In en, this message translates to:
  /// **'{count} pomodoros • {duration}'**
  String timerDailySummary(int count, Object duration);

  /// No description provided for @timerSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get timerSubjectLabel;

  /// No description provided for @timerStartFocus.
  ///
  /// In en, this message translates to:
  /// **'Start Focus'**
  String get timerStartFocus;

  /// No description provided for @timerResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get timerResume;

  /// No description provided for @timerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timerPause;

  /// No description provided for @timerSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get timerSkip;

  /// No description provided for @timerReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get timerReset;

  /// No description provided for @timerSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer Settings'**
  String get timerSettingsTitle;

  /// No description provided for @timerSettingsWorkMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Work (min)'**
  String get timerSettingsWorkMinutesLabel;

  /// No description provided for @timerSettingsShortBreakMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Short break (min)'**
  String get timerSettingsShortBreakMinutesLabel;

  /// No description provided for @timerSettingsLongBreakMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Long break (min)'**
  String get timerSettingsLongBreakMinutesLabel;

  /// No description provided for @timerSettingsRoundsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rounds before long break'**
  String get timerSettingsRoundsLabel;

  /// No description provided for @timerPhaseReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get timerPhaseReady;

  /// No description provided for @timerPhasePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get timerPhasePaused;

  /// No description provided for @timerPhaseFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus Time'**
  String get timerPhaseFocus;

  /// No description provided for @timerPhaseShortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get timerPhaseShortBreak;

  /// No description provided for @timerPhaseLongBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get timerPhaseLongBreak;

  /// No description provided for @timerDurationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String timerDurationHoursMinutes(int hours, int minutes);

  /// No description provided for @timerDurationMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String timerDurationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @timerDurationMinutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String timerDurationMinutesOnly(int minutes);

  /// No description provided for @timerHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get timerHistoryTitle;

  /// No description provided for @timerHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No study sessions yet.\\nComplete a Pomodoro to see history.'**
  String get timerHistoryEmpty;

  /// No description provided for @timerHistorySummary.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions • {duration}'**
  String timerHistorySummary(int count, Object duration);

  /// No description provided for @timerHistoryUnknownSubject.
  ///
  /// In en, this message translates to:
  /// **'Unknown subject'**
  String get timerHistoryUnknownSubject;

  /// No description provided for @profileLanguageCodeEn.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get profileLanguageCodeEn;

  /// No description provided for @profileLanguageCodeTh.
  ///
  /// In en, this message translates to:
  /// **'TH'**
  String get profileLanguageCodeTh;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @authCheckingSession.
  ///
  /// In en, this message translates to:
  /// **'Checking session...'**
  String get authCheckingSession;

  /// No description provided for @authGenericError.
  ///
  /// In en, this message translates to:
  /// **'Auth error: {error}'**
  String authGenericError(Object error);

  /// No description provided for @authUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.\\n{error}'**
  String authUnexpectedError(Object error);

  /// No description provided for @authUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get authUnexpected;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get authInvalidCredentials;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHintGeneral.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get authEmailHintGeneral;

  /// No description provided for @authEmailHintAcademic.
  ///
  /// In en, this message translates to:
  /// **'name@university.edu'**
  String get authEmailHintAcademic;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authPasswordMinLength;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOr;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authNoAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get authNoAccountRegister;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue organizing your work.'**
  String get authSignInSubtitle;

  /// No description provided for @authGoogleSignInFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get authGoogleSignInFailedGeneric;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed ({code}). Please try again.'**
  String authErrorLoginFailed(Object code);

  /// No description provided for @authErrorGooglePopupBlocked.
  ///
  /// In en, this message translates to:
  /// **'Sign-in popup was blocked. Please allow popups for this site.'**
  String get authErrorGooglePopupBlocked;

  /// No description provided for @authErrorGoogleCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get authErrorGoogleCancelled;

  /// No description provided for @authErrorGoogleAccountExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email using a different sign-in method.'**
  String get authErrorGoogleAccountExists;

  /// No description provided for @authErrorGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed ({code}). Please try again.'**
  String authErrorGoogleFailed(Object code);

  /// No description provided for @authResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent to your email'**
  String get authResetLinkSent;

  /// No description provided for @authResetFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to send reset email. Please try again.'**
  String get authResetFailedGeneric;

  /// No description provided for @authErrorResetUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found for this email.'**
  String get authErrorResetUserNotFound;

  /// No description provided for @authErrorResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email ({code}).'**
  String authErrorResetFailed(Object code);

  /// No description provided for @authSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get authSendResetEmail;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link.'**
  String get authResetPasswordSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your UniTask workspace in under a minute.'**
  String get registerSubtitle;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get registerPasswordHint;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get registerConfirmPasswordHint;

  /// No description provided for @registerConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get registerConfirmPasswordRequired;

  /// No description provided for @registerConfirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get registerConfirmPasswordMismatch;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerCreateAccount;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get registerAlreadyHaveAccount;

  /// No description provided for @registerErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 6 characters.'**
  String get registerErrorWeakPassword;

  /// No description provided for @registerErrorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get registerErrorEmailAlreadyInUse;

  /// No description provided for @registerErrorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Email/password sign-up is disabled in the Firebase Console.'**
  String get registerErrorOperationNotAllowed;

  /// No description provided for @registerErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed ({code}). Please try again.'**
  String registerErrorFailed(Object code);

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboardTitle;

  /// No description provided for @adminRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRoleAdmin;

  /// No description provided for @adminRoleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get adminRoleUser;

  /// No description provided for @adminTabUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminTabUsers;

  /// No description provided for @adminTabAllTasks.
  ///
  /// In en, this message translates to:
  /// **'All Tasks'**
  String get adminTabAllTasks;

  /// No description provided for @adminSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String adminSignedInAs(Object email);

  /// No description provided for @adminUsersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load users.\\n{error}'**
  String adminUsersLoadFailed(Object error);

  /// No description provided for @adminUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get adminUsersEmpty;

  /// No description provided for @adminTasksLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tasks.\\n{error}'**
  String adminTasksLoadFailed(Object error);

  /// No description provided for @adminTasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks found.'**
  String get adminTasksEmpty;

  /// No description provided for @adminTaskOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner: {ownerPrefix}…'**
  String adminTaskOwner(Object ownerPrefix);

  /// No description provided for @assignmentSelectSubjectError.
  ///
  /// In en, this message translates to:
  /// **'Please select a subject'**
  String get assignmentSelectSubjectError;

  /// No description provided for @assignmentTitleRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get assignmentTitleRequiredError;

  /// No description provided for @assignmentWeightRangeError.
  ///
  /// In en, this message translates to:
  /// **'Weight must be 1-100'**
  String get assignmentWeightRangeError;

  /// No description provided for @assignmentCreated.
  ///
  /// In en, this message translates to:
  /// **'Assignment created'**
  String get assignmentCreated;

  /// No description provided for @assignmentCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create assignment: {error}'**
  String assignmentCreateFailed(Object error);

  /// No description provided for @assignmentAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Assignment'**
  String get assignmentAddTitle;

  /// No description provided for @assignmentNeedSubjectFirst.
  ///
  /// In en, this message translates to:
  /// **'Please create a subject first.'**
  String get assignmentNeedSubjectFirst;

  /// No description provided for @assignmentCreateSubjectAction.
  ///
  /// In en, this message translates to:
  /// **'Create subject'**
  String get assignmentCreateSubjectAction;

  /// No description provided for @assignmentSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get assignmentSubjectLabel;

  /// No description provided for @assignmentWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight %'**
  String get assignmentWeightLabel;

  /// No description provided for @landingOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open App'**
  String get landingOpenApp;

  /// No description provided for @landingBadgeNextGen.
  ///
  /// In en, this message translates to:
  /// **'Next-Gen Productivity'**
  String get landingBadgeNextGen;

  /// No description provided for @landingHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your tasks\\nsmarter and faster.'**
  String get landingHeroTitle;

  /// No description provided for @landingHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize assignments, track progress, and stay on schedule with a beautiful SaaS workflow.'**
  String get landingHeroSubtitle;

  /// No description provided for @landingStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get landingStartNow;

  /// No description provided for @landingLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get landingLearnMore;

  /// No description provided for @landingFeatureTaskManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Management'**
  String get landingFeatureTaskManagementTitle;

  /// No description provided for @landingFeatureTaskManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Create and organize assignments efficiently.'**
  String get landingFeatureTaskManagementDescription;

  /// No description provided for @landingFeatureRealtimeSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time Sync'**
  String get landingFeatureRealtimeSyncTitle;

  /// No description provided for @landingFeatureRealtimeSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Instant updates across all your devices.'**
  String get landingFeatureRealtimeSyncDescription;

  /// No description provided for @landingFeatureSmartRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Reminders'**
  String get landingFeatureSmartRemindersTitle;

  /// No description provided for @landingFeatureSmartRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Never miss a deadline with intelligent alerts.'**
  String get landingFeatureSmartRemindersDescription;

  /// No description provided for @landingFeaturePremiumUiTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium UI'**
  String get landingFeaturePremiumUiTitle;

  /// No description provided for @landingFeaturePremiumUiDescription.
  ///
  /// In en, this message translates to:
  /// **'Focus better with a clean, modern interface.'**
  String get landingFeaturePremiumUiDescription;

  /// No description provided for @landingFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you need'**
  String get landingFeaturesTitle;

  /// No description provided for @landingFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Powerful features designed for maximum productivity.'**
  String get landingFeaturesSubtitle;

  /// No description provided for @landingShowcaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Beautiful inside out'**
  String get landingShowcaseTitle;

  /// No description provided for @landingShowcaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Experience an app that feels as good as it looks.'**
  String get landingShowcaseSubtitle;

  /// No description provided for @landingShowcaseScreenDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get landingShowcaseScreenDashboard;

  /// No description provided for @landingShowcaseScreenAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignment Board'**
  String get landingShowcaseScreenAssignments;

  /// No description provided for @landingShowcaseScreenFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get landingShowcaseScreenFocus;

  /// No description provided for @landingFaqQuestionFree.
  ///
  /// In en, this message translates to:
  /// **'Is this app free?'**
  String get landingFaqQuestionFree;

  /// No description provided for @landingFaqAnswerFree.
  ///
  /// In en, this message translates to:
  /// **'Yes. UniTask core features are free to use.'**
  String get landingFaqAnswerFree;

  /// No description provided for @landingFaqQuestionSync.
  ///
  /// In en, this message translates to:
  /// **'Does it sync across devices?'**
  String get landingFaqQuestionSync;

  /// No description provided for @landingFaqAnswerSync.
  ///
  /// In en, this message translates to:
  /// **'Yes. Data synchronizes in real-time across all devices.'**
  String get landingFaqAnswerSync;

  /// No description provided for @landingFaqQuestionOffline.
  ///
  /// In en, this message translates to:
  /// **'Can I use it offline?'**
  String get landingFaqQuestionOffline;

  /// No description provided for @landingFaqAnswerOffline.
  ///
  /// In en, this message translates to:
  /// **'Yes. You can work offline and sync automatically when online.'**
  String get landingFaqAnswerOffline;

  /// No description provided for @landingFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Common Questions'**
  String get landingFaqTitle;

  /// No description provided for @landingFaqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to know about UniTask.'**
  String get landingFaqSubtitle;

  /// No description provided for @landingBottomTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to boost your productivity?'**
  String get landingBottomTitle;

  /// No description provided for @landingBottomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of users organizing their tasks efficiently.'**
  String get landingBottomSubtitle;

  /// No description provided for @landingPhoneTitleToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get landingPhoneTitleToday;

  /// No description provided for @landingPhoneTaskDesignReview.
  ///
  /// In en, this message translates to:
  /// **'Design Review'**
  String get landingPhoneTaskDesignReview;

  /// No description provided for @landingPhoneTaskDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get landingPhoneTaskDevelopment;

  /// No description provided for @landingPhoneTaskSyncTeam.
  ///
  /// In en, this message translates to:
  /// **'Sync Team'**
  String get landingPhoneTaskSyncTeam;

  /// No description provided for @landingPhoneNewTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get landingPhoneNewTask;
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
