import 'signal.dart';

class State<T> {
  final String label;
  final List<String> signals;
  final void Function(Signal, T) onSignal;
  final Map<int, bool Function(T)> transitions;

  State({
    required this.label,
    required this.signals,
    required this.onSignal,
    required this.transitions,
  });
}
