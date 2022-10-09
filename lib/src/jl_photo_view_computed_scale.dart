/// A class that work as a enum. It overloads the operator `*` saving the double as a multiplier.
///
/// ```
/// JLPhotoViewComputedScale.contained * 2
/// ```
///
class JLPhotoViewComputedScale {
  const JLPhotoViewComputedScale._internal(this._value, [this.multiplier = 1.0]);

  final String _value;
  final double multiplier;

  @override
  String toString() => 'Enum.$_value';

  static const contained = const JLPhotoViewComputedScale._internal('contained');
  static const covered = const JLPhotoViewComputedScale._internal('covered');

  JLPhotoViewComputedScale operator *(double multiplier) {
    return JLPhotoViewComputedScale._internal(_value, multiplier);
  }

  JLPhotoViewComputedScale operator /(double divider) {
    return JLPhotoViewComputedScale._internal(_value, 1 / divider);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JLPhotoViewComputedScale &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
