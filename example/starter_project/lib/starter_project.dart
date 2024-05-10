/// Non refactored `GildedRose` class from Gilded Rose Kata
final class GildedRose {
  final List<Item> items;

  // Initializing items in the constructor
  GildedRose({
    required this.items,
  });

  /// Non refactored updateQuality method
  void updateQuality() {
    for (int i = 0; i < items.length; i++) {
      if (items[i].name != "Aged Brie" &&
          items[i].name != "Backstage passes to a TAFKAL80ETC concert") {
        if (items[i].quality > 0) {
          if (items[i].name != "Sulfuras, Hand of Ragnaros") {
            items[i].quality = items[i].quality - 1;
          }
        }
      } else {
        if (items[i].quality < 50) {
          items[i].quality = items[i].quality + 1;

          if (items[i].name == "Backstage passes to a TAFKAL80ETC concert") {
            if (items[i].sellIn < 11) {
              if (items[i].quality < 50) {
                items[i].quality = items[i].quality + 1;
              }
            }

            if (items[i].sellIn < 6) {
              if (items[i].quality < 50) {
                items[i].quality = items[i].quality + 1;
              }
            }
          }
        }
      }

      if (items[i].name != "Sulfuras, Hand of Ragnaros") {
        items[i].sellIn = items[i].sellIn - 1;
      }

      if (items[i].sellIn < 0) {
        if (items[i].name != "Aged Brie") {
          if (items[i].name != "Backstage passes to a TAFKAL80ETC concert") {
            if (items[i].quality > 0) {
              if (items[i].name != "Sulfuras, Hand of Ragnaros") {
                items[i].quality = items[i].quality - 1;
              }
            }
          } else {
            items[i].quality = items[i].quality - items[i].quality;
          }
        } else {
          if (items[i].quality < 50) {
            items[i].quality = items[i].quality + 1;
          }
        }
      }
    }
  }
}

/// `Item` class for representing items in the Gilded Rose application
final class Item {
  final String name;
  int sellIn;
  int quality;

  Item(this.name, {required this.sellIn, required this.quality});

  @override
  String toString() => 'Item{name: $name, sellIn: $sellIn, quality: $quality}';
}
