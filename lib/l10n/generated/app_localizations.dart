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
/// import 'generated/app_localizations.dart';
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
    Locale('sw'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In sw, this message translates to:
  /// **'CyberSwahili'**
  String get appTitle;

  /// No description provided for @latestNews.
  ///
  /// In sw, this message translates to:
  /// **'Habari za Hivi Punde'**
  String get latestNews;

  /// No description provided for @categories.
  ///
  /// In sw, this message translates to:
  /// **'Makundi'**
  String get categories;

  /// No description provided for @favorites.
  ///
  /// In sw, this message translates to:
  /// **'Vipendwa'**
  String get favorites;

  /// No description provided for @darkMode.
  ///
  /// In sw, this message translates to:
  /// **'Hali ya Giza'**
  String get darkMode;

  /// No description provided for @settings.
  ///
  /// In sw, this message translates to:
  /// **'Mipangilio'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta'**
  String get search;

  /// No description provided for @noInternet.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna Muunganisho wa Mtandao'**
  String get noInternet;

  /// No description provided for @retry.
  ///
  /// In sw, this message translates to:
  /// **'Jaribu Tena'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In sw, this message translates to:
  /// **'Inapakia...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In sw, this message translates to:
  /// **'Kosa'**
  String get error;

  /// No description provided for @share.
  ///
  /// In sw, this message translates to:
  /// **'Shiriki'**
  String get share;

  /// No description provided for @readMore.
  ///
  /// In sw, this message translates to:
  /// **'Soma Zaidi'**
  String get readMore;

  /// No description provided for @author.
  ///
  /// In sw, this message translates to:
  /// **'Mwandishi'**
  String get author;

  /// No description provided for @published.
  ///
  /// In sw, this message translates to:
  /// **'Imechapishwa'**
  String get published;

  /// No description provided for @updated.
  ///
  /// In sw, this message translates to:
  /// **'Imesasishwa'**
  String get updated;

  /// No description provided for @categoriesTitle.
  ///
  /// In sw, this message translates to:
  /// **'Makundi ya Makala'**
  String get categoriesTitle;

  /// No description provided for @cybersecurity.
  ///
  /// In sw, this message translates to:
  /// **'Usalama wa Mtandao'**
  String get cybersecurity;

  /// No description provided for @aiTutorials.
  ///
  /// In sw, this message translates to:
  /// **'Mafunzo ya AI'**
  String get aiTutorials;

  /// No description provided for @allPosts.
  ///
  /// In sw, this message translates to:
  /// **'Makala Zote'**
  String get allPosts;

  /// No description provided for @articles.
  ///
  /// In sw, this message translates to:
  /// **'Makala'**
  String get articles;

  /// No description provided for @all.
  ///
  /// In sw, this message translates to:
  /// **'Zote'**
  String get all;

  /// No description provided for @favourites.
  ///
  /// In sw, this message translates to:
  /// **'Vipendwa'**
  String get favourites;

  /// No description provided for @searchHint.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta makala...'**
  String get searchHint;

  /// No description provided for @featured.
  ///
  /// In sw, this message translates to:
  /// **'MAARUFU'**
  String get featured;

  /// No description provided for @noResults.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna matokeo'**
  String get noResults;

  /// No description provided for @noArticles.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna makala'**
  String get noArticles;

  /// No description provided for @tryOther.
  ///
  /// In sw, this message translates to:
  /// **'Jaribu neno lingine'**
  String get tryOther;

  /// No description provided for @tapToLoad.
  ///
  /// In sw, this message translates to:
  /// **'Bonyeza kupakua'**
  String get tapToLoad;

  /// No description provided for @showMore.
  ///
  /// In sw, this message translates to:
  /// **'Onyesha Upya'**
  String get showMore;

  /// No description provided for @networkErr.
  ///
  /// In sw, this message translates to:
  /// **'Tatizo la Mtandao'**
  String get networkErr;

  /// No description provided for @tryAgain.
  ///
  /// In sw, this message translates to:
  /// **'Jaribu Tena'**
  String get tryAgain;

  /// No description provided for @fetching.
  ///
  /// In sw, this message translates to:
  /// **'Inatafuta kategoria...'**
  String get fetching;

  /// No description provided for @noFavs.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna vipendwa'**
  String get noFavs;

  /// No description provided for @noFavsSub.
  ///
  /// In sw, this message translates to:
  /// **'Gusa ikoni ya alama kwenye makala kuyaongeza hapa'**
  String get noFavsSub;

  /// No description provided for @secAppearance.
  ///
  /// In sw, this message translates to:
  /// **'MUONEKANO'**
  String get secAppearance;

  /// No description provided for @secLanguage.
  ///
  /// In sw, this message translates to:
  /// **'LUGHA'**
  String get secLanguage;

  /// No description provided for @secContent.
  ///
  /// In sw, this message translates to:
  /// **'MAKALA'**
  String get secContent;

  /// No description provided for @secNotifications.
  ///
  /// In sw, this message translates to:
  /// **'ARIFA'**
  String get secNotifications;

  /// No description provided for @secCategories.
  ///
  /// In sw, this message translates to:
  /// **'UAINISHAJI'**
  String get secCategories;

  /// No description provided for @secShare.
  ///
  /// In sw, this message translates to:
  /// **'SHIRIKI'**
  String get secShare;

  /// No description provided for @secHelp.
  ///
  /// In sw, this message translates to:
  /// **'MSAADA'**
  String get secHelp;

  /// No description provided for @secData.
  ///
  /// In sw, this message translates to:
  /// **'DATA'**
  String get secData;

  /// No description provided for @secReset.
  ///
  /// In sw, this message translates to:
  /// **'WEKA UPYA'**
  String get secReset;

  /// No description provided for @secAbout.
  ///
  /// In sw, this message translates to:
  /// **'KUHUSU'**
  String get secAbout;

  /// No description provided for @secReports.
  ///
  /// In sw, this message translates to:
  /// **'RIPOTI'**
  String get secReports;

  /// No description provided for @lightMode.
  ///
  /// In sw, this message translates to:
  /// **'Hali ya Mwanga'**
  String get lightMode;

  /// No description provided for @modeSub.
  ///
  /// In sw, this message translates to:
  /// **'Badilisha mandhari ya programu'**
  String get modeSub;

  /// No description provided for @textSize.
  ///
  /// In sw, this message translates to:
  /// **'Ukubwa wa Maandishi'**
  String get textSize;

  /// No description provided for @appLanguage.
  ///
  /// In sw, this message translates to:
  /// **'Lugha ya Programu'**
  String get appLanguage;

  /// No description provided for @offlineCache.
  ///
  /// In sw, this message translates to:
  /// **'Hifadhi Nje ya Mtandao'**
  String get offlineCache;

  /// No description provided for @offlineSub.
  ///
  /// In sw, this message translates to:
  /// **'Pakua kwa matumizi bila mtandao'**
  String get offlineSub;

  /// No description provided for @notifTitle.
  ///
  /// In sw, this message translates to:
  /// **'Arifa za Makala Mapya'**
  String get notifTitle;

  /// No description provided for @notifSub.
  ///
  /// In sw, this message translates to:
  /// **'Pokea taarifa makala mapya yapowekwa'**
  String get notifSub;

  /// No description provided for @chooseCategories.
  ///
  /// In sw, this message translates to:
  /// **'Chagua Kategoria'**
  String get chooseCategories;

  /// No description provided for @catSub.
  ///
  /// In sw, this message translates to:
  /// **'Amua makundi yanayoonekana'**
  String get catSub;

  /// No description provided for @shareApp.
  ///
  /// In sw, this message translates to:
  /// **'Shiriki Programu'**
  String get shareApp;

  /// No description provided for @shareSub.
  ///
  /// In sw, this message translates to:
  /// **'Mwambie rafiki yako kuhusu CyberSwahili'**
  String get shareSub;

  /// No description provided for @faqTitle.
  ///
  /// In sw, this message translates to:
  /// **'Maswali ya Kawaida'**
  String get faqTitle;

  /// No description provided for @faqSub.
  ///
  /// In sw, this message translates to:
  /// **'Majibu ya maswali yanayoulizwa mara nyingi'**
  String get faqSub;

  /// No description provided for @refreshArt.
  ///
  /// In sw, this message translates to:
  /// **'Onyesha Upya Makala'**
  String get refreshArt;

  /// No description provided for @refreshSub.
  ///
  /// In sw, this message translates to:
  /// **'Pakua makala mapya kutoka seva'**
  String get refreshSub;

  /// No description provided for @clearCache.
  ///
  /// In sw, this message translates to:
  /// **'Futa Akiba'**
  String get clearCache;

  /// No description provided for @clearCacheSub.
  ///
  /// In sw, this message translates to:
  /// **'Futa makala yote yaliyohifadhiwa'**
  String get clearCacheSub;

  /// No description provided for @resetAll.
  ///
  /// In sw, this message translates to:
  /// **'Weka Upya Mipangilio Yote'**
  String get resetAll;

  /// No description provided for @resetSub.
  ///
  /// In sw, this message translates to:
  /// **'Rudisha mipangilio yote kwa kawaida'**
  String get resetSub;

  /// No description provided for @small.
  ///
  /// In sw, this message translates to:
  /// **'Ndogo'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In sw, this message translates to:
  /// **'Wastani'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In sw, this message translates to:
  /// **'Kubwa'**
  String get large;

  /// No description provided for @cancel.
  ///
  /// In sw, this message translates to:
  /// **'Ghairi'**
  String get cancel;

  /// No description provided for @proceed.
  ///
  /// In sw, this message translates to:
  /// **'Endelea'**
  String get proceed;

  /// No description provided for @shareCopied.
  ///
  /// In sw, this message translates to:
  /// **'Ujumbe wa kushiriki umekopwa!'**
  String get shareCopied;

  /// No description provided for @cacheCleared.
  ///
  /// In sw, this message translates to:
  /// **'Akiba imefutwa kikamilifu'**
  String get cacheCleared;

  /// No description provided for @resetDone.
  ///
  /// In sw, this message translates to:
  /// **'Mipangilio imewekwa upya'**
  String get resetDone;

  /// No description provided for @refreshing.
  ///
  /// In sw, this message translates to:
  /// **'Makala yanasasishwa...'**
  String get refreshing;

  /// No description provided for @linkCopied.
  ///
  /// In sw, this message translates to:
  /// **'Kiungo kimekopwa!'**
  String get linkCopied;

  /// No description provided for @openBrowser.
  ///
  /// In sw, this message translates to:
  /// **'Kivinjari'**
  String get openBrowser;

  /// No description provided for @shareArticle.
  ///
  /// In sw, this message translates to:
  /// **'Shiriki'**
  String get shareArticle;

  /// No description provided for @readMin.
  ///
  /// In sw, this message translates to:
  /// **'dk'**
  String get readMin;

  /// No description provided for @articleNotLoaded.
  ///
  /// In sw, this message translates to:
  /// **'Makala haijapakiwa'**
  String get articleNotLoaded;

  /// No description provided for @clearCacheQ.
  ///
  /// In sw, this message translates to:
  /// **'Futa Akiba?'**
  String get clearCacheQ;

  /// No description provided for @clearCacheBody.
  ///
  /// In sw, this message translates to:
  /// **'Makala yote yaliyohifadhiwa yatafutwa. Utahitaji mtandao upya.'**
  String get clearCacheBody;

  /// No description provided for @resetAllQ.
  ///
  /// In sw, this message translates to:
  /// **'Weka Upya Mipangilio?'**
  String get resetAllQ;

  /// No description provided for @resetAllBody.
  ///
  /// In sw, this message translates to:
  /// **'Mipangilio yote, pamoja na vipendwa na uainishaji, itarudi kwa kawaida.'**
  String get resetAllBody;

  /// No description provided for @categoriesPageTitle.
  ///
  /// In sw, this message translates to:
  /// **'Chagua Kategoria'**
  String get categoriesPageTitle;

  /// No description provided for @categoriesHint.
  ///
  /// In sw, this message translates to:
  /// **'Chagua makundi unayotaka kuona kwenye ukurasa wa nyumbani.'**
  String get categoriesHint;

  /// No description provided for @selectAll.
  ///
  /// In sw, this message translates to:
  /// **'Chaguo Zote'**
  String get selectAll;

  /// No description provided for @kiswahili.
  ///
  /// In sw, this message translates to:
  /// **'Kiswahili'**
  String get kiswahili;

  /// No description provided for @english.
  ///
  /// In sw, this message translates to:
  /// **'Kiingereza'**
  String get english;

  /// No description provided for @viewMode.
  ///
  /// In sw, this message translates to:
  /// **'Muonekano wa Makala'**
  String get viewMode;

  /// No description provided for @list.
  ///
  /// In sw, this message translates to:
  /// **'Orodha'**
  String get list;

  /// No description provided for @grid.
  ///
  /// In sw, this message translates to:
  /// **'Gridi'**
  String get grid;

  /// No description provided for @cards.
  ///
  /// In sw, this message translates to:
  /// **'Kadi'**
  String get cards;

  /// No description provided for @reports.
  ///
  /// In sw, this message translates to:
  /// **'Ripoti'**
  String get reports;

  /// No description provided for @readingReport.
  ///
  /// In sw, this message translates to:
  /// **'Ripoti ya Kusoma'**
  String get readingReport;

  /// No description provided for @reportSubtitle.
  ///
  /// In sw, this message translates to:
  /// **'Onyesha takwimu za makala ulizosoma na kuhifadhi'**
  String get reportSubtitle;

  /// No description provided for @totalArticles.
  ///
  /// In sw, this message translates to:
  /// **'Makala Yaote'**
  String get totalArticles;

  /// No description provided for @availableArticles.
  ///
  /// In sw, this message translates to:
  /// **'yanayopatikana'**
  String get availableArticles;

  /// No description provided for @articlesRead.
  ///
  /// In sw, this message translates to:
  /// **'Makala Zilizosomwa'**
  String get articlesRead;

  /// No description provided for @ofTotal.
  ///
  /// In sw, this message translates to:
  /// **'ya jumla'**
  String get ofTotal;

  /// No description provided for @favourited.
  ///
  /// In sw, this message translates to:
  /// **'Zilizohifadhiwa'**
  String get favourited;

  /// No description provided for @savedForLater.
  ///
  /// In sw, this message translates to:
  /// **'zimehifadhiwa'**
  String get savedForLater;

  /// No description provided for @engagement.
  ///
  /// In sw, this message translates to:
  /// **'Ujumuishaji'**
  String get engagement;

  /// No description provided for @favRate.
  ///
  /// In sw, this message translates to:
  /// **'kiwango cha kupendelea'**
  String get favRate;

  /// No description provided for @insights.
  ///
  /// In sw, this message translates to:
  /// **'Maarifa'**
  String get insights;

  /// No description provided for @greatReader.
  ///
  /// In sw, this message translates to:
  /// **'Msomaji Bora!'**
  String get greatReader;

  /// No description provided for @greatReaderDesc.
  ///
  /// In sw, this message translates to:
  /// **'Umepata makala nyingi. Endelea kusoma!'**
  String get greatReaderDesc;

  /// No description provided for @goodReader.
  ///
  /// In sw, this message translates to:
  /// **'Msomaji Mwema'**
  String get goodReader;

  /// No description provided for @goodReaderDesc.
  ///
  /// In sw, this message translates to:
  /// **'Umepata makala kadhaa. Jaribu kusoma zaidi!'**
  String get goodReaderDesc;

  /// No description provided for @startReading.
  ///
  /// In sw, this message translates to:
  /// **'Anza Kusoma'**
  String get startReading;

  /// No description provided for @startReadingDesc.
  ///
  /// In sw, this message translates to:
  /// **'Hujaanza kusoma makala. Bonyeza makala kupata maarifa!'**
  String get startReadingDesc;

  /// No description provided for @activeSaver.
  ///
  /// In sw, this message translates to:
  /// **'Mhifadhi Aktivi!'**
  String get activeSaver;

  /// No description provided for @activeSaverDesc.
  ///
  /// In sw, this message translates to:
  /// **'Umependelea makala nyingi. Mazuri!'**
  String get activeSaverDesc;

  /// No description provided for @moderateSaver.
  ///
  /// In sw, this message translates to:
  /// **'Mhifadhi wa Kawaida'**
  String get moderateSaver;

  /// No description provided for @moderateSaverDesc.
  ///
  /// In sw, this message translates to:
  /// **'Umependelea makala kadhaa. Jaribu kuhifadhi zaidi!'**
  String get moderateSaverDesc;

  /// No description provided for @saveMore.
  ///
  /// In sw, this message translates to:
  /// **'Hifadhi Zaidi'**
  String get saveMore;

  /// No description provided for @saveMoreDesc.
  ///
  /// In sw, this message translates to:
  /// **'Hujaweka makala nyingi. Bonyeza ikoni ya kitabu!'**
  String get saveMoreDesc;

  /// No description provided for @keepUpdated.
  ///
  /// In sw, this message translates to:
  /// **'Endelea Kujua'**
  String get keepUpdated;

  /// No description provided for @keepUpdatedDesc.
  ///
  /// In sw, this message translates to:
  /// **'Onyesha upya mara kwa mara kupata makala mpya'**
  String get keepUpdatedDesc;

  /// No description provided for @viewReports.
  ///
  /// In sw, this message translates to:
  /// **'Onyesha Ripoti'**
  String get viewReports;

  /// No description provided for @reportsDesc.
  ///
  /// In sw, this message translates to:
  /// **'Angalia takwimu za makala ulizosoma'**
  String get reportsDesc;
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
