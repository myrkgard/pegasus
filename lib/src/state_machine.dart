import 'dart:io';
import 'signal.dart';
import 'state.dart';

class StateMachine<T> {
  final Map<int, State<T>> states;
  final int initialState;
  int _currentState;
  T data;
  final void Function(T) onDataMightHaveChanged;

  StateMachine({
    required this.states,
    required this.initialState,
    required this.data,
    required this.onDataMightHaveChanged,
  }) : _currentState = initialState {
    _move();
  }

  List<int> _getAllAcceptedTargets() {
    var res = <int>[];
    states[_currentState]!.transitions.forEach((target, guard) {
      if (guard.call(data)) {
        res.add(target);
      }
    });
    return res;
  }

  void _move() {
    List<int> allAcceptedTargets = _getAllAcceptedTargets();
    if (allAcceptedTargets.length > 1) {
      throw 'multiple accepted transitions';
    } else if (allAcceptedTargets.length == 1) {
      final targetState = allAcceptedTargets.first;
      if (_currentState == targetState) {
        throw 'transition to self';
      } else {
        _currentState = targetState;
      }
    }
    // don't do anything if allAcceptedTransitions is empty
  }

  void sendSignal(Signal signal) {
    states[_currentState]!.onSignal(signal, data);
    _move();
    onDataMightHaveChanged.call(data);
  }

  String toPlantUmlString() {
    String res = '@startuml\n';
    res += '\n';
    res += 'skinparam shadowing false\n';
    res += 'skinparam monochrome true\n';
    res += 'skinparam defaultFontName Monospaced\n'; // Monospaced [sic!]
    res += '\n';

    // all states
    states.forEach((key, value) {
      res += 'S$key : ${value.label}\\n----';
      for (final sig in value.signals) {
        res += '\\n- $sig';
      }
      res += '\n';
    });

    res += '\n';

    // pseudo start state to initial state
    res += '[*] --> S$initialState\n';

    // all transitions with their labels
    states.forEach((startState, value) {
      for (final trans in value.transitions.entries) {
        res += 'S$startState --> S${trans.key}\n';
      }
    });

    res += '\n';
    res += '@enduml\n';
    return res;
  }

  void exportToPlantUmlFile(String filePath) async {
    await File(filePath).writeAsString(toPlantUmlString());
  }
}
