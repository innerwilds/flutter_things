import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// Item selection controller. 
/// 
/// Use item identity number like hashCode to select and unselect item.
class ItemSelectionController extends ValueNotifier<Set<int>> {
  /// Main ctor.
  /// 
  /// There is optional [initial] value to set.
  ItemSelectionController({Set<int>? initial}) : super(initial ?? const {});
  
  /// Whether [key] is in selection.
  bool isSelected(int key) => value.contains(key);
  
  /// Adds [key] to selection.
  void select(int key) {
    value = value.union({ key });
  }
  
  /// Removes [key] from selection.
  void unselect(int key) {
    value = value.difference({ key });
  }
  
  /// Adds or removes key to/from selection.
  void toggle(int key) {
    if (value.contains(key)) {
      unselect(key);
    } else {
      select(key);
    }
  }
  
  /// Intersection between current keys and [otherKeys].
  void intersection(Set<int> otherKeys) {
    value = value.intersection(otherKeys);
  }
}