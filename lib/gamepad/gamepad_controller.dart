import 'dart:js_interop';

import 'package:web/web.dart' as web;

class GamepadController {
  final void Function() onAction;
  // the base state in the browser is always 4 null slots
  List<web.Gamepad?> availableGamepads = [null, null, null, null];
  web.Gamepad? currentGamepad;
  bool get hasGamepad => availableGamepads.any((element) => element != null);

  JSFunction get updateJS => update.toJS;
  JSFunction get onDisconnectJS => onDisconnect.toJS;
  JSFunction get onActionJS => onAction.toJS;

  GamepadController(void Function() this.onAction) {
    _populateGamepads();
    web.window.requestAnimationFrame(_gameLoop.toJS);
  }

  final web.Event buttonPressedEvent = web.Event('buttonPressed');

  List<bool>? _previousButtonStates;

  void _populateGamepads() {
    final JSArray<web.Gamepad?> gamepadsJS = web.window.navigator.getGamepads();

    availableGamepads = gamepadsJS.toDart;
  }

  void update() {
    _populateGamepads();
  }

  void onDisconnect() {
    // repopulate sets back to null state
    _populateGamepads();
    currentGamepad = null;
  }

  void findCurrentGamepad() {
    // implement a selector if more than one gamepad may be connected
    // otherwise we'll assume only one at a time
    if (hasGamepad) {
      currentGamepad =
          availableGamepads.firstWhere((element) => element != null);
    }
  }

  void _gameLoop(num time) {
    // Keep the loop going for the next frame.
    web.window.requestAnimationFrame(_gameLoop.toJS);

    _populateGamepads();
    findCurrentGamepad();

    if (currentGamepad != null) {
      final gamepad = currentGamepad!;
      // The buttons property is a JSArray, so we convert it to a Dart list.
      final currentButtonStates =
          gamepad.buttons.toDart.map((b) => b.pressed).toList();

      // If this is the first frame with a gamepad, just store the state.
      if (_previousButtonStates == null ||
          _previousButtonStates!.length != currentButtonStates.length) {
        _previousButtonStates = currentButtonStates;
        return;
      }

      // Check for a button press (state changed from false to true)
      for (var i = 0; i < currentButtonStates.length; i++) {
        if (currentButtonStates[i] && !_previousButtonStates![i]) {
          onAction();
          break;
        }
      }
      _previousButtonStates = currentButtonStates;
    } else {
      _previousButtonStates = null;
    }
  }
}
