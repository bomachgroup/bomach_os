import 'dart:developer' as developer;
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'attendance_reminder_contracts.dart';

AttendanceReminderNotificationProvider
    createAttendanceReminderNotificationProvider() =>
        _WebReminderNotificationProvider();

class _WebReminderNotificationProvider
    implements AttendanceReminderNotificationProvider {
  @override
  Future<bool> requestPermission() async {
    if (!kIsWeb) return false;
    try {
      if (!web.window.isSecureContext) return false;
      final permission = await web.Notification.requestPermission().toDart;
      return permission.toDart == 'granted';
    } catch (error) {
      developer.log('Browser notification permission unavailable: $error');
      return false;
    }
  }

  @override
  Future<bool> showNotification({
    required String title,
    required String body,
    required String tag,
  }) async {
    if (!kIsWeb) return false;
    try {
      if (web.Notification.permission != 'granted') return false;
      try {
        web.Notification(
          title,
          web.NotificationOptions(
            body: body,
            tag: tag,
            icon: 'icons/Icon-192.png',
          ),
        );
        return true;
      } catch (_) {
        // Installed Safari PWAs use persistent notifications through the
        // active service worker in some browser versions.
        final registration =
            await web.window.navigator.serviceWorker.ready.toDart;
        await registration
            .showNotification(
              title,
              web.NotificationOptions(
                body: body,
                tag: tag,
                icon: 'icons/Icon-192.png',
              ),
            )
            .toDart;
        return true;
      }
    } catch (error) {
      developer.log('Could not display browser notification: $error');
      return false;
    }
  }
}
