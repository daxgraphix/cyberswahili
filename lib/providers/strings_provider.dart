import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';

/// All UI strings in Swahili and English.
/// Use via: `ref.watch(stringsProvider)`
class S {
  final bool sw; // true = Kiswahili
  const S({required this.sw});

  // Navigation
  String get articles   => sw ? 'Makala'     : 'Articles';
  String get all        => sw ? 'Zote'       : 'All';
  String get favourites => sw ? 'Vipendwa'   : 'Favourites';
  String get settings   => sw ? 'Mipangilio' : 'Settings';

  // Home bar
  String get searchHint => sw ? 'Tafuta makala...' : 'Search articles...';
  String get featured   => sw ? 'MAARUFU'          : 'FEATURED';

  // Feed states
  String get noResults  => sw ? 'Hakuna matokeo' : 'No results';
  String get noArticles => sw ? 'Hakuna makala'  : 'No articles';
  String get tryOther   => sw ? 'Jaribu neno lingine' : 'Try a different keyword';
  String get tapToLoad  => sw ? 'Bonyeza kupakua'     : 'Tap to load';
  String get showMore   => sw ? 'Onyesha Upya'        : 'Refresh';
  String get networkErr => sw ? 'Tatizo la Mtandao'   : 'Network Error';
  String get tryAgain   => sw ? 'Jaribu Tena'         : 'Try Again';
  String get loading    => sw ? 'Inapakia...'         : 'Loading...';
  String get fetching   => sw ? 'Inatafuta kategoria...' : 'Fetching category...';

  // Favourites
  String get noFavs    => sw ? 'Hakuna vipendwa' : 'No favourites yet';
  String get noFavsSub => sw
      ? 'Gusa ikoni ya alama kwenye makala kuyaongeza hapa'
      : 'Tap the bookmark icon on any article to save it here';

  // Settings sections
  String get secAppearance    => sw ? 'MUONEKANO'     : 'APPEARANCE';
  String get secLanguage      => sw ? 'LUGHA'         : 'LANGUAGE';
  String get secContent       => sw ? 'MAKALA'        : 'CONTENT';
  String get secNotifications => sw ? 'ARIFA'         : 'NOTIFICATIONS';
  String get secCategories    => sw ? 'UAINISHAJI'    : 'CATEGORIES';
  String get secShare         => sw ? 'SHIRIKI'       : 'SHARE';
  String get secHelp          => sw ? 'MSAADA'        : 'HELP';
  String get secData          => sw ? 'DATA'          : 'DATA';
  String get secReset         => sw ? 'WEKA UPYA'     : 'RESET';
  String get secAbout         => sw ? 'KUHUSU'        : 'ABOUT';

  // Settings items
  String get darkMode       => sw ? 'Hali ya Giza'       : 'Dark Mode';
  String get lightMode      => sw ? 'Hali ya Mwanga'     : 'Light Mode';
  String get modeSub        => sw ? 'Badilisha mandhari ya programu' : 'Switch app theme';
  String get textSize       => sw ? 'Ukubwa wa Maandishi' : 'Text Size';
  String get appLanguage    => sw ? 'Lugha ya Programu'   : 'App Language';
  String get offlineCache   => sw ? 'Hifadhi Nje ya Mtandao' : 'Offline Cache';
  String get offlineSub     => sw ? 'Pakua kwa matumizi bila mtandao' : 'Download for offline use';
  String get notifTitle     => sw ? 'Arifa za Makala Mapya'  : 'New Article Alerts';
  String get notifSub       => sw ? 'Pokea taarifa makala mapya yapowekwa' : 'Get alerts when new articles are posted';
  String get chooseCategories => sw ? 'Chagua Kategoria'  : 'Choose Categories';
  String get catSub         => sw ? 'Amua makundi yanayoonekana' : 'Pick visible tab categories';
  String get shareApp       => sw ? 'Shiriki Programu'   : 'Share App';
  String get shareSub       => sw ? 'Mwambie rafiki yako kuhusu CyberSwahili' : 'Tell friends about CyberSwahili';
  String get faqTitle       => sw ? 'Maswali ya Kawaida' : 'Frequently Asked Questions';
  String get faqSub         => sw ? 'Majibu ya maswali yanayoulizwa mara nyingi' : 'Answers to common questions';
  String get refreshArt     => sw ? 'Onyesha Upya Makala' : 'Refresh Articles';
  String get refreshSub     => sw ? 'Pakua makala mapya kutoka seva' : 'Download latest from server';
  String get clearCache     => sw ? 'Futa Akiba'  : 'Clear Cache';
  String get clearCacheSub  => sw ? 'Futa makala yote yaliyohifadhiwa' : 'Delete all stored articles';
  String get resetAll       => sw ? 'Weka Upya Mipangilio Yote' : 'Reset All Settings';
  String get resetSub       => sw ? 'Rudisha mipangilio yote kwa kawaida' : 'Restore defaults';

  // Sizes
  String get small  => sw ? 'Ndogo'   : 'Small';
  String get medium => sw ? 'Wastani' : 'Medium';
  String get large  => sw ? 'Kubwa'   : 'Large';

  // Actions
  String get cancel      => sw ? 'Ghairi'  : 'Cancel';
  String get proceed     => sw ? 'Endelea' : 'Proceed';
  String get shareCopied => sw ? 'Ujumbe wa kushiriki umekopwa!' : 'Share message copied!';
  String get cacheCleared => sw ? 'Akiba imefutwa kikamilifu' : 'Cache cleared successfully';
  String get resetDone   => sw ? 'Mipangilio imewekwa upya'  : 'Settings have been reset';
  String get refreshing  => sw ? 'Makala yanasasishwa...'    : 'Refreshing articles...';
  String get linkCopied  => sw ? 'Kiungo kimekopwa!'         : 'Link copied!';

