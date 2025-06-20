import 'dart:js_interop';
// import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

class GamepadController {
  List<web.Gamepad?> availableGamepads = [];
  web.Gamepad? currentGamepad;
  bool get hasGamepad => availableGamepads.isNotEmpty;
  JSFunction get updateJS => update.toJS;
  JSFunction get onDisconnectJS => onDisconnect.toJS;

  GamepadController() {
    _populateGamepads();
  }

  void _populateGamepads() {
    final JSArray<web.Gamepad?> gamepadsJS = web.window.navigator.getGamepads();

    availableGamepads = gamepadsJS.toDart;
  }

  void update() {
    _populateGamepads();
  }

  void onDisconnect() {
    currentGamepad = null;
    availableGamepads = [];
  }
}
