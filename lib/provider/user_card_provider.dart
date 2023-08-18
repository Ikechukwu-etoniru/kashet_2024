import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/user_card.dart';

class UserCardProvider extends ChangeNotifier {
  Future<void> getCards() async {
    const _cardsEndpoint = '';
    final _uri = Uri.parse('$_cardsEndpoint + token');
    final response = await http.get(_uri);
    final List cardsList = json.decode(response.body);
    for (var element in cardsList) {
      _userCardList.add(element);
    }
  }

  final List<UserCard> _userCardList = [
    UserCard(
        cardNumber: 0,
        cardPin: 0,
        cvv: 0,
        expiryDate: DateTime.now(),
        cardImageUrl: 'images/kasheto_icon.png',
        bankName: 'Kasheto Wallet',
        id: '1'),
        UserCard(
        cardNumber: 1,
        cardPin: 1,
        cvv: 1,
        expiryDate: DateTime.now(),
        cardImageUrl: 'images/bank.png',
        bankName: 'Bank Card',
        id: '2'),
  ];

  List<UserCard> get userCardList {
    return [..._userCardList];
  }
}
