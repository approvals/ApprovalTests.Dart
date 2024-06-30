/// Item class for testing
class JsonItem {
  final int id;
  final String name;
  final SubItem subItem;
  final AnotherItem anotherItem;

  const JsonItem({
    required this.id,
    required this.name,
    required this.subItem,
    required this.anotherItem,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subItem': subItem.toJson(),
        'anotherItem': anotherItem.toJson(),
      };
}

/// Sub item class for testing
class SubItem {
  final int id;
  final String name;
  final List<AnotherItem> anotherItems;

  const SubItem({
    required this.id,
    required this.name,
    required this.anotherItems,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'anotherItems': anotherItems.map((e) => e.toJson()).toList(),
      };
}

/// Another item class for testing
class AnotherItem {
  final int id;
  final String name;

  const AnotherItem({required this.id, required this.name});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

/// Item without `toJson` method
class ErrorItem {
  final int id;
  final String name;

  const ErrorItem({required this.id, required this.name});
}