  // Post detail
  String get openBrowser  => sw ? 'Kivinjari' : 'Browser';
  String get shareArticle => sw ? 'Shiriki'   : 'Share';
  String get readMin      => sw ? 'dk'        : 'min';
  String get articleNotLoaded => sw ? 'Makala haijapakiwa' : 'Article not loaded';

  // Confirm dialogs
  String get clearCacheQ    => sw ? 'Futa Akiba?'          : 'Clear Cache?';
  String get clearCacheBody => sw
      ? 'Makala yote yaliyohifadhiwa yatafutwa. Utahitaji mtandao upya.'
      : 'All stored articles will be deleted. You\'ll need internet to reload.';
  String get resetAllQ    => sw ? 'Weka Upya Mipangilio?' : 'Reset All Settings?';
  String get resetAllBody => sw
      ? 'Mipangilio yote, pamoja na vipendwa na uainishaji, itarudi kwa kawaida.'
      : 'All settings including favourites and categories will be reset to defaults.';
  String get categoriesPageTitle => sw ? 'Chagua Kategoria' : 'Choose Categories';
  String get categoriesHint => sw
      ? 'Chagua makundi unayotaka kuona kwenye ukurasa wa nyumbani.'
      : 'Choose which categories appear on the home tab bar.';
   String get selectAll => sw ? 'Chaguo Zote' : 'Select All';

  // View modes
  String get viewMode => sw ? 'Muonekano wa Makala' : 'Article View';
  String get list => sw ? 'Orodha' : 'List';
  String get grid => sw ? 'Gridi' : 'Grid';
  String get cards => sw ? 'Kadi' : 'Cards';

  // Reports
  String get reports => sw ? 'Ripoti' : 'Reports';
  String get readingReport => sw ? 'Ripoti ya Kusoma' : 'Reading Report';
  String get reportSubtitle => sw ? 'Onyesha takwimu za makala ulizosoma na kuhifadhi' : 'View statistics of articles you\'ve read and saved';
  String get totalArticles => sw ? 'Makala Yaote' : 'Total Articles';
  String get availableArticles => sw ? 'yanayopatikana' : 'available';
  String get articlesRead => sw ? 'Makala Zilizosomwa' : 'Articles Read';
  String get ofTotal => sw ? 'ya jumla' : 'of total';
  String get favourited => sw ? 'Zilizohifadhiwa' : 'Favourited';
  String get savedForLater => sw ? 'zimehifadhiwa' : 'saved for later';
  String get engagement => sw ? 'Ujumuishaji' : 'Engagement';
  String get favRate => sw ? 'kiwango cha kupendelea' : 'favourite rate';
  String get insights => sw ? 'Maarifa' : 'Insights';
  String get greatReader => sw ? 'Msomaji Bora!' : 'Great Reader!';
  String get greatReaderDesc => sw ? 'Umepata makala nyingi. Endelea kusoma!' : 'You\'ve read many articles. Keep it up!';
  String get goodReader => sw ? 'Msomaji Mwema' : 'Good Reader';
  String get goodReaderDesc => sw ? 'Umepata makala kadhaa. Jaribu kusoma zaidi!' : 'You\'ve read several articles. Try reading more!';
  String get startReading => sw ? 'Anza Kusoma' : 'Start Reading';
  String get startReadingDesc => sw ? 'Hujaanza kusoma makala. Bonyeza makala kupata maarifa!' : 'You haven\'t started reading yet. Tap articles to gain knowledge!';
  String get activeSaver => sw ? 'Mhifadhi Aktivi!' : 'Active Saver!';
  String get activeSaverDesc => sw ? 'Umependelea makala nyingi. Mazuri!' : 'You\'ve favourited many articles. Great!';
  String get moderateSaver => sw ? 'Mhifadhi wa Kawaida' : 'Moderate Saver';
  String get moderateSaverDesc => sw ? 'Umependelea makala kadhaa. Jaribu kuhifadhi zaidi!' : 'You\'ve favourited several articles. Try saving more!';
  String get saveMore => sw ? 'Hifadhi Zaidi' : 'Save More';
  String get saveMoreDesc => sw ? 'Hujaweka makala nyingi. Bonyeza alama ya kitabu!' : 'You haven\'t saved many articles. Tap the bookmark icon!';
  String get keepUpdated => sw ? 'Endelea Kujua' : 'Keep Updated';
  String get keepUpdatedDesc => sw ? 'Onyesha upya mara kwa mara kupata makala mpya' : 'Refresh regularly to get new articles';

  // Settings sections
  String get secReports => sw ? 'RIPOTI' : 'REPORTS';
  String get viewReports => sw ? 'Onyesha Ripoti' : 'View Reports';
  String get reportsDesc => sw ? 'Angalia takwimu za makala ulizosoma' : 'Check statistics of articles you\'ve read';

   // Language options
   String get kiswahili => sw ? 'Kiswahili' : 'Kiswahili';
   String get english => sw ? 'Kiingereza' : 'English';

   // Categories page
   String get chooseCategoriesPageTitle => sw ? 'Chagua Kategoria' : 'Choose Categories';
}

final stringsProvider = Provider<S>((ref) {
  final swahili = ref.watch(settingsProvider).swahiliFirst;
  return S(sw: swahili);
});
