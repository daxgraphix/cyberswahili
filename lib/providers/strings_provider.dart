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
  String get showMore   => sw ? 'Onyesha zaidi'        : 'Refresh';
  String get networkErr => sw ? 'Tatizo la mtandao'   : 'Network Error';
  String get tryAgain   => sw ? 'Jaribu tena'         : 'Try Again';
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
  String get secCategories    => sw ? 'KATEGORIA'     : 'CATEGORIES';
  String get secShare         => sw ? 'SHIRIKI'       : 'SHARE';
  String get secHelp          => sw ? 'MSAADA'        : 'HELP';
  String get secData          => sw ? 'DATA'          : 'DATA';
  String get secReset         => sw ? 'WEKA UPYA'     : 'RESET';

  // Settings items
  String get darkMode       => sw ? 'Hali ya giza'       : 'Dark Mode';
  String get lightMode      => sw ? 'Hali ya mwanga'     : 'Light Mode';
  String get modeSub        => sw ? 'Badilisha mandhari ya programu' : 'Switch app theme';
  String get textSize       => sw ? 'Ukubwa wa maandishi' : 'Text Size';
  String get appLanguage    => sw ? 'Lugha ya programu'   : 'App Language';
  String get offlineCache   => sw ? 'Akiba ya nje ya mtandao' : 'Offline Cache';
  String get offlineSub     => sw ? 'Hifadhi makala kwa matumizi bila mtandao' : 'Save articles for offline use';
  String get notifTitle     => sw ? 'Arifa za makala Mpya'  : 'New Article Alerts';
  String get notifSub       => sw ? 'Pokea taarifa makala Mpya yanapowekwa' : 'Get alerts when new articles are posted';
  String get chooseCategories => sw ? 'Chagua kategoria'  : 'Choose Categories';
  String get catSub         => sw ? 'Amua kategoria zinazoonekana' : 'Pick visible tab categories';
  String get shareApp       => sw ? 'Shiriki programu'   : 'Share App';
  String get shareSub       => sw ? 'Mwambie rafiki yako kuhusu CyberSwahili' : 'Tell friends about CyberSwahili';
  String get faqTitle       => sw ? 'Maswali yanayoulizwa mara nyingi' : 'Frequently Asked Questions';
  String get faqSub         => sw ? 'Majibu ya maswali yanayoulizwa mara nyingi' : 'Answers to common questions';
  String get refreshArt     => sw ? 'Onyesha upya makala' : 'Refresh Articles';
  String get refreshSub     => sw ? 'Pakua makala Mpya kutoka kwenye seva' : 'Download latest from server';
  String get clearCache     => sw ? 'Futa akiba'  : 'Clear Cache';
  String get clearCacheSub  => sw ? 'Futa data ya makala yaliyohifadhiwa' : 'Delete all stored article data';
  String get resetAll       => sw ? 'Weka upya mipangilio yote' : 'Reset All Settings';
  String get resetSub       => sw ? 'Rudisha mipangilio yote kwa kawaida' : 'Restore defaults';

  // Sizes
  String get small  => sw ? 'Ndogo'   : 'Small';
  String get medium => sw ? 'Wastani' : 'Medium';
  String get large  => sw ? 'Kubwa'   : 'Large';

  // Actions
  String get cancel      => sw ? 'Ghairi'  : 'Cancel';
  String get proceed     => sw ? 'Endelea' : 'Proceed';
  String get shareCopied => sw ? 'Ujumbe umenakiliwa!' : 'Share message copied!';
  String get cacheCleared => sw ? 'Akiba imefutwa kikamilifu' : 'Cache cleared successfully';
  String get resetDone   => sw ? 'Mipangilio imewekwa upya'  : 'Settings have been reset';
  String get refreshing  => sw ? 'Inapakua makala Mpya...'    : 'Refreshing latest articles...';
  String get linkCopied  => sw ? 'Kiungo kimenakiliwa!'         : 'Link copied!';
  String get ok          => sw ? 'Sawa'                    : 'OK';
  String get search      => sw ? 'Tafuta'                  : 'Search';
  String get refresh     => sw ? 'Sasisha'                 : 'Refresh';
  String get back        => sw ? 'Rudi'                    : 'Back';

  // Post detail
  String get openBrowser  => sw ? 'Kivinjari' : 'Browser';
  String get shareArticle => sw ? 'Shiriki'   : 'Share';
  String get readMin      => sw ? 'dk'        : 'min';
  String get readMinSemantic => sw ? 'dakika' : 'minutes';
  String get articleNotLoaded => sw ? 'Makala haijapakiwa' : 'Article not loaded';

  // Confirm dialogs
  String get clearCacheQ    => sw ? 'Futa akiba?'          : 'Clear Cache?';
  String get clearCacheBody => sw
      ? 'Makala yote yaliyohifadhiwa kwenye akiba yatafutwa. Utahitaji mtandao ili kuyapakia tena.'
      : 'All cached articles will be deleted. You\'ll need internet to reload them.';
  String get resetAllQ    => sw ? 'Weka upya mipangilio?' : 'Reset All Settings?';
  String get resetAllBody => sw
      ? 'Mipangilio yote, pamoja na vipendwa, rekodi za kusoma, na kategoria, itarudi kwenye hali ya awali.'
      : 'All settings including favourites, read history, and categories will be reset to defaults.';
  String get categoriesPageTitle => sw ? 'Chagua kategoria' : 'Choose Categories';
  String get categoriesHint => sw
      ? 'Chagua makundi unayotaka kuona kwenye ukurasa wa nyumbani.'
      : 'Choose which categories appear on the home tab bar.';
   String get selectAll => sw ? 'Chaguo zote' : 'Select All';

  // View modes
  String get viewMode => sw ? 'Muonekano wa makala' : 'Article View';
  String get list => sw ? 'Orodha' : 'List';
  String get grid => sw ? 'Gridi' : 'Grid';
  String get cards => sw ? 'Kadi' : 'Cards';

  // Reports
  String get reports => sw ? 'Takwimu za usomaji' : 'Reading Analytics';
  String get readingReport => sw ? 'Muhtasari' : 'Overview';
  String get reportSubtitle => sw ? 'Takwimu zako za usomaji na ushiriki' : 'Your reading performance & engagement';
  String get activity => sw ? 'Utendaji' : 'Activity';
  String get interests => sw ? 'Mapendeleo' : 'Interests';
  String get achievements => sw ? 'Mafanikio' : 'Achievements';
  String get readingGoal => sw ? 'Lengo la kusoma' : 'Reading Goal';
  String get dailyGoal => sw ? 'Lengo la kila siku' : 'Daily Goal';
  String get goalReached => sw ? 'Lengo limefikiwa!' : 'Goal reached!';
  String get keepReading => sw ? 'Endelea kusoma kufikia lengo' : 'Keep reading to hit your goal';
  String get totalArticles => sw ? 'Makala zote' : 'Total Articles';
  String get availableArticles => sw ? 'yanayopatikana' : 'available';
  String get articlesRead => sw ? 'Makala zilizosomwa' : 'Articles Read';
  String get ofTotal => sw ? 'ya jumla' : 'of total';
  String get favourited => sw ? 'Zilizohifadhiwa' : 'Favourited';
  String get savedForLater => sw ? 'zimehifadhiwa' : 'saved for later';
  String get engagement => sw ? 'Ushiriki' : 'Engagement';
  String get favRate => sw ? 'kiwango cha kupendelea' : 'favourite rate';
  String get insights => sw ? 'Maarifa' : 'Insights';
  String get greatReader => sw ? 'Msomaji bora!' : 'Great Reader!';
  String get greatReaderDesc => sw ? 'Umepata makala nyingi. Endelea kusoma!' : 'You\'ve read many articles. Keep it up!';
  String get goodReader => sw ? 'Msomaji mwema' : 'Good Reader';
  String get goodReaderDesc => sw ? 'Umepata makala kadhaa. Jaribu kusoma zaidi!' : 'You\'ve read several articles. Try reading more!';
  String get startReading => sw ? 'Anza kusoma' : 'Start Reading';
  String get startReadingDesc => sw ? 'Hujaanza kusoma makala. Bonyeza makala kupata maarifa!' : 'You haven\'t started reading yet. Tap articles to gain knowledge!';
  String get activeSaver => sw ? 'Mhifadhi stadi!' : 'Active Saver!';
  String get activeSaverDesc => sw ? 'Umependelea makala nyingi. Kazi nzuri!' : 'You\'ve favourited many articles. Great job!';
  String get moderateSaver => sw ? 'Mhifadhi wa kawaida' : 'Moderate Saver';
  String get moderateSaverDesc => sw ? 'Umependelea makala kadhaa. Jaribu kuhifadhi zaidi!' : 'You\'ve favourited several articles. Try saving more!';
  String get saveMore => sw ? 'Hifadhi zaidi' : 'Save More';
  String get saveMoreDesc => sw ? 'Hujaweka makala nyingi. Bonyeza alama ya kitabu!' : 'You haven\'t saved many articles. Tap the bookmark icon!';
  String get keepUpdated => sw ? 'Endelea kujua' : 'Keep Updated';
  String get keepUpdatedDesc => sw ? 'Onyesha upya mara kwa mara kupata makala mpya' : 'Refresh regularly to get new articles';
  
  // Reports - Interactive
  String get viewByCategory => sw ? 'Kwa kategoria' : 'View by Category';
  String get analytics => sw ? 'Vipengele' : 'Analytics';
  String get weeklyTrend => sw ? 'Mbadala wa wiki' : 'Weekly Trend';
  String get distribution => sw ? 'Ubambuzi' : 'Distribution';
  String get noCategoryData => sw ? 'Hakuna takwimu za kategoria' : 'No category data yet';
  String get noArticlesRead => sw ? 'Hakuna makala zilizosomwa' : 'No articles read yet';
  String get noFavourites => sw ? 'Hakuna vipendwa' : 'No favourites yet';
  String get noInsights => sw ? 'Hakuna maarifa kwa sasa' : 'No insights available yet';
  String get readingStreak => sw ? 'Mfululizo wa kusoma' : 'Reading Streak';
  String get topCategory => sw ? 'Kategoria kuu' : 'Top Category';
  String get readLater => sw ? 'Hifadhi nje ya mtandao' : 'Save offline';
  String get savedOffline => sw ? 'Imehifadhiwa nje ya mtandao' : 'Saved offline';
  String get manageOffline => sw ? 'Dhibiti makala nje ya mtandao' : 'Manage Offline Articles';
  String get offlineManagementDesc => sw ? 'Angalia na ufute makala yaliyohifadhiwa' : 'View and delete stored articles';
  String get noOfflineArticles => sw ? 'Hakuna makala nje ya mtandao' : 'No offline articles';
  String get articleLoadingBody => sw
      ? 'Makala inapakuliwa. Hii inaweza kuchukua muda mfupi mara ya kwanza.'
      : 'Article content is loading. This can take a moment the first time.';
  String get contentLoadFailed => sw
      ? 'Maudhui hayakupakiwa. Unaweza kujaribu tena au kufungua kwenye kivinjari.'
      : 'Content did not load. You can retry or open it in the browser.';
  String get refreshDone => sw ? 'Makala yamesasishwa' : 'Articles refreshed';
  String get refreshFailed => sw ? 'Imeshindwa kusasisha' : 'Refresh failed';
  String get offlineMode => sw ? 'Nje ya mtandao' : 'Offline';
  String get serverOffline => sw ? 'Seva haipatikani' : 'Server Unreachable';
  String get deviceOffline => sw ? 'Huna mtandao' : 'Device Offline';
  String get offlineMessage => sw ? 'Uko nje ya mtandao kwa sasa: tafadhali kagua mtandao wako na ujaribu tena' : 'You\'re currently offline: please check your internet and try again';
  String get relatedArticles => sw ? 'Makala yanayohusiana' : 'Related Articles';
  String get deleteOfflineQ => sw ? 'Futa makala?' : 'Delete Article?';
  String get deleteOfflineBody => sw
      ? 'Hii itaondoa maudhui ya makala haya kwenye simu yako.'
      : 'This will remove the content of this article from your device.';
  String get delete     => sw ? 'Futa'     : 'Delete';
  String get offlineManagementHint => sw
      ? 'Makala unayopakua kwa ajili ya kusoma nje ya mtandao yataonekana hapa.'
      : 'Articles you download for offline reading will appear here.';
  String get newArticlesNotif => sw ? 'Kuna makala Mpya!' : 'New articles available!';
  String get newArticlesNotifBody => sw
      ? 'Gusa ili kusoma makala Mpya ya teknolojia.'
      : 'Tap to read the latest technology articles.';

  // Settings sections
  String get secReports => sw ? 'RIPOTI' : 'REPORTS';
  String get viewReports => sw ? 'Onyesha ripoti' : 'View Reports';
  String get reportsDesc => sw ? 'Angalia takwimu za makala ulizosoma' : 'Check statistics of articles you\'ve read';
  String get clearReadHistory => sw ? 'Futa zilizosomwa' : 'Clear Read History';
  String get clearReadHistorySub => sw ? 'Futa rekodi zako za kusoma' : 'Clear your reading history';
  String get qnaTitle => sw ? 'Maswali na Majibu' : 'Questions & Answers';
  String get qnaSub => sw ? 'Maswali ya kawaida' : 'Frequently asked questions';

  // Achievements
  String get badgeNewReader      => sw ? 'Msomaji Mpya'      : 'New Reader';
  String get badgeNewReaderDesc  => sw ? 'Soma makala yako ya kwanza' : 'Read your first article';
  String get badgeTechLover      => sw ? 'Mpenzi wa Teknolojia' : 'Tech Enthusiast';
  String get badgeTechLoverDesc  => sw ? 'Soma makala 10'      : 'Read 10 articles';
  String get badgeCollector      => sw ? 'Mkusanyaji Makala'  : 'The Collector';
  String get badgeCollectorDesc  => sw ? 'Hifadhi makala 5'    : 'Save 5 articles';
  String get badgePowerReader    => sw ? 'Msomaji Hodari'    : 'Power Reader';
  String get badgePowerReaderDesc => sw ? 'Soma makala 50'      : 'Read 50 articles';

  // Dynamic strings / Plurals
  String daysCount(int n) => sw ? '$n siku' : '$n ${n == 1 ? 'day' : 'days'}';
  String faqCountSummary(int n) => sw 
      ? 'Maswali $n yanayoulizwa mara nyingi' 
      : '$n frequently asked questions';

  List<Map<String, String>> get faqs {
    if (sw) {
      return [
        {'q': 'CyberSwahili ni nini?', 'a': 'CyberSwahili ni programu inayoleta habari za teknolojia kwa lugha ya Kiswahili. Tunaamini kila Mwafrika anastahili kupata elimu ya kidijitali kwa lugha yake.'},
        {'q': 'Jinsi ya kusoma bila mtandao?', 'a': 'Washa "Hifadhi nje ya mtandao" kwenye mipangilio. Makala yatahifadhiwa kwenye simu yako na unaweza kuyasoma hata bila mtandao.'},
        {'q': 'Jinsi ya kuhifadhi makala?', 'a': 'Gusa ikoni ya alama ya kitabu (🔖) kwenye makala yoyote. Makala yako yataorodheshwa kwenye kichupo cha "Vipendwa".'},
        {'q': 'Jinsi ya kubadilisha rangi?', 'a': 'Nenda Mipangilio → Muonekano → Badilisha kati ya "Hali ya giza" na "Hali ya mwanga".'},
        {'q': 'Jinsi ya kushiriki makala?', 'a': 'Fungua makala yoyote kisha bonyeza kitufe cha "Shiriki". Kiungo kitakopwa kwenye clipboard.'},
        {'q': 'Programu haifanyi kazi vizuri?', 'a': 'Jaribu: 1) Hakikisha una mtandao. 2) Futa akiba. 3) Funga na ufungue programu upya.'},
        {'q': 'Jinsi ya kubadilisha lugha?', 'a': 'Nenda Mipangilio → Lugha → Chagua "Kiswahili" au "Kiingereza".'},
      ];
    }
    return [
      {'q': 'What is CyberSwahili?', 'a': 'CyberSwahili is an app that brings technology news in Swahili. We believe every African deserves digital education in their language.'},
      {'q': 'How can I read offline?', 'a': 'Enable "Offline Cache" in Settings. Articles will be saved on your device for offline reading.'},
      {'q': 'How to save articles?', 'a': 'Tap the bookmark icon (🔖) on any article. Saved articles appear in the "Favourites" section.'},
      {'q': 'How to change app theme?', 'a': 'Go to Settings → Appearance → Switch between "Dark Mode" and "Light Mode".'},
      {'q': 'How to share articles?', 'a': 'Open any article and tap the "Share" button. The link copies to your clipboard.'},
      {'q': 'Why isn\'t the app working?', 'a': 'Try: 1) Check internet connection. 2) Clear cache. 3) Restart the app.'},
      {'q': 'How to change language?', 'a': 'Go to Settings → Language → Choose "Swahili" or "English".'},
    ];
  }

  // Language options
  String get kiswahili => sw ? 'Kiswahili' : 'Swahili';
  String get english => sw ? 'Kiingereza' : 'English';

  // App info
  String get appName => sw ? 'CyberSwahili' : 'CyberSwahili';
  String get appDescription => sw ? 'Habari za Teknolojia kwa Kiswahili' : 'Technology News in Swahili';
  String get appVersion => sw ? 'Toleo' : 'Version';

  // Categories page
  String get chooseCategoriesPageTitle => sw ? 'Chagua kategoria' : 'Choose Categories';
}

final stringsProvider = Provider<S>((ref) {
  final swahili = ref.watch(settingsProvider).swahiliFirst;
  return S(sw: swahili);
});
