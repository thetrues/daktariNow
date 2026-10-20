import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('sw'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DaktariNow'**
  String get appName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @navHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get navHowItWorks;

  /// No description provided for @navForDoctors.
  ///
  /// In en, this message translates to:
  /// **'For doctors'**
  String get navForDoctors;

  /// No description provided for @navFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get navFaq;

  /// No description provided for @heroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Verified doctors · Tanzania'**
  String get heroEyebrow;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'See a specialist today, wherever you are.'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat, call or video with verified doctors. Book a time that suits you, get prescriptions and lab requests, and keep your health records in one place.'**
  String get heroSubtitle;

  /// No description provided for @findADoctor.
  ///
  /// In en, this message translates to:
  /// **'Find a doctor'**
  String get findADoctor;

  /// No description provided for @iAmADoctor.
  ///
  /// In en, this message translates to:
  /// **'I\'m a doctor'**
  String get iAmADoctor;

  /// No description provided for @trustVerified.
  ///
  /// In en, this message translates to:
  /// **'Admin-verified doctors'**
  String get trustVerified;

  /// No description provided for @trustTzs.
  ///
  /// In en, this message translates to:
  /// **'Fees shown in TSh'**
  String get trustTzs;

  /// No description provided for @trustPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private & secure'**
  String get trustPrivate;

  /// No description provided for @mockVideoConsultation.
  ///
  /// In en, this message translates to:
  /// **'Video consultation'**
  String get mockVideoConsultation;

  /// No description provided for @mockSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Cardiologist'**
  String get mockSpecialty;

  /// No description provided for @mockWhen.
  ///
  /// In en, this message translates to:
  /// **'Today · 10:30'**
  String get mockWhen;

  /// No description provided for @mockDoctorMessage.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get mockDoctorMessage;

  /// No description provided for @mockPatientMessage.
  ///
  /// In en, this message translates to:
  /// **'Much better, thank you!'**
  String get mockPatientMessage;

  /// No description provided for @mockPrescriptionReady.
  ///
  /// In en, this message translates to:
  /// **'Prescription ready'**
  String get mockPrescriptionReady;

  /// No description provided for @mockVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified doctor'**
  String get mockVerified;

  /// No description provided for @howTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howTitle;

  /// No description provided for @howSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From finding a doctor to getting treatment, in three steps.'**
  String get howSubtitle;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Choose a specialist'**
  String get step1Title;

  /// No description provided for @step1Body.
  ///
  /// In en, this message translates to:
  /// **'Browse by specialty, compare fees and experience, and pick a doctor you trust.'**
  String get step1Body;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Book a time'**
  String get step2Title;

  /// No description provided for @step2Body.
  ///
  /// In en, this message translates to:
  /// **'Pick chat, voice or video and a time slot that works for you.'**
  String get step2Body;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Get care'**
  String get step3Title;

  /// No description provided for @step3Body.
  ///
  /// In en, this message translates to:
  /// **'Consult your doctor, then find prescriptions, lab requests and notes in your records.'**
  String get step3Body;

  /// No description provided for @waysTitle.
  ///
  /// In en, this message translates to:
  /// **'Care the way you want it'**
  String get waysTitle;

  /// No description provided for @waysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every consultation happens in a private room with your doctor.'**
  String get waysSubtitle;

  /// No description provided for @wayChatBody.
  ///
  /// In en, this message translates to:
  /// **'Message your doctor and share photos or reports.'**
  String get wayChatBody;

  /// No description provided for @wayVoiceBody.
  ///
  /// In en, this message translates to:
  /// **'Talk it through when typing isn\'t enough.'**
  String get wayVoiceBody;

  /// No description provided for @wayVideoBody.
  ///
  /// In en, this message translates to:
  /// **'Face-to-face consultation from your phone or computer.'**
  String get wayVideoBody;

  /// No description provided for @specialtiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Specialists for every need'**
  String get specialtiesTitle;

  /// No description provided for @specialtiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From everyday illness to long-term conditions.'**
  String get specialtiesSubtitle;

  /// No description provided for @specGp.
  ///
  /// In en, this message translates to:
  /// **'General practitioner'**
  String get specGp;

  /// No description provided for @specPediatrics.
  ///
  /// In en, this message translates to:
  /// **'Pediatrician'**
  String get specPediatrics;

  /// No description provided for @specGynecology.
  ///
  /// In en, this message translates to:
  /// **'Gynecologist'**
  String get specGynecology;

  /// No description provided for @specCardiology.
  ///
  /// In en, this message translates to:
  /// **'Cardiologist'**
  String get specCardiology;

  /// No description provided for @specDermatology.
  ///
  /// In en, this message translates to:
  /// **'Dermatologist'**
  String get specDermatology;

  /// No description provided for @specDentistry.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get specDentistry;

  /// No description provided for @specPsychiatry.
  ///
  /// In en, this message translates to:
  /// **'Psychiatrist'**
  String get specPsychiatry;

  /// No description provided for @specEnt.
  ///
  /// In en, this message translates to:
  /// **'Ear, nose & throat'**
  String get specEnt;

  /// No description provided for @andManyMore.
  ///
  /// In en, this message translates to:
  /// **'and many more'**
  String get andManyMore;

  /// No description provided for @homeCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Care at home'**
  String get homeCareTitle;

  /// No description provided for @homeCareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When you can\'t come to us, we come to you.'**
  String get homeCareSubtitle;

  /// No description provided for @homeVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor home visit'**
  String get homeVisitTitle;

  /// No description provided for @homeVisitBody.
  ///
  /// In en, this message translates to:
  /// **'A doctor examines you in the comfort of your home.'**
  String get homeVisitBody;

  /// No description provided for @sampleCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Lab sample collection'**
  String get sampleCollectionTitle;

  /// No description provided for @sampleCollectionBody.
  ///
  /// In en, this message translates to:
  /// **'Samples taken at home and sent to the lab.'**
  String get sampleCollectionBody;

  /// No description provided for @nurseVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'Nurse visit'**
  String get nurseVisitTitle;

  /// No description provided for @nurseVisitBody.
  ///
  /// In en, this message translates to:
  /// **'Wound care, injections and check-ups at home.'**
  String get nurseVisitBody;

  /// No description provided for @doctorsBandTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you a doctor?'**
  String get doctorsBandTitle;

  /// No description provided for @doctorsBandBody.
  ///
  /// In en, this message translates to:
  /// **'Join DaktariNow, consult patients from the app or the web, set your own hours and earn for every consultation.'**
  String get doctorsBandBody;

  /// No description provided for @doctorsPoint1.
  ///
  /// In en, this message translates to:
  /// **'Set your own schedule'**
  String get doctorsPoint1;

  /// No description provided for @doctorsPoint2.
  ///
  /// In en, this message translates to:
  /// **'Paid for every consultation'**
  String get doctorsPoint2;

  /// No description provided for @doctorsPoint3.
  ///
  /// In en, this message translates to:
  /// **'Work from your phone or computer'**
  String get doctorsPoint3;

  /// No description provided for @joinAsDoctor.
  ///
  /// In en, this message translates to:
  /// **'Join as a doctor'**
  String get joinAsDoctor;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqTitle;

  /// No description provided for @faq1Q.
  ///
  /// In en, this message translates to:
  /// **'Are the doctors real and qualified?'**
  String get faq1Q;

  /// No description provided for @faq1A.
  ///
  /// In en, this message translates to:
  /// **'Every doctor submits their medical license and ID, and our team checks them before they can see patients.'**
  String get faq1A;

  /// No description provided for @faq2Q.
  ///
  /// In en, this message translates to:
  /// **'How much does a consultation cost?'**
  String get faq2Q;

  /// No description provided for @faq2A.
  ///
  /// In en, this message translates to:
  /// **'Each doctor sets their own fee. You see it in TSh before you book.'**
  String get faq2A;

  /// No description provided for @faq3Q.
  ///
  /// In en, this message translates to:
  /// **'Is my information private?'**
  String get faq3Q;

  /// No description provided for @faq3A.
  ///
  /// In en, this message translates to:
  /// **'Your records are shared only with the doctors you consult, and every connection is encrypted.'**
  String get faq3A;

  /// No description provided for @faq4Q.
  ///
  /// In en, this message translates to:
  /// **'Do I need to install anything?'**
  String get faq4Q;

  /// No description provided for @faq4A.
  ///
  /// In en, this message translates to:
  /// **'No. DaktariNow works in the browser on any phone or computer.'**
  String get faq4A;

  /// No description provided for @faq5Q.
  ///
  /// In en, this message translates to:
  /// **'Is DaktariNow for emergencies?'**
  String get faq5Q;

  /// No description provided for @faq5A.
  ///
  /// In en, this message translates to:
  /// **'No. In an emergency, call 112 or go to the nearest hospital.'**
  String get faq5A;

  /// No description provided for @ctaTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next consultation is a few taps away.'**
  String get ctaTitle;

  /// No description provided for @ctaButton.
  ///
  /// In en, this message translates to:
  /// **'Create a free account'**
  String get ctaButton;

  /// No description provided for @footerTagline.
  ///
  /// In en, this message translates to:
  /// **'Trusted care, wherever you are.'**
  String get footerTagline;

  /// No description provided for @footerContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get footerContact;

  /// No description provided for @footerAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get footerAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @footerEmergency.
  ///
  /// In en, this message translates to:
  /// **'In an emergency, call 112.'**
  String get footerEmergency;

  /// No description provided for @footerCopyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} DaktariNow. All rights reserved.'**
  String footerCopyright(int year);

  /// No description provided for @consultChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get consultChat;

  /// No description provided for @consultVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice call'**
  String get consultVoice;

  /// No description provided for @consultVideo.
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get consultVideo;

  /// No description provided for @consultPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone call'**
  String get consultPhone;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in as a patient or a doctor.'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @noAccountCreate.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create one'**
  String get noAccountCreate;

  /// No description provided for @seededAccounts.
  ///
  /// In en, this message translates to:
  /// **'Seeded test accounts (debug builds only)'**
  String get seededAccounts;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @registerSubtitlePatient.
  ///
  /// In en, this message translates to:
  /// **'Get care from verified specialists.'**
  String get registerSubtitlePatient;

  /// No description provided for @registerSubtitleDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor accounts are reviewed by our team before going live.'**
  String get registerSubtitleDoctor;

  /// No description provided for @iAmAPatient.
  ///
  /// In en, this message translates to:
  /// **'I\'m a patient'**
  String get iAmAPatient;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// No description provided for @atLeast8Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Chars;

  /// No description provided for @loadingSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Loading specialties…'**
  String get loadingSpecialties;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @couldNotLoadSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Could not load specialties'**
  String get couldNotLoadSpecialties;

  /// No description provided for @chooseSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Choose a specialty'**
  String get chooseSpecialty;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Medical license number'**
  String get licenseNumber;

  /// No description provided for @licenseRequired.
  ///
  /// In en, this message translates to:
  /// **'License number is required'**
  String get licenseRequired;

  /// No description provided for @uploadDocsLater.
  ///
  /// In en, this message translates to:
  /// **'You\'ll upload your license and ID after signing up.'**
  String get uploadDocsLater;

  /// No description provided for @submitForVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit for verification'**
  String get submitForVerification;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccountSignIn;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get navAppointments;

  /// No description provided for @navRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get navRecords;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get navPatients;

  /// No description provided for @navEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get navEarnings;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @consultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultation;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get notStarted;

  /// No description provided for @statusBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get statusBooked;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get statusRequested;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @vitalHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get vitalHeartRate;

  /// No description provided for @vitalBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get vitalBloodPressure;

  /// No description provided for @vitalBloodSugar.
  ///
  /// In en, this message translates to:
  /// **'Blood sugar'**
  String get vitalBloodSugar;

  /// No description provided for @vitalWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get vitalWeight;

  /// No description provided for @vitalTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get vitalTemperature;

  /// No description provided for @recordPrescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get recordPrescription;

  /// No description provided for @recordLabReport.
  ///
  /// In en, this message translates to:
  /// **'Lab report'**
  String get recordLabReport;

  /// No description provided for @recordXRay.
  ///
  /// In en, this message translates to:
  /// **'X-ray / scan'**
  String get recordXRay;

  /// No description provided for @recordVaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get recordVaccination;

  /// No description provided for @recordSummary.
  ///
  /// In en, this message translates to:
  /// **'Health summary'**
  String get recordSummary;

  /// No description provided for @recordOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get recordOther;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File is larger than 10 MB.'**
  String get fileTooLarge;

  /// No description provided for @couldNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file.'**
  String get couldNotOpenFile;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach DaktariNow right now. Check your connection and try again.'**
  String get errorOffline;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong ({code})'**
  String errorGeneric(String code);

  /// No description provided for @useAdminConsole.
  ///
  /// In en, this message translates to:
  /// **'Please use the admin console.'**
  String get useAdminConsole;

  /// No description provided for @signInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again'**
  String get signInAgain;

  /// No description provided for @addReading.
  ///
  /// In en, this message translates to:
  /// **'Add reading'**
  String get addReading;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get diastolic;

  /// No description provided for @hintExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. {value}'**
  String hintExample(String value);

  /// No description provided for @hintUpper.
  ///
  /// In en, this message translates to:
  /// **'Upper, e.g. 120'**
  String get hintUpper;

  /// No description provided for @hintLower.
  ///
  /// In en, this message translates to:
  /// **'Lower, e.g. 80'**
  String get hintLower;

  /// No description provided for @whenMeasured.
  ///
  /// In en, this message translates to:
  /// **'When it was measured'**
  String get whenMeasured;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumber;

  /// No description provided for @healthOverview.
  ///
  /// In en, this message translates to:
  /// **'Health overview'**
  String get healthOverview;

  /// No description provided for @upcomingAppointment.
  ///
  /// In en, this message translates to:
  /// **'Upcoming appointment'**
  String get upcomingAppointment;

  /// No description provided for @noUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingAppointments;

  /// No description provided for @findAndBook.
  ///
  /// In en, this message translates to:
  /// **'Find a doctor and book one'**
  String get findAndBook;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name} 👋'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name} 👋'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name} 👋'**
  String greetingEvening(String name);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @searchDoctorsHint.
  ///
  /// In en, this message translates to:
  /// **'Search doctors, specialists...'**
  String get searchDoctorsHint;

  /// No description provided for @trackYourHealth.
  ///
  /// In en, this message translates to:
  /// **'Track your health'**
  String get trackYourHealth;

  /// No description provided for @trackYourHealthBody.
  ///
  /// In en, this message translates to:
  /// **'Add heart rate, blood pressure or sugar readings. Your doctor sees them during consultations.'**
  String get trackYourHealthBody;

  /// No description provided for @noReadingYet.
  ///
  /// In en, this message translates to:
  /// **'No reading yet'**
  String get noReadingYet;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @labTest.
  ///
  /// In en, this message translates to:
  /// **'Lab test'**
  String get labTest;

  /// No description provided for @medicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @careAtHome.
  ///
  /// In en, this message translates to:
  /// **'Care at home'**
  String get careAtHome;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @noUpcomingAppointmentsDot.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments.'**
  String get noUpcomingAppointmentsDot;

  /// No description provided for @noPastAppointments.
  ///
  /// In en, this message translates to:
  /// **'No past appointments.'**
  String get noPastAppointments;

  /// No description provided for @findDoctors.
  ///
  /// In en, this message translates to:
  /// **'Find doctors'**
  String get findDoctors;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noDoctorsMatch.
  ///
  /// In en, this message translates to:
  /// **'No doctors match your search.'**
  String get noDoctorsMatch;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get bookingConfirmed;

  /// No description provided for @bookingConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'{type} with {doctor}\n{when}\nPaid {fee}'**
  String bookingConfirmedBody(
    String type,
    String doctor,
    String when,
    String fee,
  );

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @consultationType.
  ///
  /// In en, this message translates to:
  /// **'Consultation type'**
  String get consultationType;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @noFreeTimes.
  ///
  /// In en, this message translates to:
  /// **'No free times on this day. Try another date.'**
  String get noFreeTimes;

  /// No description provided for @reasonForVisit.
  ///
  /// In en, this message translates to:
  /// **'Reason for visit'**
  String get reasonForVisit;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe your symptoms (optional)'**
  String get reasonHint;

  /// No description provided for @appointmentSummary.
  ///
  /// In en, this message translates to:
  /// **'Appointment summary'**
  String get appointmentSummary;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get dateAndTime;

  /// No description provided for @chooseATime.
  ///
  /// In en, this message translates to:
  /// **'Choose a time'**
  String get chooseATime;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @consultationFee.
  ///
  /// In en, this message translates to:
  /// **'Consultation fee'**
  String get consultationFee;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get bookAppointment;

  /// No description provided for @confirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm & pay {fee}'**
  String confirmAndPay(String fee);

  /// No description provided for @medicalRecords.
  ///
  /// In en, this message translates to:
  /// **'Medical records'**
  String get medicalRecords;

  /// No description provided for @addNewRecord.
  ///
  /// In en, this message translates to:
  /// **'Add new record'**
  String get addNewRecord;

  /// No description provided for @bloodGroupValue.
  ///
  /// In en, this message translates to:
  /// **'Blood {group}'**
  String bloodGroupValue(String group);

  /// No description provided for @allergiesValue.
  ///
  /// In en, this message translates to:
  /// **'Allergies: {list}'**
  String allergiesValue(String list);

  /// No description provided for @editHealthInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit health information'**
  String get editHealthInfo;

  /// No description provided for @noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet. Add lab results, scans or vaccination cards so your doctors can see them.'**
  String get noRecordsYet;

  /// No description provided for @updatedOn.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String updatedOn(String date);

  /// No description provided for @addedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String addedBy(String name);

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes.'**
  String get noNotes;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open {name} ({size})'**
  String openFile(String name, String size);

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get deleteRecord;

  /// No description provided for @addRecord.
  ///
  /// In en, this message translates to:
  /// **'Add record'**
  String get addRecord;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @recordTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Full blood count, March 2026'**
  String get recordTitleHint;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a title'**
  String get addTitle;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @attachPdfOrPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach PDF or photo'**
  String get attachPdfOrPhoto;

  /// No description provided for @removeAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove attachment'**
  String get removeAttachment;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @addPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Add your phone number'**
  String get addPhoneNumber;

  /// No description provided for @professionalProfile.
  ///
  /// In en, this message translates to:
  /// **'Professional profile'**
  String get professionalProfile;

  /// No description provided for @professionalProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Fee, bio, hospital, consultation length'**
  String get professionalProfileHint;

  /// No description provided for @verificationDocuments.
  ///
  /// In en, this message translates to:
  /// **'Verification documents'**
  String get verificationDocuments;

  /// No description provided for @licenseAndId.
  ///
  /// In en, this message translates to:
  /// **'License and ID'**
  String get licenseAndId;

  /// No description provided for @healthInformation.
  ///
  /// In en, this message translates to:
  /// **'Health information'**
  String get healthInformation;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @bloodGroupAllergies.
  ///
  /// In en, this message translates to:
  /// **'Blood group, allergies'**
  String get bloodGroupAllergies;

  /// No description provided for @homeServiceRequests.
  ///
  /// In en, this message translates to:
  /// **'Home service requests'**
  String get homeServiceRequests;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpSupport;

  /// No description provided for @verifiedDoctor.
  ///
  /// In en, this message translates to:
  /// **'Verified doctor'**
  String get verifiedDoctor;

  /// No description provided for @helpBody.
  ///
  /// In en, this message translates to:
  /// **'Questions about bookings, payments or your account? Email us and we will get back to you.'**
  String get helpBody;

  /// No description provided for @medicalEmergency.
  ///
  /// In en, this message translates to:
  /// **'Medical emergency?'**
  String get medicalEmergency;

  /// No description provided for @emergencyDontWait.
  ///
  /// In en, this message translates to:
  /// **'Do not wait for support. Call emergency services.'**
  String get emergencyDontWait;

  /// No description provided for @healthStatus.
  ///
  /// In en, this message translates to:
  /// **'Health status'**
  String get healthStatus;

  /// No description provided for @noReadingsYetFor.
  ///
  /// In en, this message translates to:
  /// **'No {type} readings yet'**
  String noReadingsYetFor(String type);

  /// No description provided for @logReadingsHint.
  ///
  /// In en, this message translates to:
  /// **'Log readings from your own devices so your doctor can see how you are doing.'**
  String get logReadingsHint;

  /// No description provided for @latestOf.
  ///
  /// In en, this message translates to:
  /// **'Latest {type}'**
  String latestOf(String type);

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @readings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get readings;

  /// No description provided for @deleteReading.
  ///
  /// In en, this message translates to:
  /// **'Delete reading'**
  String get deleteReading;

  /// No description provided for @notADiagnosis.
  ///
  /// In en, this message translates to:
  /// **'These are your own readings, not a diagnosis. Talk to a doctor if something looks unusual.'**
  String get notADiagnosis;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterValidPhone;

  /// No description provided for @changeEmailHelp.
  ///
  /// In en, this message translates to:
  /// **'Contact support to change your email.'**
  String get changeEmailHelp;

  /// No description provided for @sharedWithDoctor.
  ///
  /// In en, this message translates to:
  /// **'Shared with your doctor during consultations.'**
  String get sharedWithDoctor;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get bloodGroup;

  /// No description provided for @noneRecorded.
  ///
  /// In en, this message translates to:
  /// **'None recorded'**
  String get noneRecorded;

  /// No description provided for @allergyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Penicillin, peanuts'**
  String get allergyHint;

  /// No description provided for @addAllergy.
  ///
  /// In en, this message translates to:
  /// **'Add allergy'**
  String get addAllergy;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @aboutYou.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get aboutYou;

  /// No description provided for @aboutYouHint.
  ///
  /// In en, this message translates to:
  /// **'What you treat, languages you speak…'**
  String get aboutYouHint;

  /// No description provided for @feeHelper.
  ///
  /// In en, this message translates to:
  /// **'What patients pay per consultation. The platform commission is deducted from it.'**
  String get feeHelper;

  /// No description provided for @enterYourFee.
  ///
  /// In en, this message translates to:
  /// **'Enter your fee'**
  String get enterYourFee;

  /// No description provided for @yearsOfExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get yearsOfExperience;

  /// No description provided for @enter0to70.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 0 to 70'**
  String get enter0to70;

  /// No description provided for @hospitalClinic.
  ///
  /// In en, this message translates to:
  /// **'Hospital / clinic'**
  String get hospitalClinic;

  /// No description provided for @independent.
  ///
  /// In en, this message translates to:
  /// **'Independent'**
  String get independent;

  /// No description provided for @consultationLength.
  ///
  /// In en, this message translates to:
  /// **'Consultation length'**
  String get consultationLength;

  /// No description provided for @docLicense.
  ///
  /// In en, this message translates to:
  /// **'Medical license'**
  String get docLicense;

  /// No description provided for @docNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get docNationalId;

  /// No description provided for @docCertificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get docCertificate;

  /// No description provided for @whatUploading.
  ///
  /// In en, this message translates to:
  /// **'What are you uploading?'**
  String get whatUploading;

  /// No description provided for @docUploaded.
  ///
  /// In en, this message translates to:
  /// **'{type} uploaded'**
  String docUploaded(String type);

  /// No description provided for @uploadDocsIntro.
  ///
  /// In en, this message translates to:
  /// **'Upload your medical license and national ID. Our team checks them before you can accept patients.'**
  String get uploadDocsIntro;

  /// No description provided for @uploadedOn.
  ///
  /// In en, this message translates to:
  /// **'Uploaded {date}'**
  String uploadedOn(String date);

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload document'**
  String get uploadDocument;

  /// No description provided for @fileTypesHint.
  ///
  /// In en, this message translates to:
  /// **'PDF, JPG, PNG or WebP, up to 10 MB.'**
  String get fileTypesHint;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other devices have been signed out.'**
  String get passwordChanged;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @homeServices.
  ///
  /// In en, this message translates to:
  /// **'Home services'**
  String get homeServices;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get myRequests;

  /// No description provided for @homeServicesIntro.
  ///
  /// In en, this message translates to:
  /// **'Care at your door. Request a service and our team will call you to confirm the time.'**
  String get homeServicesIntro;

  /// No description provided for @noHomeServices.
  ///
  /// In en, this message translates to:
  /// **'No home services are available right now.'**
  String get noHomeServices;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @choosePreferredTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a preferred date and time.'**
  String get choosePreferredTime;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent. Our team will call you to confirm.'**
  String get requestSent;

  /// No description provided for @requestService.
  ///
  /// In en, this message translates to:
  /// **'Request service'**
  String get requestService;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This service is no longer available.'**
  String get serviceUnavailable;

  /// No description provided for @requestWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Request · {price}'**
  String requestWithPrice(String price);

  /// No description provided for @whereShouldWeCome.
  ///
  /// In en, this message translates to:
  /// **'Where should we come?'**
  String get whereShouldWeCome;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'House / plot, street, area, city and a landmark'**
  String get addressHint;

  /// No description provided for @enterFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your full address'**
  String get enterFullAddress;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number, e.g. +255 7XX XXX XXX'**
  String get phoneHint;

  /// No description provided for @when.
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get when;

  /// No description provided for @choosePreferredTimeNoDot.
  ///
  /// In en, this message translates to:
  /// **'Choose a preferred date and time'**
  String get choosePreferredTimeNoDot;

  /// No description provided for @notesForTeam.
  ///
  /// In en, this message translates to:
  /// **'Notes for the team (optional)'**
  String get notesForTeam;

  /// No description provided for @notesForTeamHint.
  ///
  /// In en, this message translates to:
  /// **'Who is the patient, symptoms, access instructions…'**
  String get notesForTeamHint;

  /// No description provided for @payWhenConfirmed.
  ///
  /// In en, this message translates to:
  /// **'You pay when the service is confirmed. The price shown is the standard price; the team will tell you about any extra costs first.'**
  String get payWhenConfirmed;

  /// No description provided for @cancelRequestQ.
  ///
  /// In en, this message translates to:
  /// **'Cancel this request?'**
  String get cancelRequestQ;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequest;

  /// No description provided for @myHomeServiceRequests.
  ///
  /// In en, this message translates to:
  /// **'My home service requests'**
  String get myHomeServiceRequests;

  /// No description provided for @noRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequestsYet;

  /// No description provided for @browseHomeServices.
  ///
  /// In en, this message translates to:
  /// **'Browse home services'**
  String get browseHomeServices;

  /// No description provided for @fromDaktariNow.
  ///
  /// In en, this message translates to:
  /// **'From DaktariNow: {note}'**
  String fromDaktariNow(String note);

  /// No description provided for @myMedicines.
  ///
  /// In en, this message translates to:
  /// **'My medicines'**
  String get myMedicines;

  /// No description provided for @noPrescriptionsYet.
  ///
  /// In en, this message translates to:
  /// **'No prescriptions yet'**
  String get noPrescriptionsYet;

  /// No description provided for @noPrescriptionsBody.
  ///
  /// In en, this message translates to:
  /// **'Medicines your doctor prescribes during a consultation appear here.'**
  String get noPrescriptionsBody;

  /// No description provided for @takeAsDirected.
  ///
  /// In en, this message translates to:
  /// **'Take medicines only as your doctor directed. Pharmacies may ask to see this prescription.'**
  String get takeAsDirected;

  /// No description provided for @labTests.
  ///
  /// In en, this message translates to:
  /// **'Lab tests'**
  String get labTests;

  /// No description provided for @noLabTests.
  ///
  /// In en, this message translates to:
  /// **'No lab tests requested'**
  String get noLabTests;

  /// No description provided for @noLabTestsBody.
  ///
  /// In en, this message translates to:
  /// **'When a doctor requests tests for you, they appear here. Upload your results under Records.'**
  String get noLabTestsBody;

  /// No description provided for @requestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by {name} · {date}'**
  String requestedBy(String name, String date);

  /// No description provided for @labToDo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get labToDo;

  /// No description provided for @labSampleCollected.
  ///
  /// In en, this message translates to:
  /// **'Sample collected'**
  String get labSampleCollected;

  /// No description provided for @samplesAtHome.
  ///
  /// In en, this message translates to:
  /// **'Get samples collected at home'**
  String get samplesAtHome;

  /// No description provided for @requestSampleCollection.
  ///
  /// In en, this message translates to:
  /// **'Request home sample collection'**
  String get requestSampleCollection;

  /// No description provided for @dialFromPhone.
  ///
  /// In en, this message translates to:
  /// **'Dial {number} from your phone.'**
  String dialFromPhone(String number);

  /// No description provided for @isThisEmergency.
  ///
  /// In en, this message translates to:
  /// **'Is this an emergency?'**
  String get isThisEmergency;

  /// No description provided for @emergencyBody.
  ///
  /// In en, this message translates to:
  /// **'DaktariNow is not an emergency service. If someone has severe chest pain, trouble breathing, heavy bleeding, a seizure, or is unconscious, call for help now or go to the nearest hospital.'**
  String get emergencyBody;

  /// No description provided for @callNumber.
  ///
  /// In en, this message translates to:
  /// **'Call {number}'**
  String callNumber(String number);

  /// No description provided for @whileYouWait.
  ///
  /// In en, this message translates to:
  /// **'While you wait'**
  String get whileYouWait;

  /// No description provided for @waitStep1.
  ///
  /// In en, this message translates to:
  /// **'Stay with the person and keep them calm.'**
  String get waitStep1;

  /// No description provided for @waitStep2.
  ///
  /// In en, this message translates to:
  /// **'Do not give food or drink if they are drowsy or unconscious.'**
  String get waitStep2;

  /// No description provided for @waitStep3.
  ///
  /// In en, this message translates to:
  /// **'Have their medicines and any medical records ready.'**
  String get waitStep3;

  /// No description provided for @waitStep4.
  ///
  /// In en, this message translates to:
  /// **'Send someone to meet the ambulance if you can.'**
  String get waitStep4;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up'**
  String get allCaughtUp;

  /// No description provided for @allCaughtUpBody.
  ///
  /// In en, this message translates to:
  /// **'Appointment reminders, prescriptions and home-service updates show here.'**
  String get allCaughtUpBody;

  /// No description provided for @notifStarted.
  ///
  /// In en, this message translates to:
  /// **'{doctor} has started your consultation'**
  String notifStarted(String doctor);

  /// No description provided for @tapToJoin.
  ///
  /// In en, this message translates to:
  /// **'Tap to join'**
  String get tapToJoin;

  /// No description provided for @notifUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming: {type} with {doctor}'**
  String notifUpcoming(String type, String doctor);

  /// No description provided for @notifPrescription.
  ///
  /// In en, this message translates to:
  /// **'New prescription from {doctor}'**
  String notifPrescription(String doctor);

  /// No description provided for @notifServiceUpdate.
  ///
  /// In en, this message translates to:
  /// **'{service}: {status}'**
  String notifServiceUpdate(String service, String status);

  /// No description provided for @completeConsultationQ.
  ///
  /// In en, this message translates to:
  /// **'Complete consultation?'**
  String get completeConsultationQ;

  /// No description provided for @completeConsultationBody.
  ///
  /// In en, this message translates to:
  /// **'The chat closes and the fee is released to your wallet. Send any prescription before completing.'**
  String get completeConsultationBody;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @consultationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Consultation completed'**
  String get consultationCompleted;

  /// No description provided for @cancelAppointmentQ.
  ///
  /// In en, this message translates to:
  /// **'Cancel this appointment?'**
  String get cancelAppointmentQ;

  /// No description provided for @refundedInFull.
  ///
  /// In en, this message translates to:
  /// **'You will be refunded in full.'**
  String get refundedInFull;

  /// No description provided for @cancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'Cancel appointment'**
  String get cancelAppointment;

  /// No description provided for @appointmentCancelledRefunded.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled and refunded'**
  String get appointmentCancelledRefunded;

  /// No description provided for @thanksFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get thanksFeedback;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @consultationStarted.
  ///
  /// In en, this message translates to:
  /// **'Consultation started'**
  String get consultationStarted;

  /// No description provided for @endAndComplete.
  ///
  /// In en, this message translates to:
  /// **'End & complete'**
  String get endAndComplete;

  /// No description provided for @rateDoctor.
  ///
  /// In en, this message translates to:
  /// **'Rate doctor'**
  String get rateDoctor;

  /// No description provided for @prescriptionAndLabs.
  ///
  /// In en, this message translates to:
  /// **'Prescription & lab tests'**
  String get prescriptionAndLabs;

  /// No description provided for @tabConsult.
  ///
  /// In en, this message translates to:
  /// **'Consult'**
  String get tabConsult;

  /// No description provided for @tabRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get tabRecords;

  /// No description provided for @tabPrescribe.
  ///
  /// In en, this message translates to:
  /// **'Prescribe'**
  String get tabPrescribe;

  /// No description provided for @scheduledDoctor.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {when}. Press Start when you are ready.'**
  String scheduledDoctor(String when);

  /// No description provided for @scheduledPatient.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {when}. Your doctor will start the session.'**
  String scheduledPatient(String when);

  /// No description provided for @cancelledRefunded.
  ///
  /// In en, this message translates to:
  /// **'Cancelled · refunded'**
  String get cancelledRefunded;

  /// No description provided for @patientFile.
  ///
  /// In en, this message translates to:
  /// **'Patient file'**
  String get patientFile;

  /// No description provided for @reasonValue.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String reasonValue(String reason);

  /// No description provided for @latestReadingsPatient.
  ///
  /// In en, this message translates to:
  /// **'Latest readings (patient-entered)'**
  String get latestReadingsPatient;

  /// No description provided for @noRecordsOnFile.
  ///
  /// In en, this message translates to:
  /// **'No records on file.'**
  String get noRecordsOnFile;

  /// No description provided for @recordsOnlyActive.
  ///
  /// In en, this message translates to:
  /// **'Records are only available during an active consultation.'**
  String get recordsOnlyActive;

  /// No description provided for @accessLogged.
  ///
  /// In en, this message translates to:
  /// **'Access is logged and limited to the duration of this consultation.'**
  String get accessLogged;

  /// No description provided for @howWasConsultation.
  ///
  /// In en, this message translates to:
  /// **'How was your consultation?'**
  String get howWasConsultation;

  /// No description provided for @starsOutOf5.
  ///
  /// In en, this message translates to:
  /// **'{count} of 5 stars'**
  String starsOutOf5(int count);

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @sayHello.
  ///
  /// In en, this message translates to:
  /// **'Say hello to {name} 👋'**
  String sayHello(String name);

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages.'**
  String get noMessages;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message {name}…'**
  String messageHint(String name);

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @chatReadOnly.
  ///
  /// In en, this message translates to:
  /// **'This consultation has ended. Chat is read-only.'**
  String get chatReadOnly;

  /// No description provided for @asDirected.
  ///
  /// In en, this message translates to:
  /// **'As directed'**
  String get asDirected;

  /// No description provided for @sentToPatient.
  ///
  /// In en, this message translates to:
  /// **'Sent to patient'**
  String get sentToPatient;

  /// No description provided for @startToPrescribe.
  ///
  /// In en, this message translates to:
  /// **'Start the consultation to prescribe or request labs.'**
  String get startToPrescribe;

  /// No description provided for @consultationEnded.
  ///
  /// In en, this message translates to:
  /// **'This consultation has ended.'**
  String get consultationEnded;

  /// No description provided for @prescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get prescription;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @medicineStrength.
  ///
  /// In en, this message translates to:
  /// **'Medicine & strength'**
  String get medicineStrength;

  /// No description provided for @dosageHint.
  ///
  /// In en, this message translates to:
  /// **'Dosage, e.g. 1×2'**
  String get dosageHint;

  /// No description provided for @durationHint.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationHint;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get addMedicine;

  /// No description provided for @notesForPatient.
  ///
  /// In en, this message translates to:
  /// **'Notes for the patient (optional)'**
  String get notesForPatient;

  /// No description provided for @alreadyRequested.
  ///
  /// In en, this message translates to:
  /// **'Already requested: {list}'**
  String alreadyRequested(String list);

  /// No description provided for @sendToPatient.
  ///
  /// In en, this message translates to:
  /// **'Send to patient'**
  String get sendToPatient;

  /// No description provided for @labTestsRequested.
  ///
  /// In en, this message translates to:
  /// **'Lab tests requested'**
  String get labTestsRequested;

  /// No description provided for @allowMic.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone access in your browser or phone settings, then turn it on below.'**
  String get allowMic;

  /// No description provided for @allowCamera.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in your browser or phone settings, then turn it on below.'**
  String get allowCamera;

  /// No description provided for @allowMicCamera.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone and camera access in your browser or phone settings, then turn them on below.'**
  String get allowMicCamera;

  /// No description provided for @callConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the call. Check your connection and try again.'**
  String get callConnectFailed;

  /// No description provided for @micBlocked.
  ///
  /// In en, this message translates to:
  /// **'Microphone access was blocked.'**
  String get micBlocked;

  /// No description provided for @cameraBlocked.
  ///
  /// In en, this message translates to:
  /// **'Camera access was blocked.'**
  String get cameraBlocked;

  /// No description provided for @callReady.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are'**
  String get callReady;

  /// No description provided for @callOpensWhenStarted.
  ///
  /// In en, this message translates to:
  /// **'The call opens when the doctor starts the consultation'**
  String get callOpensWhenStarted;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @waitingToJoin.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to join… {elapsed}'**
  String waitingToJoin(String name, String elapsed);

  /// No description provided for @callSpeaking.
  ///
  /// In en, this message translates to:
  /// **'{elapsed} · speaking'**
  String callSpeaking(String elapsed);

  /// No description provided for @callConnected.
  ///
  /// In en, this message translates to:
  /// **'{elapsed} · connected'**
  String callConnected(String elapsed);

  /// No description provided for @callEnded.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get callEnded;

  /// No description provided for @rejoinCall.
  ///
  /// In en, this message translates to:
  /// **'Rejoin call'**
  String get rejoinCall;

  /// No description provided for @joinCall.
  ///
  /// In en, this message translates to:
  /// **'Join call'**
  String get joinCall;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @leaveCall.
  ///
  /// In en, this message translates to:
  /// **'Leave call'**
  String get leaveCall;

  /// No description provided for @goodDay.
  ///
  /// In en, this message translates to:
  /// **'Good day, {name}'**
  String goodDay(String name);

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @earnedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Earned this month'**
  String get earnedThisMonth;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @upcomingConsultations.
  ///
  /// In en, this message translates to:
  /// **'Upcoming consultations'**
  String get upcomingConsultations;

  /// No description provided for @noConsultationsScheduled.
  ///
  /// In en, this message translates to:
  /// **'No consultations scheduled.'**
  String get noConsultationsScheduled;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @myPatients.
  ///
  /// In en, this message translates to:
  /// **'My patients'**
  String get myPatients;

  /// No description provided for @searchPatients.
  ///
  /// In en, this message translates to:
  /// **'Search patients...'**
  String get searchPatients;

  /// No description provided for @noPatientsYet.
  ///
  /// In en, this message translates to:
  /// **'No patients yet.'**
  String get noPatientsYet;

  /// No description provided for @availabilitySaved.
  ///
  /// In en, this message translates to:
  /// **'Availability saved'**
  String get availabilitySaved;

  /// No description provided for @mySchedule.
  ///
  /// In en, this message translates to:
  /// **'My schedule'**
  String get mySchedule;

  /// No description provided for @scheduleHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap an hour to toggle it. Patients only see enabled times.'**
  String get scheduleHelp;

  /// No description provided for @scheduleHelpTz.
  ///
  /// In en, this message translates to:
  /// **'Tap an hour to toggle it. Patients only see enabled times (your timezone: {timezone}).'**
  String scheduleHelpTz(String timezone);

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @payoutRequested.
  ///
  /// In en, this message translates to:
  /// **'Payout requested. An admin will process it soon.'**
  String get payoutRequested;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalance;

  /// No description provided for @inEscrow.
  ///
  /// In en, this message translates to:
  /// **'In escrow: {amount}'**
  String inEscrow(String amount);

  /// No description provided for @payoutPending.
  ///
  /// In en, this message translates to:
  /// **'Payout pending: {amount}'**
  String payoutPending(String amount);

  /// No description provided for @requestPayout.
  ///
  /// In en, this message translates to:
  /// **'Request payout'**
  String get requestPayout;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @completedConsultations.
  ///
  /// In en, this message translates to:
  /// **'Completed consultations'**
  String get completedConsultations;

  /// No description provided for @platformCommission.
  ///
  /// In en, this message translates to:
  /// **'Platform commission'**
  String get platformCommission;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @earningsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Earnings appear here when you complete consultations.'**
  String get earningsAppearHere;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @payoutHelper.
  ///
  /// In en, this message translates to:
  /// **'Available: {available} · minimum {minimum}'**
  String payoutHelper(String available, String minimum);

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get enterAmount;

  /// No description provided for @minimumIs.
  ///
  /// In en, this message translates to:
  /// **'Minimum is {amount}'**
  String minimumIs(String amount);

  /// No description provided for @moreThanAvailable.
  ///
  /// In en, this message translates to:
  /// **'More than available'**
  String get moreThanAvailable;

  /// No description provided for @sendTo.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get sendTo;

  /// No description provided for @sendToHint.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa, Tigo Pesa, Airtel Money or bank'**
  String get sendToHint;

  /// No description provided for @whereSendMoney.
  ///
  /// In en, this message translates to:
  /// **'Where should we send the money?'**
  String get whereSendMoney;

  /// No description provided for @stillUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Still under review.'**
  String get stillUnderReview;

  /// No description provided for @stepAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get stepAccountCreated;

  /// No description provided for @stepUploadDocs.
  ///
  /// In en, this message translates to:
  /// **'Upload license & national ID'**
  String get stepUploadDocs;

  /// No description provided for @stepAdminReview.
  ///
  /// In en, this message translates to:
  /// **'Admin review (1–2 business days)'**
  String get stepAdminReview;

  /// No description provided for @stepStartConsulting.
  ///
  /// In en, this message translates to:
  /// **'Start consulting & earning'**
  String get stepStartConsulting;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @verificationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Verification declined'**
  String get verificationDeclined;

  /// No description provided for @accountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Account suspended'**
  String get accountSuspended;

  /// No description provided for @profileUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Your profile is under review'**
  String get profileUnderReview;

  /// No description provided for @blockedBody.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, please contact support if you think this is a mistake.'**
  String blockedBody(String name);

  /// No description provided for @reviewBody.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, our team verifies every doctor before they can accept consultations. We\'ll let you know when you\'re approved.'**
  String reviewBody(String name);

  /// No description provided for @checkStatus.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get checkStatus;

  /// No description provided for @yourDocuments.
  ///
  /// In en, this message translates to:
  /// **'Your documents'**
  String get yourDocuments;
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
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
