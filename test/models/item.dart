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
}

/// Another item class for testing
class AnotherItem {
  final int id;
  final String name;

  const AnotherItem({required this.id, required this.name});
}
