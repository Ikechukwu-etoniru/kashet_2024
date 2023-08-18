class CountryModel {
  final int id;
  final String name;
  final String countryISO;
  final List<States> states;

  CountryModel(
      {required this.id,
      required this.name,
      required this.countryISO,
      required this.states});
}

class States {
  final int id;
  final int stateId;
  final String name;

  States({required this.id, required this.name, required this.stateId});
}
