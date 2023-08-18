import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasheto_flutter/models/money_request.dart';

class MoneyRequestPage extends StatelessWidget {
  final List<MoneyRequest> mrList;
  final int pageNumber;
  const MoneyRequestPage(
      {required this.mrList, required this.pageNumber, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: mrList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.asset(
                          'images/unavailable_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(pageNumber == 0
                          ? 'You have sent no money request yet !!!!'
                          : 'You have received no money request')
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: mrList.length,
                  itemBuilder: (context, index) =>
                      MoneyRequestContainer(mr: mrList[index])));
    });
  }
}

class MoneyRequestContainer extends StatelessWidget {
  final MoneyRequest mr;
  const MoneyRequestContainer({required this.mr, Key? key}) : super(key: key);

  String _mrDate() {
    var time = mr.createdAt;
    var inDateTime = DateTime(
      int.parse(time.substring(0, 4)),
      int.parse(time.substring(5, 7)),
      int.parse(time.substring(8, 10)),
      int.parse(time.substring(11, 13)),
      int.parse(time.substring(14, 16)),
    );
    return DateFormat.yMMMMEEEEd().format(inDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.1,
              height: 70,
              child: Icon(
                mr.status == 'pending' ? Icons.pending : Icons.done,
                color: mr.status == 'pending' ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mr.type == 'sent'
                      ? 'You requested money from ${mr.name}'
                      : 'You have received a money request from ${mr.name}'),
                  Text(
                    _mrDate(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (mr.status != 'pending')
                    const Text(
                      'Completed !!!',
                      style: TextStyle(color: Colors.green),
                    )
                ],
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${mr.currency} ${mr.amount}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'K ${mr.ktcValue}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
