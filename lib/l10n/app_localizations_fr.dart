// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Digital Minaret';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Chourouk';

  @override
  String get prayerDhuhr => 'Dohr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerJumuah => 'Joumou\'a';

  @override
  String get prayerIftar => 'Iftar';

  @override
  String get prayerSuhoor => 'Souhour';

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
  String get suhoorEnds => 'FIN DU SOUHOUR';

  @override
  String get iftarTime => 'HEURE DE L\'IFTAR';

  @override
  String get unknown => 'Inconnu';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get welcomeSubtitle =>
      'Définissez votre localisation, la méthode de calcul et le madhab pour obtenir des horaires de prière précis.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get close => 'Fermer';

  @override
  String get ok => 'OK';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get submit => 'Envoyer';

  @override
  String get cancel => 'Annuler';

  @override
  String get download => 'Télécharger';

  @override
  String get retry => 'Réessayer';

  @override
  String get settings => 'Paramètres';

  @override
  String get stepLocation => '1. Localisation';

  @override
  String get useCurrentLocation => 'Utiliser la position actuelle';

  @override
  String get enterLocation => 'Saisir une localisation';

  @override
  String get searchLocation => 'Rechercher une localisation';

  @override
  String get cityOrAddress => 'Ville ou adresse';

  @override
  String get noLocationSelected => 'Aucune localisation sélectionnée';

  @override
  String locationSetTo(String cityName) {
    return 'Localisation définie sur $cityName. Horaires de prière actualisés.';
  }

  @override
  String get locationUpdated =>
      'Localisation mise à jour et horaires de prière actualisés.';

  @override
  String get unableToGetLocation =>
      'Impossible d\'obtenir la localisation. Essayez la recherche manuelle.';

  @override
  String get stepCalculationMethod => '2. Méthode de calcul';

  @override
  String get stepAsrMadhab => '3. Madhab pour Asr';

  @override
  String get stepFullAdhanPack => '4. Pack d\'adhan complet';

  @override
  String get adhanPackNote =>
      'L\'adhan de notification reste fixé à 30 secondes. Cette sélection est utilisée pour l\'adhan complet lorsque vous appuyez sur la notification.';

  @override
  String get methodIsna => 'Amérique du Nord (ISNA)';

  @override
  String get methodMuslimWorldLeague => 'Ligue islamique mondiale';

  @override
  String get methodTurkeyDiyanet => 'Diyanet de Türkiye';

  @override
  String get methodEgyptian => 'Égyptienne';

  @override
  String get methodKarachi => 'Karachi (UISC)';

  @override
  String get methodUmmAlQura => 'Oumm al-Qoura (La Mecque)';

  @override
  String get methodDubai => 'Dubaï (Région du Golfe)';

  @override
  String get methodSingapore => 'Singapour / Asie du Sud-Est';

  @override
  String get methodTehran => 'Téhéran (Iran)';

  @override
  String get madhabNonHanafi => 'Non-Hanafi';

  @override
  String get madhabHanafi => 'Hanafi';

  @override
  String get asrMadhab => 'Madhab pour Asr';

  @override
  String get location => 'Localisation';

  @override
  String get calculation => 'Calcul';

  @override
  String get notifications => 'Notifications';

  @override
  String get adhanAudio => 'Audio de l\'adhan';

  @override
  String get supportAndTrust => 'Soutien et confiance';

  @override
  String get permissionNeeded => 'Autorisation requise';

  @override
  String get pleaseAllowNotifications =>
      'Veuillez autoriser les notifications dans les réglages de l\'iPhone.';

  @override
  String get fullAdhanOnNotificationTap =>
      'Adhan complet en appuyant sur la notification';

  @override
  String get playDuaAfterAdhan => 'Lire le doua après l\'adhan';

  @override
  String adhanPackLabel(String packName) {
    return 'Pack d\'adhan : $packName';
  }

  @override
  String get adhanPacks => 'Packs d\'adhan';

  @override
  String get downloadAdhanPack => 'Télécharger le pack d\'adhan';

  @override
  String adhanPackDownloadPrompt(String packName) {
    return '$packName sera téléchargé sur votre appareil. Continuer ?';
  }

  @override
  String get downloadingAdhanPack => 'Téléchargement du pack d\'adhan...';

  @override
  String downloadFailed(String error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String packDownloaded(String packName) {
    return '$packName téléchargé.';
  }

  @override
  String get donate => 'Faire un don';

  @override
  String get donateSubtitle =>
      'Soutenez le développement si vous le souhaitez.';

  @override
  String get sendFeedback => 'Envoyer un commentaire';

  @override
  String get sendFeedbackSubtitle => 'Ouvrir un formulaire rapide';

  @override
  String get widgetSetup => 'Configuration du widget';

  @override
  String get widgetSetupSubtitle =>
      'Comment ajouter et actualiser le widget en direct sur l\'écran d\'accueil.';

  @override
  String get privacyNotes => 'Politique de confidentialité';

  @override
  String get privacyNotesSubtitle =>
      'Découvrez comment les données sont traitées sur l\'appareil.';

  @override
  String get thankYouForUsing => 'Merci d\'utiliser Digital Minaret.';

  @override
  String get appAlwaysFree =>
      'Cette application restera toujours sans publicité et gratuite.';

  @override
  String get rateDigitalMinaret => 'Évaluer Digital Minaret';

  @override
  String get ratePromptMessage =>
      'Appréciez-vous ce cheminement spirituel ? Vos commentaires nous aident à éclairer le chemin.';

  @override
  String get couldNotOpenLink =>
      'Impossible d\'ouvrir le lien sur cet appareil.';

  @override
  String couldNotPlayPreview(String error) {
    return 'Impossible de lire l\'aperçu de l\'adhan : $error';
  }

  @override
  String notificationsCouldNotBeScheduled(String error) {
    return 'Les notifications n\'ont pas pu être entièrement programmées : $error';
  }

  @override
  String couldNotContinue(String error) {
    return 'Impossible de continuer. Veuillez réessayer. ($error)';
  }

  @override
  String get hadithOfTheDay => 'Hadith du jour';

  @override
  String get ramadanDua => 'Doua du Ramadan';

  @override
  String get verseFromQuran => 'Verset du Coran';

  @override
  String get hadithBody =>
      'Le mois de Ramadan est venu à vous, un mois béni qu\'Allah vous a prescrit de jeûner. (Nasa\'i)';

  @override
  String get duaBody =>
      'Ô Allah, je Te demande Ton amour, l\'amour de ceux qui T\'aiment, et les actes qui me rapprochent de Ton amour.';

  @override
  String get verseBody =>
      'Ô vous qui avez cru ! Le jeûne vous a été prescrit comme il a été prescrit à ceux qui vous ont précédés, afin que vous atteigniez la piété. (Al-Baqarah 2:183)';

  @override
  String get supportTheApp => 'Soutenir l\'application';

  @override
  String get donateDescription =>
      'Cette application est gratuite et sans publicité. Si vous le souhaitez, vous pouvez soutenir le développement par un don unique.';

  @override
  String get purchaseDidNotComplete => 'L\'achat n\'a pas abouti.';

  @override
  String get thankYou => 'Merci';

  @override
  String get thankYouDonateMessage =>
      'Votre soutien compte énormément. Cela permet de maintenir l\'application gratuite et sans publicité.';

  @override
  String get smallTip => 'Petit don';

  @override
  String get mediumTip => 'Don moyen';

  @override
  String get largeTip => 'Don généreux';

  @override
  String get donationOptionsUnavailable =>
      'Les options de don ne sont pas encore disponibles.';

  @override
  String get donationOptionsSetup =>
      'Ajoutez les clés RevenueCat et les produits du store (tip_small, tip_medium, tip_large), puis réessayez.';

  @override
  String get feedbackSubject => 'Commentaire pour Digital Minaret';

  @override
  String get mailCouldNotBeOpened =>
      'L\'application Mail n\'a pas pu être ouverte.';

  @override
  String get openMailApp => 'Ouvrir l\'application Mail';

  @override
  String get subject => 'Objet';

  @override
  String get yourFeedback => 'Votre commentaire';

  @override
  String get feedbackHint =>
      'Ceci ouvre votre application de messagerie par défaut avec les champs préremplis.';

  @override
  String get privacyNoAccountRequired => 'Aucun compte requis';

  @override
  String get privacyNoAccountBody =>
      'Vous pouvez utiliser l\'application sans créer de compte ni partager de données personnelles.';

  @override
  String get privacyLocationOnDevice => 'La localisation reste sur l\'appareil';

  @override
  String get privacyLocationBody =>
      'La localisation est utilisée uniquement pour calculer les horaires de prière et est stockée localement sur votre téléphone.';

  @override
  String get privacyNoAds => 'Aucune publicité, aucun traceur';

  @override
  String get privacyNoAdsBody =>
      'L\'application ne contient aucun SDK publicitaire ni aucun suivi analytique par défaut.';

  @override
  String get privacyNotificationsLocal => 'Les notifications sont locales';

  @override
  String get privacyNotificationsBody =>
      'Les notifications de prière sont programmées et déclenchées directement sur l\'appareil.';

  @override
  String get privacyFeedbackOptIn => 'Le commentaire est facultatif';

  @override
  String get privacyFeedbackBody =>
      'Si vous appuyez sur commentaire, votre application de messagerie par défaut s\'ouvre. Rien n\'est envoyé automatiquement.';

  @override
  String get widgetSetupTitle => 'Configuration du widget';

  @override
  String get widgetLiveTitle => 'Widget en direct';

  @override
  String get widgetLiveBody =>
      'Le widget affiche la prière en cours, la prochaine prière et le temps restant. Les données se mettent à jour lorsque l\'application calcule/synchronise les horaires de prière, et la chronologie s\'actualise chaque minute.';

  @override
  String get widgetIosTitle => 'iOS';

  @override
  String get widgetIosBody =>
      'Appui long sur l\'écran d\'accueil > + > Digital Minaret > choisir la taille > Ajouter le widget.\nS\'il n\'apparaît pas après une mise à jour : supprimez le widget, ouvrez l\'application une fois, puis ajoutez-le de nouveau.';

  @override
  String get widgetAndroidTitle => 'Android';

  @override
  String get widgetAndroidBody =>
      'Appui long sur l\'écran d\'accueil > Widgets > Digital Minaret.\nSi les données sont obsolètes : supprimez/réajoutez le widget et ouvrez l\'application une fois pour envoyer les horaires à jour.';

  @override
  String get widgetTypographyTitle => 'Typographie';

  @override
  String get widgetTypographyBody =>
      'La typographie du widget est alignée avec le style de l\'application (Cinzel + Manrope) sur iOS et Android.';

  @override
  String get language => 'Langue';

  @override
  String get qibla => 'Qibla';

  @override
  String get towardsTheQibla => 'DIRECTION DE LA QIBLA';

  @override
  String get compassNotAvailable =>
      'Le capteur de boussole n\'est pas disponible sur cet appareil.';

  @override
  String get locationRequiredForQibla =>
      'La localisation est necessaire pour determiner la direction de la Qibla.';
}
