import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:pokedex/consts/consts_api.dart';
import 'package:pokedex/consts/consts_app.dart';
import 'package:pokedex/models/pokeapi.dart';
import 'package:http/http.dart' as http;

part 'pokeapi_store.g.dart';

class PokeApiStore = _PokeApiStoreBase with _$PokeApiStore;

abstract class _PokeApiStoreBase with Store {
  @observable
  PokeAPI _pokeAPI;
  @observable
  Color colorPokemon;

  @observable
  Pokemon _pokemonAtual;
  @observable
  int positionActual;

  @computed
  PokeAPI get pokeAPI => _pokeAPI;

  @computed
  Pokemon get pokemonAtual => _pokemonAtual;

  @action
  fetchPokemonList() {
    _pokeAPI = null;
    loadPokeAPI().then((pokeList) {
      _pokeAPI = pokeList;
    });
  }

  Pokemon getPokemon({int index}) {
    return _pokeAPI.pokemon[index];
  }

  @action
  setPokemonAtual({int index}) {
    _pokemonAtual = _pokeAPI.pokemon[index];
    colorPokemon = ConstsAPI.getColorType(type: _pokemonAtual.type[0]);
    positionActual = index;
  }

  @action
  Widget getImage({String number}) {
    return CachedNetworkImage(
      placeholder: (context, url) => new Container(
        color: Colors.transparent,
      ),
      imageUrl:
          'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/$number.png',
    );
  }

  Future<PokeAPI> loadPokeAPI() async {
    try {
      final response = await http.get(ConstsAPI.pokeapiURL);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        var decodeJson = jsonDecode(response.body);
        return PokeAPI.fromJson(decodeJson);
      } else {
        // If the server did not return a 200 OK response, then throw an exception.
        throw Exception('Failed to load album');
      }
    } catch (error, stacktrace) {
      print("Error get list" + stacktrace.toString());
      return null;
    }
  }
}
