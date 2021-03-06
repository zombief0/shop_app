import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final int quantity;
  final double price;
  final String title;

  CartItem(
      {@required this.id,
      @required this.quantity,
      @required this.price,
      @required this.title});

  Map toJson() => {
        'id': id,
        'quantity': quantity,
        'price': price,
        'title': title,
      };

  factory CartItem.fromJson(dynamic json) {
    return CartItem(
        id: json['id'] as String,
        quantity: json['quantity'] as int,
        price: json['price'] as double,
        title: json['title'] as String);
  }
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              quantity: existingCartItem.quantity + 1,
              price: price,
              title: title));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              quantity: 1,
              price: price,
              title: title));
    }

    notifyListeners();
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  bool isEmpty() {
    return _items.isEmpty;
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              quantity: existingCartItem.quantity - 1,
              price: existingCartItem.price,
              title: existingCartItem.title));
    } else {
      _items.remove(productId);
    }

    notifyListeners();
  }
}
