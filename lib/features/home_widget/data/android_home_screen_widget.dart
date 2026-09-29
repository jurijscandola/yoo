import 'dart:convert';
import 'dart:io' show Platform;

import 'package:home_widget/home_widget.dart';

import '../domain/home_screen_widget.dart';
import '../domain/widget_snapshot.dart';

/// [HomeScreenWidget] backed by home_widget and the Glance widget in
/// `android/app/src/main/kotlin/com/app/yoo/widget/`. Does nothing on other
/// platforms (the iOS WidgetKit extension does not exist yet).
class AndroidHomeScreenWidget implements HomeScreenWidget {
  const AndroidHomeScreenWidget();

  /// Key read by the native widget (YooWidget.kt).
  static const dataKey = 'yoo_widget';

  /// The Glance receiver declared in AndroidManifest.xml.
  static const receiver = 'com.app.yoo.widget.YooWidgetReceiver';

  @override
  Future<void> publish(WidgetSnapshot snapshot, {required List<DateTime> redrawAt}) async {
    if (!Platform.isAndroid) return;
    await HomeWidget.saveWidgetData<String>(dataKey, jsonEncode(snapshot.toJson()));
    await HomeWidget.updateWidget(qualifiedAndroidName: receiver);
    await HomeWidget.scheduleWidgetUpdates(redrawAt, qualifiedAndroidName: receiver);
  }
}
