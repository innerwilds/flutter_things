import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// Item selection controller. 
/// 
/// Use item identity number like hashCode or an ID to select and unselect items.
///
/// For better memory safety always use primitives.
class ItemSelectionController<K> extends ValueNotifier<Set<K>> {
  /// Main ctor.
  /// 
  /// There is optional [initial] value to set.
  ItemSelectionController({Set<K>? initial}) : super(initial ?? const {});
  
  /// Whether [key] is in selection.
  bool isSelected(int key) => value.contains(key);
  
  /// Adds [key] to selection.
  void select(K key) {
    value = value.union({ key });
  }
  
  /// Removes [key] from selection.
  void unselect(K key) {
    value = value.difference({ key });
  }
  
  /// Adds or removes key to/from selection.
  void toggle(K key) {
    if (value.contains(key)) {
      unselect(key);
    } else {
      select(key);
    }
  }
  
  /// Intersection between current keys and [otherKeys].
  void intersection(Set<K> otherKeys) {
    value = value.intersection(otherKeys);
  }
}
