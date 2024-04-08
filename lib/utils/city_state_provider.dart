import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:user_app/models/indian_state.dart';

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




