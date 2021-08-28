import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});

  Map toJson() {
    List<Map> products = this.products != null
        ? this.products.map((e) => e.toJson()).toList()
        : null;
    return {
      'id': this.id,
      'amount': this.amount,
      'products': products,
      'dateTime': this.dateTime
    };
  }
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-e819d-default-rtdb.firebaseio.com/orders.json');

    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'products': jsonEncode(cartProducts),
          'dateTime': DateTime.now().toString()
        }));
    if (response.statusCode >= 400) {
      throw HttpException('Could not save orders');
    }
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: DateTime.now()));
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-e819d-default-rtdb.firebaseio.com/orders.json');
    try {
      final response = await http.get(url);
      var ordersJson = json.decode(response.body) as Map<String, dynamic>;
      if (ordersJson == null) {
        return;
      }
      List<OrderItem> ordersObj = [];
      ordersJson.forEach((key, value) {
        ordersObj.add(OrderItem(
            id: key,
            amount: value['amount'],
            products: (jsonDecode(value['products']) as List)
                .map((e) => CartItem.fromJson(e))
                .toList(),
            dateTime: DateTime.parse(value['dateTime'])));
      });
      _orders = ordersObj;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
