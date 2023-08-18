class DstvPlan {
  final int id;
  final String name;
  final String amount;

  DstvPlan({required this.id, required this.amount, required this.name});
}

class GotvPlan {
  final int id;
  final String name;
  final String amount;

  GotvPlan({required this.id, required this.amount, required this.name});
}

class StimePlan {
  final int id;
  final String name;
  final String amount;

  StimePlan({required this.id, required this.amount, required this.name});
}

class ElectricPlan {
  final int id;
  final String name;

  ElectricPlan({required this.id, required this.name});
}

class BillingPlan {
  final int id;
  final String name;
  final String amount;
  final String genName;
  final String billType;

  BillingPlan(
      {required this.id,
      required this.name,
      required this.amount,
      required this.genName,
      required this.billType});
}
