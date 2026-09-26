import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app_logger.dart';

/// A scheduled reminder, described in already-localised text.
///
/// The service deliberately knows nothing about mantras or goals: callers hand
/// it the wording, which keeps notification copy translatable and testable.
@immutable
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
  });

  final int id;
  final int hour;
  final int minute;
  final String title;
  final String body;
}

/// Local notifications. No server, no push tokens — the device schedules its
/// own reminders in the user's own time zone.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String channelId = 'japmala.reminders';
  static const String channelName = 'Jaap reminders';
  static const String channelDescription =
      'Gentle daily reminders for your Naam Jap';

  bool _initialised = false;
  bool get isInitialised => _initialised;

  Future<void> init() async {
    if (_initialised) return;
    try {
      tzdata.initializeTimeZones();
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } on Object catch (error, stack) {
      // A missing zone must not stop the app from counting Jaap.
      AppLogger.e('Time zone lookup failed; reminders use UTC', error, stack);
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Permission is requested when the user first turns a reminder on,
          // not on a cold first launch.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.defaultImportance,
          ),
        );

    _initialised = true;
  }

  /// Asks for permission at the moment the user enables a reminder.
  Future<bool> requestPermission() async {
    await init();
    try {
      if (Platform.isIOS) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      }
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return granted ?? false;
    } on Object catch (error, stack) {
      AppLogger.e('Notification permission request failed', error, stack);
      return false;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    await init();
    try {
      if (Platform.isAndroid) {
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.areNotificationsEnabled() ??
            false;
      }
    } on Object catch (error, stack) {
      AppLogger.e('Could not read notification state', error, stack);
    }
    return true;
  }

  /// Replaces every scheduled reminder with [reminders]. Rescheduling
  /// wholesale is simpler to reason about than diffing, and cheap.
  Future<void> sync(List<ScheduledReminder> reminders) async {
    await init();
    await cancelAll();
    for (final reminder in reminders) {
      await scheduleDaily(reminder);
    }
    AppLogger.i('Scheduled ${reminders.length} reminder(s)');
  }

  Future<void> scheduleDaily(ScheduledReminder reminder) async {
    await init();
    try {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: _nextInstanceOf(reminder.hour, reminder.minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        // Inexact scheduling avoids asking for the exact-alarm permission,
        // which a reminder like this does not warrant.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on Object catch (error, stack) {
      AppLogger.e('Could not schedule reminder ${reminder.id}', error, stack);
    }
  }

  Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
