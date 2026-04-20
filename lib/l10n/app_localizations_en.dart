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

  @override
  String get tasksLoading => 'Loading tasks...';

  @override
  String tasksLoadFailed(Object error) {
    return 'Failed to load tasks.\n$error';
  }

  @override
  String get tasksAssignmentsTitle => 'Assignments';

  @override
  String get tasksAssignmentsSubtitle => 'Your assignments and exams';

  @override
  String tasksSectionToday(int count) {
    return 'Today $count';
  }

  @override
  String tasksSectionUpcoming(int count) {
    return 'Upcoming $count';
  }

  @override
  String tasksSectionDone(int count) {
    return 'Done $count';
  }

  @override
  String get tasksFilterAll => 'All';

  @override
  String get tasksEmptyTitle => 'No tasks for this filter.';

  @override
  String get tasksEmptySubtitle => 'Enjoy your free time!';

  @override
  String get taskActionEdit => 'Edit';

  @override
  String get taskActionMoveTodo => 'Move to To Do';

  @override
  String get taskActionMoveDone => 'Move to Done';

  @override
  String get taskDeleteTitle => 'Delete Task';

  @override
  String taskDeleteMessage(Object title) {
    return 'Delete \"$title\"? This cannot be undone.';
  }

  @override
  String get taskTooltipMarkTodo => 'Mark as to-do';

  @override
  String get taskTooltipMarkDone => 'Mark as done';

  @override
  String taskDeleted(Object title) {
    return 'Task deleted: $title';
  }

  @override
  String get taskCompleted => 'Task completed';

  @override
  String get taskMarkedTodo => 'Task marked as to-do';

  @override
  String get commonUndo => 'UNDO';

  @override
  String get taskTooltipActions => 'Task actions';

  @override
  String get taskBadgeDone => 'Done';

  @override
  String get taskBadgeNoDate => 'No date';

  @override
  String get taskBadgeToday => 'Today';

  @override
  String get taskBadgeOverdue => 'Overdue';

  @override
  String get taskBadgeUpcoming => 'Upcoming';

  @override
  String taskSubtitleDue(Object date) {
    return 'Due $date';
  }

  @override
  String get commonAdd => 'Add';

  @override
  String get commonMore => 'More';

  @override
  String get profileLoading => 'Loading profile...';

  @override
  String get profileDeletingAccount => 'Deleting account...';

  @override
  String get profileAccountDeleted => 'Account deleted successfully.';

  @override
  String get profileReauthBeforeDelete =>
      'Please sign in again before deleting your account.';

  @override
  String profileSignOutFailed(Object error) {
    return 'Sign out failed: $error';
  }

  @override
  String profileDurationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String profileDurationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String profileDurationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String profileMinutesOption(int minutes) {
    return '$minutes min';
  }

  @override
  String profileMinutesShort(int minutes) {
    return '${minutes}m';
  }

  @override
  String get subjectsNewSubject => 'New Subject';

  @override
  String subjectsLoadFailed(Object error) {
    return 'Failed to load subjects.\\n$error';
  }

  @override
  String get subjectsSearchHint => 'Search subjects';

  @override
  String get subjectsEmptyTitle => 'No subjects yet';

  @override
  String get subjectsEmptyMessage =>
      'Tap the + button to add your first subject.';

  @override
  String get subjectsNoMatchTitle => 'No matching subjects';

  @override
  String get subjectsNoMatchMessage =>
      'Try a different keyword to find your subject.';

  @override
  String subjectsAssignmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assignments',
      one: '1 assignment',
      zero: 'No assignments',
    );
    return '$_temp0';
  }

  @override
  String get subjectsAddTitle => 'Add Subject';

  @override
  String get subjectsEditTitle => 'Edit Subject';

  @override
  String subjectsCreated(Object name) {
    return '\"$name\" created';
  }

  @override
  String subjectsCreateFailed(Object error) {
    return 'Failed to create subject: $error';
  }

  @override
  String subjectsUpdated(Object name) {
    return '\"$name\" updated';
  }

  @override
  String subjectsUpdateFailed(Object error) {
    return 'Failed to update subject: $error';
  }

  @override
  String get subjectsDeleteTitle => 'Delete Subject';

  @override
  String subjectsDeleteMessage(Object name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String subjectsDeleted(Object name) {
    return '\"$name\" deleted';
  }

  @override
  String subjectsDeleteFailed(Object error) {
    return 'Failed to delete subject: $error';
  }

  @override
  String get subjectsNameLabel => 'Subject name';

  @override
  String get subjectsColorLabel => 'Color';

  @override
  String get taskEditTitle => 'Edit Assignment';

  @override
  String get taskEditNotFound => 'Task not found.';

  @override
  String get taskEditHeader => 'Edit assignment';

  @override
  String get taskEditSubtitle => 'Update details and save changes.';

  @override
  String get taskFormTitleLabel => 'Title';

  @override
  String get taskFormTitleHint => 'What needs to be done?';

  @override
  String get taskFormTitleRequired => 'Title is required.';

  @override
  String get taskFormDescriptionLabel => 'Description';

  @override
  String get taskFormDescriptionHint => 'Optional notes';

  @override
  String get taskFormSubjectRequired => 'Subject is required.';

  @override
  String get taskFormSelectSubject => 'Select Subject';

  @override
  String get taskFormFutureDateRequired =>
      'Please select a future date and time.';

  @override
  String taskFormCreateFailed(Object error) {
    return 'Failed to create task: $error';
  }

  @override
  String get taskFormCreateTaskTitle => 'New Task';

  @override
  String get taskFormNoDueDateTap => 'No due date (Tap to set)';

  @override
  String get taskFormCreating => 'Creating...';

  @override
  String get taskDueDateLabel => 'Due date';

  @override
  String get taskNoDueDate => 'No due date';

  @override
  String get taskClearDueDate => 'Clear due date';

  @override
  String get taskSaving => 'Saving...';

  @override
  String get taskSaveChanges => 'Save Changes';

  @override
  String taskSaveFailed(Object error) {
    return 'Failed to save changes: $error';
  }

  @override
  String get taskDetailTitle => 'Assignment Detail';

  @override
  String get taskDetailMissing => 'Task no longer exists.';

  @override
  String get taskStatusLabel => 'Status';

  @override
  String get taskMovedToTodo => 'Moved to To Do';

  @override
  String get taskMarkedCompleted => 'Marked as completed';

  @override
  String get taskMarkAsTodo => 'Mark as To Do';

  @override
  String get taskMarkAsCompleted => 'Mark as Completed';

  @override
  String get taskStatusCompleted => 'Completed';

  @override
  String get taskStatusPending => 'Pending';

  @override
  String get taskStatusInProgress => 'In progress';

  @override
  String get timerTooltipSettings => 'Settings';

  @override
  String get timerTooltipHistory => 'History';

  @override
  String get timerToday => 'Today';

  @override
  String timerDailySummary(int count, Object duration) {
    return '$count pomodoros • $duration';
  }

  @override
  String get timerSubjectLabel => 'Subject';

  @override
  String get timerStartFocus => 'Start Focus';

  @override
  String get timerResume => 'Resume';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerSkip => 'Skip';

  @override
  String get timerReset => 'Reset';

  @override
  String get timerSettingsTitle => 'Timer Settings';

  @override
  String get timerSettingsWorkMinutesLabel => 'Work (min)';

  @override
  String get timerSettingsShortBreakMinutesLabel => 'Short break (min)';

  @override
  String get timerSettingsLongBreakMinutesLabel => 'Long break (min)';

  @override
  String get timerSettingsRoundsLabel => 'Rounds before long break';

  @override
  String get timerPhaseReady => 'Ready';

  @override
  String get timerPhasePaused => 'Paused';

  @override
  String get timerPhaseFocus => 'Focus Time';

  @override
  String get timerPhaseShortBreak => 'Short Break';

  @override
  String get timerPhaseLongBreak => 'Long Break';

  @override
  String timerDurationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String timerDurationMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String timerDurationMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String get timerHistoryTitle => 'Session History';

  @override
  String get timerHistoryEmpty =>
      'No study sessions yet.\\nComplete a Pomodoro to see history.';

  @override
  String timerHistorySummary(int count, Object duration) {
    return '$count sessions • $duration';
  }

  @override
  String get timerHistoryUnknownSubject => 'Unknown subject';

  @override
  String get profileLanguageCodeEn => 'EN';

  @override
  String get profileLanguageCodeTh => 'TH';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get authCheckingSession => 'Checking session...';

  @override
  String authGenericError(Object error) {
    return 'Auth error: $error';
  }

  @override
  String authUnexpectedError(Object error) {
    return 'Something went wrong.\\n$error';
  }

  @override
  String get authUnexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get authInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authForgotPasswordTitle => 'Forgot Password';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHintGeneral => 'name@example.com';

  @override
  String get authEmailHintAcademic => 'name@university.edu';

  @override
  String get authEmailRequired => 'Email is required.';

  @override
  String get authEmailInvalid => 'Enter a valid email address.';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authPasswordRequired => 'Password is required.';

  @override
  String get authPasswordMinLength => 'Password must be at least 6 characters.';

  @override
  String get authLogin => 'Login';

  @override
  String get authOr => 'OR';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authNoAccountRegister => 'Don\'t have an account? Register';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignInSubtitle => 'Sign in to continue organizing your work.';

  @override
  String get authGoogleSignInFailedGeneric =>
      'Google sign-in failed. Please try again.';

  @override
  String get authErrorInvalidEmail => 'The email address is not valid.';

  @override
  String get authErrorUserDisabled => 'This account has been disabled.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String authErrorLoginFailed(Object code) {
    return 'Login failed ($code). Please try again.';
  }

  @override
  String get authErrorGooglePopupBlocked =>
      'Sign-in popup was blocked. Please allow popups for this site.';

  @override
  String get authErrorGoogleCancelled => 'Sign-in was cancelled.';

  @override
  String get authErrorGoogleAccountExists =>
      'An account already exists with this email using a different sign-in method.';

  @override
  String authErrorGoogleFailed(Object code) {
    return 'Google sign-in failed ($code). Please try again.';
  }

  @override
  String get authResetLinkSent => 'Reset link sent to your email';

  @override
  String get authResetFailedGeneric =>
      'Unable to send reset email. Please try again.';

  @override
  String get authErrorResetUserNotFound => 'No user found for this email.';

  @override
  String authErrorResetFailed(Object code) {
    return 'Failed to send reset email ($code).';
  }

  @override
  String get authSendResetEmail => 'Send Reset Email';

  @override
  String get authResetPasswordTitle => 'Reset your password';

  @override
  String get authResetPasswordSubtitle =>
      'Enter your email to receive a password reset link.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle =>
      'Set up your UniTask workspace in under a minute.';

  @override
  String get registerPasswordHint => 'At least 6 characters';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerConfirmPasswordHint => 'Re-enter your password';

  @override
  String get registerConfirmPasswordRequired => 'Please confirm your password.';

  @override
  String get registerConfirmPasswordMismatch => 'Passwords do not match.';

  @override
  String get registerCreateAccount => 'Create account';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account? Login';

  @override
  String get registerErrorWeakPassword =>
      'Password is too weak. Use at least 6 characters.';

  @override
  String get registerErrorEmailAlreadyInUse =>
      'An account with this email already exists.';

  @override
  String get registerErrorOperationNotAllowed =>
      'Email/password sign-up is disabled in the Firebase Console.';

  @override
  String registerErrorFailed(Object code) {
    return 'Registration failed ($code). Please try again.';
  }

  @override
  String get adminDashboardTitle => 'Admin Dashboard';

  @override
  String get adminRoleAdmin => 'Admin';

  @override
  String get adminRoleUser => 'User';

  @override
  String get adminTabUsers => 'Users';

  @override
  String get adminTabAllTasks => 'All Tasks';

  @override
  String adminSignedInAs(Object email) {
    return 'Signed in as $email';
  }

  @override
  String adminUsersLoadFailed(Object error) {
    return 'Failed to load users.\\n$error';
  }

  @override
  String get adminUsersEmpty => 'No users found.';

  @override
  String adminTasksLoadFailed(Object error) {
    return 'Failed to load tasks.\\n$error';
  }

  @override
  String get adminTasksEmpty => 'No tasks found.';

  @override
  String adminTaskOwner(Object ownerPrefix) {
    return 'Owner: $ownerPrefix…';
  }

  @override
  String get assignmentSelectSubjectError => 'Please select a subject';

  @override
  String get assignmentTitleRequiredError => 'Please enter a title';

  @override
  String get assignmentWeightRangeError => 'Weight must be 1-100';

  @override
  String get assignmentCreated => 'Assignment created';

  @override
  String assignmentCreateFailed(Object error) {
    return 'Failed to create assignment: $error';
  }

  @override
  String get assignmentAddTitle => 'Add Assignment';

  @override
  String get assignmentNeedSubjectFirst => 'Please create a subject first.';

  @override
  String get assignmentCreateSubjectAction => 'Create subject';

  @override
  String get assignmentSubjectLabel => 'Subject';

  @override
  String get assignmentWeightLabel => 'Weight %';

  @override
  String get landingOpenApp => 'Open App';

  @override
  String get landingBadgeNextGen => 'Next-Gen Productivity';

  @override
  String get landingHeroTitle => 'Manage your tasks\\nsmarter and faster.';

  @override
  String get landingHeroSubtitle =>
      'Organize assignments, track progress, and stay on schedule with a beautiful SaaS workflow.';

  @override
  String get landingStartNow => 'Start Now';

  @override
  String get landingLearnMore => 'Learn More';

  @override
  String get landingFeatureTaskManagementTitle => 'Task Management';

  @override
  String get landingFeatureTaskManagementDescription =>
      'Create and organize assignments efficiently.';

  @override
  String get landingFeatureRealtimeSyncTitle => 'Real-time Sync';

  @override
  String get landingFeatureRealtimeSyncDescription =>
      'Instant updates across all your devices.';

  @override
  String get landingFeatureSmartRemindersTitle => 'Smart Reminders';

  @override
  String get landingFeatureSmartRemindersDescription =>
      'Never miss a deadline with intelligent alerts.';

  @override
  String get landingFeaturePremiumUiTitle => 'Premium UI';

  @override
  String get landingFeaturePremiumUiDescription =>
      'Focus better with a clean, modern interface.';

  @override
  String get landingFeaturesTitle => 'Everything you need';

  @override
  String get landingFeaturesSubtitle =>
      'Powerful features designed for maximum productivity.';

  @override
  String get landingShowcaseTitle => 'Beautiful inside out';

  @override
  String get landingShowcaseSubtitle =>
      'Experience an app that feels as good as it looks.';

  @override
  String get landingShowcaseScreenDashboard => 'Dashboard Overview';

  @override
  String get landingShowcaseScreenAssignments => 'Assignment Board';

  @override
  String get landingShowcaseScreenFocus => 'Focus Mode';

  @override
  String get landingFaqQuestionFree => 'Is this app free?';

  @override
  String get landingFaqAnswerFree =>
      'Yes. UniTask core features are free to use.';

  @override
  String get landingFaqQuestionSync => 'Does it sync across devices?';

  @override
  String get landingFaqAnswerSync =>
      'Yes. Data synchronizes in real-time across all devices.';

  @override
  String get landingFaqQuestionOffline => 'Can I use it offline?';

  @override
  String get landingFaqAnswerOffline =>
      'Yes. You can work offline and sync automatically when online.';

  @override
  String get landingFaqTitle => 'Common Questions';

  @override
  String get landingFaqSubtitle => 'Everything you need to know about UniTask.';

  @override
  String get landingBottomTitle => 'Ready to boost your productivity?';

  @override
  String get landingBottomSubtitle =>
      'Join thousands of users organizing their tasks efficiently.';

  @override
  String get landingPhoneTitleToday => 'Today';

  @override
  String get landingPhoneTaskDesignReview => 'Design Review';

  @override
  String get landingPhoneTaskDevelopment => 'Development';

  @override
  String get landingPhoneTaskSyncTeam => 'Sync Team';

  @override
  String get landingPhoneNewTask => 'New Task';
}
