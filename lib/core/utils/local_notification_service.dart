export 'local_notification_service_mobile.dart'
    if (dart.library.html) 'local_notification_service_web.dart'
    if (dart.library.js) 'local_notification_service_web.dart'
    if (dart.library.js_interop) 'local_notification_service_web.dart';
