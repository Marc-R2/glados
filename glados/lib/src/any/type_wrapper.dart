part of '../../glados.dart';

class _TypeWrapper<T> {
  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
