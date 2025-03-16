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
