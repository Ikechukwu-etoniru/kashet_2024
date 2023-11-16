import 'package:flutter/material.dart';
import 'package:kasheto_flutter/models/user_card.dart';

class CardContainer extends StatelessWidget {
  final double width;
  final UserCard card;
  final VoidCallback action;
  const CardContainer(
      {required this.card, required this.width, required this.action, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      width: width * 0.9,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: width * 0.1,
            child: Image.asset(
              card.cardImageUrl,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(
            width: width * 0.05,
          ),
          // Kasheto wallet show different from cards
          if (card.id == '1' || card.id == '2')
            Center(
              child: Text(
                card.bankName,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          if (card.id != '1' && card.id != '2')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card.cardNumber.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(card.bankName)
              ],
            ),
          const Spacer(),
          IconButton(
            onPressed: action,
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 15,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}

class WCardContainer extends StatelessWidget {
  final double width;
  final UserCard card;
  final VoidCallback action;
  const WCardContainer(
      {required this.card, required this.width, required this.action, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        width: width * 0.9,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: width * 0.1,
              child: Image.asset(
                card.cardImageUrl,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              width: width * 0.05,
            ),
            // Kasheto wallet show different from cards
            if (card.id == '1' || card.id == '2')
              Center(
                child: Text(
                  card.bankName,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            if (card.id != '1' && card.id != '2')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card.cardNumber.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(card.bankName)
                ],
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
