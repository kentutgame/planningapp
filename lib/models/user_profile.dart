import 'dart:convert';

class UserProfile {
  final String name;
  final String email;
  final String avatarEmoji;
  final String? avatarImagePath;
  final String password;
  final bool defaultAlarmHMinus1;
  final String defaultAlarmHMinus1Time;
  final bool defaultAlarmHariH;
  final String defaultAlarmHariHTime;
  final bool autoAlertFallback;
  final String themeMode; // 'dark_carbon' or 'notion_light'
  final String timezone;

  UserProfile({
    this.name = 'Sarah Wijaya',
    this.email = 'sarah.wijaya@planner.id',
    this.avatarEmoji = '👩‍💼',
    this.avatarImagePath,
    this.password = 'planner123',
    this.defaultAlarmHMinus1 = true,
    this.defaultAlarmHMinus1Time = '09:00 AM',
    this.defaultAlarmHariH = true,
    this.defaultAlarmHariHTime = '08:00 AM',
    this.autoAlertFallback = true,
    this.themeMode = 'dark_carbon',
    this.timezone = 'Asia/Jakarta (WIB - UTC+07:00)',
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarEmoji,
    String? avatarImagePath,
    String? password,
    bool? defaultAlarmHMinus1,
    String? defaultAlarmHMinus1Time,
    bool? defaultAlarmHariH,
    String? defaultAlarmHariHTime,
    bool? autoAlertFallback,
    String? themeMode,
    String? timezone,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      avatarImagePath: avatarImagePath ?? this.avatarImagePath,
      password: password ?? this.password,
      defaultAlarmHMinus1: defaultAlarmHMinus1 ?? this.defaultAlarmHMinus1,
      defaultAlarmHMinus1Time:
          defaultAlarmHMinus1Time ?? this.defaultAlarmHMinus1Time,
      defaultAlarmHariH: defaultAlarmHariH ?? this.defaultAlarmHariH,
      defaultAlarmHariHTime:
          defaultAlarmHariHTime ?? this.defaultAlarmHariHTime,
      autoAlertFallback: autoAlertFallback ?? this.autoAlertFallback,
      themeMode: themeMode ?? this.themeMode,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarEmoji': avatarEmoji,
      'avatarImagePath': avatarImagePath,
      'password': password,
      'defaultAlarmHMinus1': defaultAlarmHMinus1,
      'defaultAlarmHMinus1Time': defaultAlarmHMinus1Time,
      'defaultAlarmHariH': defaultAlarmHariH,
      'defaultAlarmHariHTime': defaultAlarmHariHTime,
      'autoAlertFallback': autoAlertFallback,
      'themeMode': themeMode,
      'timezone': timezone,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? 'Sarah Wijaya',
      email: map['email'] as String? ?? 'sarah.wijaya@planner.id',
      avatarEmoji: map['avatarEmoji'] as String? ?? '👩‍💼',
      avatarImagePath: map['avatarImagePath'] as String?,
      password: map['password'] as String? ?? 'planner123',
      defaultAlarmHMinus1: map['defaultAlarmHMinus1'] as bool? ?? true,
      defaultAlarmHMinus1Time:
          map['defaultAlarmHMinus1Time'] as String? ?? '09:00 AM',
      defaultAlarmHariH: map['defaultAlarmHariH'] as bool? ?? true,
      defaultAlarmHariHTime:
          map['defaultAlarmHariHTime'] as String? ?? '08:00 AM',
      autoAlertFallback: map['autoAlertFallback'] as bool? ?? true,
      themeMode: map['themeMode'] as String? ?? 'dark_carbon',
      timezone:
          map['timezone'] as String? ?? 'Asia/Jakarta (WIB - UTC+07:00)',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}
