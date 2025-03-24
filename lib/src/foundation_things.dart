import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// Item selection controller.
///
/// Use item identity number like hashCode or an ID to select and unselect items.
///
/// For better memory safety always use primitives for [K].
class ItemSelectionController<K> extends ValueNotifier<Set<K>> {
  /// Main ctor.
  ///
  /// There is optional [initial] value to set.
  ItemSelectionController({Set<K>? initial})
                       // const {} is of type _ConstSet<Never>,
                       // so we can't do union in future.
    : super(initial ?? Set<K>.unmodifiable({}));

  /// Whether [key] is in selection.
  bool isSelected(K key) => value.contains(key);

  /// Adds [key] to selection.
  void select(K key) {
    if (value.contains(key)) {
      return;
    }
    value = Set<K>.unmodifiable(value.union({key}));
  }
  
  /// Adds all [keys] in selection.
  void selectAll(Set<K> keys) {
    if (keys.isEmpty) {
      return;
    }
    final oldValue = value;
    final newValue = value.union(keys);
    if (newValue.length == oldValue.length) {
      return;
    }
    value = Set<K>.unmodifiable(newValue);
  }

  /// Removes [key] from selection.
  void unselect(K key) {
    if (!value.contains(key)) {
      return;
    }
    value = Set<K>.unmodifiable(value.difference({key}));
  }

  /// Removes all [keys] from selection.
  void unselectAll(Set<K> keys) {
    if (keys.isEmpty) {
      return;
    }
    final oldValue = value;
    final newValue = value.difference(keys);
    if (newValue.length == oldValue.length) {
      return;
    }
    value = Set<K>.unmodifiable(newValue);
  }

  /// Adds or removes key to/from selection.
  void toggle(K key) {
    if (value.contains(key)) {
      unselect(key);
    } else {
      select(key);
    }
  }

  /// Intersection between current selected keys and [keys].
  void intersection(Set<K> keys) {
    if (keys.isEmpty) {
      return;
    }
    final oldValue = value;
    final newValue = value.intersection(keys);
    if (newValue.length == oldValue.length) {
      return;
    }
    value = Set<K>.unmodifiable(newValue);
  }
  
  /// Clears selection.
  void clear() {
    if (value.isEmpty) {
      return;
    }
    value = Set<K>.unmodifiable({});
  }
}

/// Lerps between two strings.
///
/// It just interpolates between
///
/// ABCD -> EFGH:
/// ABCD
/// BCDE
/// CDEF
/// DEFG
/// EFGH
///
/// ABCefg -> EFG
/// ABCefg
/// BCDefg
/// CDEef
/// DEFe
/// EFG
///
/// ABC -> EFGefg
/// ABC
/// BCDe
/// CDEef
/// DEFef
/// EFGefg
///
/// For single-code characters it interpolates, otherwise it swaps.
///
/// So emoji 'smile' is swaps to 'heart' on 0.5.
///
/// Привет, мир! -> مرحبا بالعالم! :
/// Imagine it.
String lerpString(String from, String to, double t) {
  var ending = Characters.empty;

  int endMode;
  Characters fromCharacters;
  Characters toCharacters;
  Characters quotient;

  if (from.characters.length > to.characters.length) {
    fromCharacters = from.characters.take(to.length);
    toCharacters = to.characters;
    quotient = from.characters.skip(to.length);
    endMode = -1;
  } else {
    fromCharacters = from.characters;
    toCharacters = to.characters.take(from.length);
    quotient = to.characters.skip(from.length);
    endMode = from.characters.length < to.characters.length ? 1 : 0;
  }

  if (t == 0.0) return '$fromCharacters${ endMode == -1 ? quotient : '' }';
  if (t == 1.0) return '$toCharacters${ endMode == 1 ? quotient : '' }';

  switch (endMode) {
    case 1:
      final quotientCurrentLength = (t * quotient.length).round();
      ending = quotient.take(quotientCurrentLength);
    case -1:
      final quotientCurrentLength = (t * quotient.length).round();
      ending = quotient.take(quotient.length - quotientCurrentLength);
  }

  final current = StringBuffer();

  /// from length is equals to to length
  final fromIterator = fromCharacters.iterator;
  final toIterator = toCharacters.iterator;

  while (fromIterator.moveNext() && toIterator.moveNext()) {
    final fromCodeUnits = fromIterator.utf16CodeUnits;
    final toCodeUnits = toIterator.utf16CodeUnits;

    if (fromCodeUnits.length >= 2 || toCodeUnits.length >= 2) {
      if (t < 0.5) {
        current.write(fromIterator.current);
      } else {
        current.write(toIterator.current);
      }
    } else {
      final fromCode = fromCodeUnits.first;
      final toCode = toCodeUnits.first;
      final currentCode = _lerpInt(fromCode, toCode, t);
      current.writeCharCode(currentCode);
    }
  }

  current.write(ending);

  return current.toString();
}

int _lerpInt(int a, int b, double t) {
  return (a + (b - a) * t).round();
}
