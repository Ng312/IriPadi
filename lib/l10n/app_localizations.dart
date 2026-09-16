import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('ms'),
    Locale('zh'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'language.english': 'English',
      'language.malay': 'Malay',
      'language.chinese': 'Chinese',
      'language.title': 'Choose your language',
      'language.subtitle': 'Pick English, Malay, or Chinese before you start.',
      'language.continue': 'Continue',
      'language.settingTitle': 'Language',
      'language.current': 'Current language',
      'language.settingNote': 'Switch app language anytime.',
      'home.tagline.line1': 'A smart AWD based',
      'home.tagline.line2': 'paddy irrigation system',
      'action.getStarted': 'Get Started',
      'action.next': 'Next',
      'action.cancel': 'Cancel',
      'action.save': 'Save',
      'action.edit': 'Edit',
      'action.ok': 'OK',
      'action.useCurrentLocation': 'Use Current Location',
      'action.fetchingLocation': 'Fetching location...',
      'action.turnOn': 'TURN ON',
      'action.turnOff': 'TURN OFF',
      'form.paddyPrompt': 'Please insert your paddy field data',
      'form.plantingMethod': 'Planting Method',
      'form.selectMethod': 'Select a method',
      'form.startDate': 'Start Date',
      'form.location': 'Location',
      'form.searchLocation': 'Search location',
      'form.validation.pickDate': 'Please pick a start date',
      'form.validation.enterLocation': 'Please enter a location',
      'form.validation.selectPlantingMethod': 'Please select a planting method',
      'form.validation.fillRequired': 'Please fill all required fields',
      'form.validation.locationNotFound': 'Could not find that location',
      'form.validation.locationNotFoundDetailed':
          'Could not find that location. Please refine the name.',
      'method.directSeeding': 'Direct Seeding',
      'method.transplanting': 'Transplanting',
      'nav.dashboard': 'Dashboard',
      'nav.log': 'Log',
      'nav.schedule': 'Schedule',
      'nav.info': 'Info',
      'page.dashboard.title': 'Dashboard',
      'page.irrigationLog.title': 'Irrigation Log',
      'page.schedule.title': 'Irrigation Schedule Recommendation',
      'page.schedule.directSeeding': 'Direct Seeding Method',
      'page.schedule.transplanting': 'Transplanting Method',
      'page.fieldInfo.title': 'Paddy Field Info',
      'page.fieldInfo.editTitle': 'Edit Field Info',
      'page.fieldInfo.startNewPlanting': 'Start New Planting',
      'page.fieldInfo.dialogTitle': 'Start new planting?',
      'page.fieldInfo.dialogBody':
          'This will clear the current paddy field info so you can enter a new cycle.',
      'page.fieldInfo.notSet': 'Not set',
      'paddy.field': 'Paddy Field',
      'paddy.plantingDate': 'Planting Date',
      'paddy.days': 'Days',
      'paddy.growthStage': 'Growth Stage',
      'log.filter.all': 'All',
      'log.filter.today': 'Today',
      'log.filter.last3Days': 'Last 3 days',
      'log.filter.last7Days': 'Last 7 days',
      'log.filter.older': 'Older',
      'log.header.date': 'Date',
      'log.header.time': 'Time',
      'log.header.waterLevelgraph': 'Water Level Graph',
      'log.header.waterLevel': 'Water Level',
      'log.header.irrigation': 'Irrigation',
      'log.empty': 'No records for this range',
      'log.sampleNote': 'Sample data shown (No live data yet)',
      'waterlevel.sampleTitle': 'Sample Data only',
      'waterlevel.sampleNote': 'Sample data shown (No live data yet)',
      'waterlevel.sampleDescription':
          'As this system is in a testing phase without IoT devices for every user, live data isn’t available. The data shown is for reference only.\n\nLive data would only be available when connected to IoT device.',
      'waterlevel.current': 'Current water level',
      'waterlevel.target': 'Target water level',
      'irrigation.control': 'Water Pump Control',
      'irrigation.status': 'Status : ',
      'irrigation.statusOn': 'ON',
      'irrigation.statusOff': 'OFF',
      'irrigation.currently': 'Water pump is currently ',
      'irrigation.modeAuto': 'Auto',
      'irrigation.modeManual': 'Manual',
      'schedule.header.growthStage': 'Growth Stage',
      'schedule.header.days': 'Days',
      'schedule.header.strategy': 'Strategy',
      'stage.Germination': 'Germination',
      'stage.Transplanting': 'Transplanting',
      'stage.Emergence': 'Emergence',
      'stage.Pre-AWD Transition': 'Pre-AWD Transition',
      'stage.Early Vegetative': 'Early Vegetative',
      'stage.Tillering': 'Tillering',
      'stage.Tilllering': 'Tillering',
      'stage.Vegetative Growth': 'Vegetative Growth',
      'stage.Active Tillering': 'Active Tillering',
      'stage.Panicle Initiation': 'Panicle Initiation',
      'stage.Flowering': 'Flowering',
      'stage.Grain Filing': 'Grain Filing',
      'stage.Ripening': 'Ripening',
      'stage.Harvest': 'Harvest',
      'strategy.Flood': 'Flood to 5cm above surface',
      'strategy.ShallowWater': 'Maintain shallow water (2–3 cm)',
      'strategy.AWDDelay':
          'Wait until seedlings reach ~10 cm before starting AWD cycles',
      'strategy.SafeAWD': 'Safe AWD',
      'strategy.Ponded': 'Maintain ponded water at 5cm',
      'strategy.StopIrrigation': 'Stop irrigation; let field dry naturally',
      'strategy.DryField': 'Dry field completely',
      'growthStage.notSet': 'Not set',
      'language.saved': 'Continue',
      'weather.chooseLocation':
          'Please choose a location so we can fetch its weather.',
      'growthStage.waterPumpOn': 'ON',
      'growthStage.waterPumpOff': 'OFF',
      'weather.condition.clear': 'Clear',
      'weather.condition.sunny': 'Sunny',
      'weather.condition.cloudy': 'Cloudy',
      'weather.condition.partlyCloudy': 'Partly cloudy',
      'weather.condition.mostlyCloudy': 'Mostly cloudy',
      'weather.condition.rain': 'Rain',
      'weather.condition.drizzle': 'Drizzle',
      'weather.condition.thunderstorm': 'Thunderstorm',
      'weather.condition.windy': 'Windy',
      'page.schedule.safeAwdNote':
          'Safe AWD: Repeat cycles of drying the field (~15cm below soil) and then re-flooding (~5cm above soil) to save water and strengthen roots.',
    },
    'ms': {
      'language.english': 'Inggeris',
      'language.malay': 'Bahasa Melayu',
      'language.chinese': 'Cina',
      'language.title': 'Pilih bahasa anda',
      'language.subtitle': 'Pilih Inggeris, Bahasa Melayu, atau Cina sebelum anda mula.',
      'language.continue': 'Teruskan',
      'language.settingTitle': 'Bahasa',
      'language.current': 'Bahasa semasa',
      'language.settingNote': 'Tukar bahasa aplikasi bila-bila masa.',
      'home.tagline.line1': 'Sistem AWD pintar',
      'home.tagline.line2': 'untuk pengairan sawah padi',
      'action.getStarted': 'Mula',
      'action.next': 'Seterusnya',
      'action.cancel': 'Batal',
      'action.save': 'Simpan',
      'action.edit': 'Kemaskini',
      'action.ok': 'OK',
      'action.useCurrentLocation': 'Gunakan lokasi semasa',
      'action.fetchingLocation': 'Sedang mendapatkan lokasi...',
      'action.turnOn': 'BUKA',
      'action.turnOff': 'TUTUP',
      'form.paddyPrompt': 'Sila masukkan data sawah padi anda',
      'form.plantingMethod': 'Kaedah penanaman',
      'form.selectMethod': 'Pilih kaedah penanaman',
      'form.startDate': 'Tarikh bermula tanaman',
      'form.location': 'Lokasi',
      'form.searchLocation': 'Cari lokasi',
      'form.validation.pickDate': 'Sila pilih tarikh bermula',
      'form.validation.enterLocation': 'Sila masukkan lokasi',
      'form.validation.selectPlantingMethod': 'Sila pilih kaedah penanaman',
      'form.validation.fillRequired': 'Sila isi semua informasi wajib',
      'form.validation.locationNotFound': 'Lokasi tidak dijumpai',
      'form.validation.locationNotFoundDetailed': 'Lokasi tidak dijumpai. Sila perincikan nama.',
      'method.directSeeding': 'Penaburan terus',
      'method.transplanting': 'Pindah tanam',
      'nav.dashboard': 'Dashboard',
      'nav.log': 'Log',
      'nav.schedule': 'Jadual',
      'nav.info': 'Info',
      'page.dashboard.title': 'Dashboard',
      'page.irrigationLog.title': 'Log pengairan',
      'page.schedule.title': 'Cadangan jadual pengairan',
      'page.schedule.directSeeding': 'Kaedah penaburan terus',
      'page.schedule.transplanting': 'Kaedah pindah tanam',
      'page.fieldInfo.title': 'Maklumat sawah',
      'page.fieldInfo.editTitle': 'Kemaskini maklumat sawah',
      'page.fieldInfo.startNewPlanting': 'Mulakan penanaman baharu',
      'page.fieldInfo.dialogTitle': 'Mulakan penanaman baru?',
      'page.fieldInfo.dialogBody': 'Ini akan memadamkan maklumat sawah semasa supaya anda boleh masukkan kitaran baru.',
      'page.fieldInfo.notSet': 'Belum ditetapkan',
      'paddy.field': 'Maklumat Sawah',
      'paddy.plantingDate': 'Tarikh Tanaman',
      'paddy.days': 'Hari',
      'paddy.growthStage': 'Peringkat',
      'log.filter.all': 'Semua',
      'log.filter.today': 'Hari ini',
      'log.filter.last3Days': '3 hari terakhir',
      'log.filter.last7Days': '7 hari terakhir',
      'log.filter.older': 'Lebih lama',
      'log.header.date': 'Tarikh',
      'log.header.time': 'Masa',
      'log.header.waterLevelgraph': 'Graf Paras Air',
      'log.header.waterLevel': 'Paras air',
      'log.header.irrigation': 'Pengairan',
      'log.empty': 'Tiada rekod untuk julat ini',
      'log.sampleNote': 'Contoh data dipaparkan (Tiada data sebenar lagi)',
      'waterlevel.sampleTitle': 'Hanya Contoh Data',
      'waterlevel.sampleNote': 'Contoh data dipaparkan (Tiada data sebenar lagi)',
      'waterlevel.sampleDescription':
          'Disebabkan sistem ini masih dalam fasa ujian tanpa peranti IoT untuk setiap pengguna, data sebenar tidak tersedia. Data yang dipaparkan hanyalah untuk rujukan.\n\nData sebenaaar hanya akan tersedia dengan penggunaan peranti IoT.',
      'waterlevel.current': 'Paras air semasa',
      'waterlevel.target': 'Sasaran paras air',
      'irrigation.control': 'Kawalan Pam Air',
      'irrigation.status': 'Status : ',
      'irrigation.statusOn': 'BUKA',
      'irrigation.statusOff': 'TUTUP',
      'irrigation.currently': 'Pam air kini ',
      'irrigation.modeAuto': 'Automatik',
      'irrigation.modeManual': 'Manual',
      'schedule.header.growthStage': 'Peringkat pertumbuhan',
      'schedule.header.days': 'Hari',
      'schedule.header.strategy': 'Strategi',
      'stage.Germination': 'Percambahan',
      'stage.Transplanting': 'Pindah Tanam',
      'stage.Emergence': 'Kemunculan',
      'stage.Pre-AWD Transition': 'Peralihan Pra-AWD',
      'stage.Early Vegetative': 'Vegetatif Awal',
      'stage.Tillering': 'Pembentukan Tunas',
      'stage.Tilllering': 'Pembentukan Tunas',
      'stage.Vegetative Growth': 'Pertumbuhan Vegetatif',
      'stage.Active Tillering': 'Pembentukan Tunas Aktif',
      'stage.Panicle Initiation': 'Permulaan Panikel',
      'stage.Flowering': 'Berbunga',
      'stage.Grain Filing': 'Pengisian bijirin',
      'stage.Ripening': 'Pematangan',
      'stage.Harvest': 'Penuaian',
      'strategy.Flood': 'Banjiri hingga 5cm atas permukaan tanah',
      'strategy.ShallowWater': 'Pastikan air cetek (2–3 cm)',
      'strategy.AWDDelay': 'Tunggu sehingga anak pokok ~10 cm sebelum mula kitaran AWD',
      'strategy.SafeAWD': 'AWD selamat',
      'strategy.Ponded': 'Kekalkan air setinggi 5cm',
      'strategy.StopIrrigation':
          'Hentikan pengairan; biarkan sawah kering',
      'strategy.DryField': 'Biarkan sawah kering sepenuhnya',
      'growthStage.notSet': 'Belum ditetapkan',
      'language.saved': 'Teruskan',
      'weather.chooseLocation': 'Sila pilih lokasi sawah padi untuk ramalan cuaca',
      'growthStage.waterPumpOn': 'BUKA',
      'growthStage.waterPumpOff': 'TUTUP',
      'weather.condition.clear': 'Jelas',
      'weather.condition.sunny': 'Cerah',
      'weather.condition.cloudy': 'Berawan',
      'weather.condition.partlyCloudy': 'Separuh berawan',
      'weather.condition.mostlyCloudy': 'Sebahagian besar berawan',
      'weather.condition.rain': 'Hujan',
      'weather.condition.drizzle': 'Gerimis',
      'weather.condition.thunderstorm': 'Ribut petir',
      'weather.condition.windy': 'Berangin',
      'page.schedule.safeAwdNote':
          'AWD selamat: Ulang kitaran mengeringkan sawah (sekitar 15cm bawah permukaan tanah) dan kemudian banjiri semula (sekitar 5cm atas permukaan tanah) untuk menjimatkan air dan menguatkan akar.',
    },
    'zh': {
      'language.english': '英语',
      'language.malay': '马来语',
      'language.chinese': '中文',
      'language.title': '选择您的语言',
      'language.subtitle': '开始前请选择英语、马来语或中文。',
      'language.continue': '继续',
      'language.settingTitle': '语言',
      'language.current': '当前语言',
      'language.settingNote': '可随时切换应用语言。',
      'home.tagline.line1': '基于 AWD 的智能',
      'home.tagline.line2': '稻田灌溉系统',
      'action.getStarted': '开始使用',
      'action.next': '下一步',
      'action.cancel': '取消',
      'action.save': '保存',
      'action.edit': '编辑',
      'action.ok': '好的',
      'action.useCurrentLocation': '使用当前位置',
      'action.fetchingLocation': '正在获取位置...',
      'action.turnOn': '开启',
      'action.turnOff': '关闭',
      'form.paddyPrompt': '请输入您的稻田信息',
      'form.plantingMethod': '种植方式',
      'form.selectMethod': '请选择方式',
      'form.startDate': '开始日期',
      'form.location': '位置',
      'form.searchLocation': '搜索位置',
      'form.validation.pickDate': '请选择开始日期',
      'form.validation.enterLocation': '请输入位置',
      'form.validation.selectPlantingMethod': '请选择种植方式',
      'form.validation.fillRequired': '请填写所有必填字段',
      'form.validation.locationNotFound': '找不到该位置',
      'form.validation.locationNotFoundDetailed': '找不到该位置，请尝试更精确的名称。',
      'method.directSeeding': '直接播种',
      'method.transplanting': '移苗种植',
      'nav.dashboard': '主页',
      'nav.log': '记录',
      'nav.schedule': '计划',
      'nav.info': '信息',
      'page.dashboard.title': '主页',
      'page.irrigationLog.title': '灌溉记录',
      'page.schedule.title': '灌溉推荐计划',
      'page.schedule.directSeeding': '直接播种方式',
      'page.schedule.transplanting': '移苗种植方式',
      'page.fieldInfo.title': '稻田信息',
      'page.fieldInfo.editTitle': '编辑稻田信息',
      'page.fieldInfo.startNewPlanting': '开始新的种植',
      'page.fieldInfo.dialogTitle': '开始新的种植？',
      'page.fieldInfo.dialogBody': '这将清除当前稻田信息，以便输入新的周期。',
      'page.fieldInfo.notSet': '未设置',
      'paddy.field': '稻田信息',
      'paddy.plantingDate': '种植日期',
      'paddy.days': '天数',
      'paddy.growthStage': '生长阶段',
      'log.filter.all': '全部',
      'log.filter.today': '今天',
      'log.filter.last3Days': '最近3天',
      'log.filter.last7Days': '最近7天',
      'log.filter.older': '更早',
      'log.header.date': '日期',
      'log.header.time': '时间',
      'log.header.waterLevelgraph': '田里水位变化图',
      'log.header.waterLevel': '水位',
      'log.header.irrigation': '灌溉状态',
      'log.empty': '该范围内没有记录',
      'log.sampleNote': '正在显示参考数据（暂无实时数据）',
      'waterlevel.sampleTitle': '目前仅展示参考数据',
      'waterlevel.sampleNote': '正在显示参考数据（暂无实时数据）',
      'waterlevel.sampleDescription':
          '由于此系统暂为测试阶段，无法提供为每个用户连接物联网设备，因此暂无实时数据，当前展示为参考数据。\n\n连接到物联网设备即可获取实时数据。',
      'waterlevel.current': '当前水位',
      'waterlevel.target': '目标水位',
      'irrigation.control': '水泵控制',
      'irrigation.status': '状态：',
      'irrigation.statusOn': '开启',
      'irrigation.statusOff': '关闭',
      'irrigation.currently': '水泵当前',
      'irrigation.modeAuto': '自动',
      'irrigation.modeManual': '手动',
      'schedule.header.growthStage': '生长阶段',
      'schedule.header.days': '天数',
      'schedule.header.strategy': '策略',
      'stage.Germination': '发芽',
      'stage.Transplanting': '移苗',
      'stage.Emergence': '出苗',
      'stage.Pre-AWD Transition': 'AWD 过渡前',
      'stage.Early Vegetative': '早期营养生长',
      'stage.Tillering': '分蘖',
      'stage.Tilllering': '分蘖',
      'stage.Vegetative Growth': '营养生长',
      'stage.Active Tillering': '旺盛分蘖',
      'stage.Panicle Initiation': '抽穗始期',
      'stage.Flowering': '开花',
      'stage.Grain Filling': '灌浆',
      'stage.Ripening': '成熟',
      'stage.Harvest': '收获',
      'strategy.Flood': '灌水至高于地表5cm',
      'strategy.ShallowWater': '保持浅水（2–3cm）',
      'strategy.AWDDelay': '苗高约10cm 后再开始 AWD 循环',
      'strategy.SafeAWD': '安全 AWD',
      'strategy.Ponded': '保持约5cm浅灌',
      'strategy.StopIrrigation': '停止灌溉，让田地自然干燥',
      'strategy.DryField': '完全晾干田地',
      'growthStage.notSet': '未设置',
      'language.saved': '继续',
      'weather.chooseLocation': '请选择位置以获取天气信息。',
      'growthStage.waterPumpOn': '开启',
      'growthStage.waterPumpOff': '关闭',
      'weather.condition.clear': '晴朗',
      'weather.condition.sunny': '晴天',
      'weather.condition.cloudy': '多云',
      'weather.condition.partlyCloudy': '局部多云',
      'weather.condition.mostlyCloudy': '阴天',
      'weather.condition.rain': '下雨',
      'weather.condition.drizzle': '小雨',
      'weather.condition.thunderstorm': '雷暴',
      'weather.condition.windy': '有风',
      'page.schedule.safeAwdNote':
          '安全 AWD：反复循环“干-湿”步骤, 让田间水位降到土位下 15 厘米，再灌溉至土面上 5 厘米浅水，以节水并促进根系。',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String failedToRetrieveLocation(Object error) {
    if (locale.languageCode == 'zh') {
      return '获取位置失败：$error';
    }
    if (locale.languageCode == 'ms') {
      return 'Gagal mendapatkan lokasi: $error';
    }
    return 'Failed to retrieve location: $error';
  }

  String weatherFetchFailed(Object error) {
    if (locale.languageCode == 'zh') {
      return '天气获取失败：$error';
    }
    if (locale.languageCode == 'ms') {
      return 'Gagal mendapatkan cuaca: $error';
    }
    return 'Weather fetch failed: $error';
  }

  String weatherRaining(String? location) {
    if (locale.languageCode == 'zh') {
      return '当前${location ?? '所在区域'}正在下雨。';
    }
    if (locale.languageCode == 'ms') {
      return 'Sekarang ${location ?? 'kawasan anda'} sedang hujan.';
    }
    return 'It’s currently raining in ${location ?? 'your area'}.';
  }

  String weatherRainChance(int probability, String hour) {
    if (locale.languageCode == 'zh') {
      return '目前没有下雨，大约在$hour:00有 $probability% 的降雨概率。';
    }
    if (locale.languageCode == 'ms') {
      return 'Sekarang tidak hujan, tetapi terdapat kemungkinan $probability% sekitar jam $hour:00.';
    }
    return 'No rain right now, but there’s a $probability% chance around $hour:00.';
  }

  String weatherNoRainExpected(String condition) {
    final translated = weatherCondition(condition);
    if (locale.languageCode == 'zh') {
      return '接下来几小时没有降雨，天气$translated。';
    }
    if (locale.languageCode == 'ms') {
      return 'Tidak dijangka hujan dalam beberapa jam akan datang. Cuacanya kelihatan ${translated.toLowerCase()}.';
    }
    return 'No rain expected in the next few hours. It looks ${translated.toLowerCase()}.';
  }

  String growthStageLabel(String stage) {
    final translated = t('stage.$stage');
    if (translated == 'stage.$stage') {
      return stage;
    }
    return translated;
  }

  String strategyLabel(String strategyKey) {
    return t(strategyKey);
  }

  String waterLevelWithUnit(num value) {
    final formatted = (value is double && value % 1 != 0)
        ? value.toStringAsFixed(1)
        : value.toString();
    return '$formatted cm';
  }

  String irrigationStatusText(bool isOn) {
    return isOn ? t('irrigation.statusOn') : t('irrigation.statusOff');
  }

  String irrigationCurrentStatus(bool isOn) {
    if (locale.languageCode == 'zh') {
      return '水泵当前已${isOn ? '开启' : '关闭'}';
    }
    if (locale.languageCode == 'ms') {
      return 'Pam air kini ${isOn ? 'buka' : 'tutup'}.';
    }
    return 'Water pump is currently ${isOn ? 'ON' : 'OFF'}';
  }

  String irrigationModeText(bool isManual) {
    return isManual ? t('irrigation.modeManual') : t('irrigation.modeAuto');
  }

  String weatherCondition(String condition) {
    final lower = condition.toLowerCase();
    String? key;
    if (lower.contains('thunder')) {
      key = 'weather.condition.thunderstorm';
    } else if (lower.contains('drizzle')) {
      key = 'weather.condition.drizzle';
    } else if (lower.contains('rain')) {
      key = 'weather.condition.rain';
    } else if (lower.contains('mostly')) {
      key = 'weather.condition.mostlyCloudy';
    } else if (lower.contains('partly')) {
      key = 'weather.condition.partlyCloudy';
    } else if (lower.contains('cloud')) {
      key = 'weather.condition.cloudy';
    } else if (lower.contains('sun')) {
      key = 'weather.condition.sunny';
    } else if (lower.contains('wind')) {
      key = 'weather.condition.windy';
    }
    if (key == null) return condition;
    final translated = t(key);
    if (translated == key) return condition;
    return translated;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
