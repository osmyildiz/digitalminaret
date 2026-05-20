// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Digital Minaret';

  @override
  String get prayerFajr => 'ファジュル';

  @override
  String get prayerSunrise => '日の出';

  @override
  String get prayerDhuhr => 'ドゥフル';

  @override
  String get prayerAsr => 'アスル';

  @override
  String get prayerMaghrib => 'マグリブ';

  @override
  String get prayerIsha => 'イシャー';

  @override
  String get prayerJumuah => 'ジュムア';

  @override
  String get prayerIftar => 'イフタール';

  @override
  String get prayerSuhoor => 'スフール';

  @override
  String get arabicFajr => 'فجر';

  @override
  String get arabicSunrise => 'شروق';

  @override
  String get arabicDhuhr => 'ظهر';

  @override
  String get arabicAsr => 'عصر';

  @override
  String get arabicMaghrib => 'مغرب';

  @override
  String get arabicIsha => 'عشاء';

  @override
  String get arabicJumuah => 'جمعة';

  @override
  String get suhoorEnds => 'スフール終了';

  @override
  String get iftarTime => 'イフタールの時刻';

  @override
  String get unknown => '不明';

  @override
  String get welcome => 'ようこそ';

  @override
  String get welcomeSubtitle => '位置情報、計算方法、マズハブを設定して、正確な礼拝時刻を始めましょう。';

  @override
  String get continueButton => '続ける';

  @override
  String get close => '閉じる';

  @override
  String get ok => 'OK';

  @override
  String get notNow => '後で';

  @override
  String get submit => '送信';

  @override
  String get cancel => 'キャンセル';

  @override
  String get download => 'ダウンロード';

  @override
  String get retry => '再試行';

  @override
  String get settings => '設定';

  @override
  String get stepLocation => '1. 位置情報';

  @override
  String get useCurrentLocation => '現在地を使用';

  @override
  String get enterLocation => '場所を入力';

  @override
  String get searchLocation => '場所を検索';

  @override
  String get cityOrAddress => '都市または住所';

  @override
  String get noLocationSelected => '場所が選択されていません';

  @override
  String locationSetTo(String cityName) {
    return '場所を $cityName に設定しました。礼拝時刻を更新しました。';
  }

  @override
  String get locationUpdated => '位置情報を更新し、礼拝時刻を再計算しました。';

  @override
  String get unableToGetLocation => '位置情報を取得できません。手動で検索してください。';

  @override
  String get stepCalculationMethod => '2. 計算方法';

  @override
  String get stepAsrMadhab => '3. アスルのマズハブ';

  @override
  String get stepFullAdhanPack => '4. フルアザーンパック';

  @override
  String get adhanPackNote => '通知アザーンは30秒固定です。この選択は、通知をタップしたときのフルアザーンに使用されます。';

  @override
  String get methodIsna => '北米 (ISNA)';

  @override
  String get methodMuslimWorldLeague => 'ムスリム世界連盟';

  @override
  String get methodTurkeyDiyanet => 'トルコ宗務庁';

  @override
  String get methodEgyptian => 'エジプト';

  @override
  String get methodKarachi => 'カラチ (UISC)';

  @override
  String get methodUmmAlQura => 'ウンム・アル=クラー (マッカ)';

  @override
  String get methodDubai => 'ドバイ (湾岸地域)';

  @override
  String get methodSingapore => 'シンガポール / 東南アジア';

  @override
  String get methodTehran => 'テヘラン (イラン)';

  @override
  String get madhabNonHanafi => 'ハナフィー以外';

  @override
  String get madhabHanafi => 'ハナフィー';

  @override
  String get asrMadhab => 'アスルのマズハブ';

  @override
  String get location => '位置情報';

  @override
  String get calculation => '計算';

  @override
  String get notifications => '通知';

  @override
  String get adhanAudio => 'アザーン音声';

  @override
  String get supportAndTrust => 'サポートと信頼';

  @override
  String get permissionNeeded => '許可が必要です';

  @override
  String get pleaseAllowNotifications => 'iPhoneの設定で通知を許可してください。';

  @override
  String get fullAdhanOnNotificationTap => '通知タップでフルアザーン再生';

  @override
  String get playDuaAfterAdhan => 'アザーン後にドゥアーを再生';

  @override
  String get lockScreenTimeline => 'ロック画面の礼拝タイムライン';

  @override
  String adhanPackLabel(String packName) {
    return 'アザーンパック: $packName';
  }

  @override
  String get adhanPacks => 'アザーンパック';

  @override
  String get downloadAdhanPack => 'アザーンパックをダウンロード';

  @override
  String adhanPackDownloadPrompt(String packName) {
    return '$packName をデバイスにダウンロードします。続けますか?';
  }

  @override
  String get downloadingAdhanPack => 'アザーンパックをダウンロード中...';

  @override
  String downloadFailed(String error) {
    return 'ダウンロードに失敗しました: $error';
  }

  @override
  String packDownloaded(String packName) {
    return '$packName をダウンロードしました。';
  }

  @override
  String get donate => '寄付';

  @override
  String get donateSubtitle => 'ご希望であれば開発を支援できます。';

  @override
  String get sendFeedback => 'フィードバックを送信';

  @override
  String get sendFeedbackSubtitle => '簡単なフォームを開く';

  @override
  String get widgetSetup => 'ウィジェットの設定';

  @override
  String get widgetSetupSubtitle => 'ホーム画面のライブウィジェットを追加・更新する方法。';

  @override
  String get privacyNotes => 'プライバシーに関する注意';

  @override
  String get privacyNotesSubtitle => 'デバイス上でデータがどのように扱われるかを読む。';

  @override
  String get thankYouForUsing => 'Digital Minaret をご利用いただきありがとうございます。';

  @override
  String get appAlwaysFree => 'このアプリは常に広告なし、無料でご利用いただけます。';

  @override
  String get rateDigitalMinaret => 'Digital Minaret を評価する';

  @override
  String get ratePromptMessage => 'この精神的な旅をお楽しみいただいていますか?あなたのフィードバックが道を照らします。';

  @override
  String get couldNotOpenLink => 'このデバイスでリンクを開けませんでした。';

  @override
  String couldNotPlayPreview(String error) {
    return 'アザーンプレビューを再生できませんでした: $error';
  }

  @override
  String notificationsCouldNotBeScheduled(String error) {
    return '通知を完全にスケジュールできませんでした: $error';
  }

  @override
  String couldNotContinue(String error) {
    return '続行できませんでした。再試行してください。($error)';
  }

  @override
  String get hadithOfTheDay => '今日のハディース';

  @override
  String get ramadanDua => 'ラマダーンのドゥアー';

  @override
  String get verseFromQuran => 'クルアーンの章句';

  @override
  String get hadithBody =>
      'ラマダーンの月があなた方に訪れた。アッラーがあなた方に断食を義務付けた祝福された月である。(ナサーイー)';

  @override
  String get duaBody => 'アッラーよ、あなたの愛を、あなたを愛する者の愛を、そしてあなたの愛に近づける行いを乞い願います。';

  @override
  String get verseBody =>
      '信仰する者よ、断食はあなた方以前の者に課せられたように、あなた方にも課せられた。それはあなた方が主を畏れるためである。(雌牛章 2:183)';

  @override
  String get supportTheApp => 'アプリを支援する';

  @override
  String get donateDescription => 'このアプリは無料・広告なしです。ご希望であれば、一度きりのチップで開発を支援できます。';

  @override
  String get purchaseDidNotComplete => '購入が完了しませんでした。';

  @override
  String get thankYou => 'ありがとうございます';

  @override
  String get thankYouDonateMessage =>
      'あなたの支援は大きな意味を持ちます。アプリを無料・広告なしに保つのに役立ちます。';

  @override
  String get smallTip => '少額チップ';

  @override
  String get mediumTip => '中額チップ';

  @override
  String get largeTip => '高額チップ';

  @override
  String get donationOptionsUnavailable => '寄付オプションはまだ利用できません。';

  @override
  String get donationOptionsSetup =>
      'RevenueCat キーとストア製品 (tip_small, tip_medium, tip_large) を追加して再試行してください。';

  @override
  String get feedbackSubject => 'Digital Minaret へのフィードバック';

  @override
  String get mailCouldNotBeOpened => 'メールアプリを開けませんでした。';

  @override
  String get openMailApp => 'メールアプリを開く';

  @override
  String get subject => '件名';

  @override
  String get yourFeedback => 'ご意見';

  @override
  String get feedbackHint => '既定のメールアプリが、入力済みフィールドで開きます。';

  @override
  String get privacyNoAccountRequired => 'アカウント不要';

  @override
  String get privacyNoAccountBody => 'アカウント作成や個人プロフィール情報の共有なしにアプリを使用できます。';

  @override
  String get privacyLocationOnDevice => '位置情報はデバイス内のみ';

  @override
  String get privacyLocationBody => '位置情報は礼拝時刻の計算にのみ使用され、お使いの携帯にローカルに保存されます。';

  @override
  String get privacyNoAds => '広告なし、トラッカーなし';

  @override
  String get privacyNoAdsBody => 'このアプリには広告 SDK もデフォルトの分析トラッキングもありません。';

  @override
  String get privacyNotificationsLocal => '通知はローカル';

  @override
  String get privacyNotificationsBody => '礼拝通知はデバイス上で直接スケジュールされ、トリガーされます。';

  @override
  String get privacyFeedbackOptIn => 'フィードバックはオプトイン';

  @override
  String get privacyFeedbackBody =>
      'フィードバックをタップすると、既定のメールアプリが開きます。何も自動的に送信されません。';

  @override
  String get widgetSetupTitle => 'ウィジェットの設定';

  @override
  String get widgetLiveTitle => 'ライブウィジェット';

  @override
  String get widgetLiveBody =>
      'ウィジェットは現在の礼拝、次の礼拝、残り時間を表示します。データはアプリが礼拝時刻を計算/同期するときに更新され、タイムラインは毎分更新されます。';

  @override
  String get widgetIosTitle => 'iOS';

  @override
  String get widgetIosBody =>
      'ホーム画面を長押し > + > Digital Minaret > サイズを選択 > ウィジェットを追加。\n更新後に表示されない場合: ウィジェットを削除し、アプリを一度開いてから再追加してください。';

  @override
  String get widgetAndroidTitle => 'Android';

  @override
  String get widgetAndroidBody =>
      'ホーム画面を長押し > ウィジェット > Digital Minaret。\n古い場合: ウィジェットを削除/再追加し、最新の時刻をプッシュするためにアプリを一度開いてください。';

  @override
  String get widgetTypographyTitle => 'タイポグラフィ';

  @override
  String get widgetTypographyBody =>
      'ウィジェットのタイポグラフィは iOS と Android の両方でアプリのスタイル (Cinzel + Manrope) に揃えています。';

  @override
  String get language => '言語';

  @override
  String get hijriMuharram => 'ムハッラム';

  @override
  String get hijriSafar => 'サファル';

  @override
  String get hijriRabiAwwal => 'ラビーウ・アル=アウワル';

  @override
  String get hijriRabiThani => 'ラビーウ・アッ=サーニー';

  @override
  String get hijriJumadaAwwal => 'ジュマーダー・アル=アウワル';

  @override
  String get hijriJumadaThani => 'ジュマーダー・アッ=サーニー';

  @override
  String get hijriRajab => 'ラジャブ';

  @override
  String get hijriShaaban => 'シャアバーン';

  @override
  String get hijriRamadan => 'ラマダーン';

  @override
  String get hijriShawwal => 'シャウワール';

  @override
  String get hijriDhuAlQadah => 'ズー・アル=カアダ';

  @override
  String get hijriDhuAlHijjah => 'ズー・アル=ヒッジャ';

  @override
  String hijriDateFormat(String day, String month, String year) {
    return 'ヒジュラ暦 $year 年 $month $day 日';
  }

  @override
  String get eidAlFitr => 'イード・アル=フィトル礼拝';

  @override
  String get eidAlAdha => 'イード・アル=アドハー礼拝';

  @override
  String get qibla => 'キブラ';

  @override
  String get towardsTheQibla => 'キブラの方向';

  @override
  String get compassNotAvailable => 'このデバイスではコンパスセンサーを利用できません。';

  @override
  String get locationRequiredForQibla => 'キブラの方向を判定するには位置情報が必要です。';
}
