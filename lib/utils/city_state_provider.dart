import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CityStateProvider {
  static final CityStateProvider _instance = CityStateProvider._internal();
  List<IndianState> _states = [];

  factory CityStateProvider() {
    return _instance;
  }

  CityStateProvider._internal() {
    _loadStates();
  }

  Future<void> _loadStates() async {
    final jsonString = await rootBundle.loadString('assets/states_cities.json');

    final List<dynamic> jsonList = json.decode(jsonString);

    _states = jsonList.map<IndianState>((json) => IndianState.fromJson(json)).toList();
  }

  List<IndianState> get states {
    if(_instance._states.isEmpty) {
      throw Exception('States not loaded');
    }
    return _instance._states;
  }
}

class IndianState {
  int stateid;
  String statename;
  List<IndianCity> cities;

  IndianState({required this.stateid, required this.statename, required this.cities});

  factory IndianState.fromJson(Map<String, dynamic> json) {
    var list = json['cities'] as List;
    List<IndianCity> citiesList = list.map((i) => IndianCity.fromJson(i)).toList();

    return IndianState(
      stateid: json['stateid'],
      statename: json['statename'],
      cities: citiesList,
    );
  }
}

class IndianCity {
  int cityid;
  String cityname;

  IndianCity({required this.cityid, required this.cityname});

  factory IndianCity.fromJson(Map<String, dynamic> json) {
    return IndianCity(
      cityid: json['cityid'],
      cityname: json['cityname'],
    );
  }
}
