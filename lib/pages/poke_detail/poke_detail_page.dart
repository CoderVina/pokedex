import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:pokedex/consts/consts_app.dart';
import 'package:pokedex/models/pokeapi.dart';
import 'package:pokedex/stores/pokeapi_store.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class PokeDetailPage extends StatefulWidget {
  final int index;

  PokeDetailPage({Key key, this.index}) : super(key: key);

  @override
  _PokeDetailPageState createState() => _PokeDetailPageState();
}

class _PokeDetailPageState extends State<PokeDetailPage> {
  PageController _pokemonController;
  PokeApiStore _pokemonStore;
  Pokemon _pokemon;
  MultiTrackTween _animation;

  double _opacity;
  double _opacityTitleBar;
  double _progress;
  double _multiple;

  @override
  void initState() {
    super.initState();
    _pokemonStore = GetIt.instance<PokeApiStore>();
    _pokemon = _pokemonStore.pokemonAtual;
    _pokemonController = PageController(initialPage: widget.index);

    _animation = MultiTrackTween([
      Track("rotation").add(Duration(seconds: 5), Tween(begin: 0.0, end: 6.0),
          curve: Curves.linear)
    ]);

    _opacity = 1.0;
    _opacityTitleBar = 0.0;
    _progress = 0.0;
    _multiple = 1;
  }

  double interval(double lower, double upper, double progress) {
    assert(lower < upper);
    if (progress > upper) return 1.0;
    if (progress < lower) return 0.0;
    return ((progress - lower) / (upper - lower)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Observer(
          builder: (context) {
            return AppBar(
              title: Opacity(
                opacity: _opacityTitleBar,
                child: Text(
                  _pokemon.name,
                  style: ConstsApp.pokemonTitleName,
                ),
              ),
              elevation: 0,
              backgroundColor: _pokemonStore.colorPokemon,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 24,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              actions: <Widget>[
                Stack(
                  alignment: Alignment.centerRight,
                  children: <Widget>[
                    ControlledAnimation(
                      playback: Playback.LOOP,
                      duration: _animation.duration,
                      tween: _animation,
                      builder: (context, animation) {
                        return Transform.rotate(
                          angle: animation["rotation"],
                          child: Hero(
                            child: Opacity(
                              child: Image.asset(
                                ConstsApp.whitePokeball,
                                height: 50,
                                width: 50,
                              ),
                              opacity: _opacityTitleBar >= 0.2? 0.2 : 0.0,
                            ),
                            tag: "fav_icon",
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.favorite_border),
                      color: Colors.white,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      backgroundColor: _pokemonStore.colorPokemon,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Observer(
              builder: (context) {
                return Container(
                  height: MediaQuery.of(context).size.height / 3,
                  color: _pokemonStore.colorPokemon,
                );
              },
            ),
            Container(
              height: MediaQuery.of(context).size.height / 3,
            ),
            SlidingSheet(
              listener: (state){
                setState(() {
                  _progress = state.progress;
                  _multiple  = 1 - interval(0.0, 0.8, _progress);
                  _opacity = _multiple;
                  _opacityTitleBar = _multiple = interval(0.55, 0.8, _progress);
                });
              },
              elevation: 0,
              cornerRadius: 30,
              snapSpec: const SnapSpec(
                snap: true,
                snappings: [0.7, 1.0],
                positioning: SnapPositioning.relativeToAvailableSpace,
              ),
              builder: (context, state) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                );
              },
            ),
            Opacity(
              opacity: _opacity,
              child: Padding(
                padding: EdgeInsets.only(
                  top: _opacityTitleBar == 1? 1000:(60 - _progress *50),
                ),
                child: SizedBox(
                  height: 200,
                  child: PageView.builder(
                      itemCount: _pokemonStore.pokeAPI.pokemon.length,
                      controller: _pokemonController,
                      onPageChanged: (index) {
                        _pokemonStore.setPokemonAtual(index: index);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        Pokemon _pokemon = _pokemonStore.getPokemon(index: index);
                        return Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            ControlledAnimation(
                              playback: Playback.LOOP,
                              duration: _animation.duration,
                              tween: _animation,
                              builder: (context, animation) {
                                return Transform.rotate(
                                  angle: animation["rotation"],
                                  child: Hero(
                                    child: Opacity(
                                      child: Image.asset(
                                        ConstsApp.whitePokeball,
                                        height: 180,
                                        width: 180,
                                      ),
                                      opacity: 0.2,
                                    ),
                                    tag: index.toString(),
                                  ),
                                );
                              },
                            ),
                            Observer(
                              builder: (context) {
                                return AnimatedPadding(
                                  child: CachedNetworkImage(
                                    height: 160,
                                    width: 160,
                                    placeholder: (context, url) => new Container(
                                      color: index == _pokemonStore.positionActual
                                          ? null
                                          : Colors.black.withOpacity(0.2),
                                    ),
                                    imageUrl:
                                        'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${_pokemon.num}.png',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.bounceInOut,
                                  padding: EdgeInsets.all(
                                      index == _pokemonStore.positionActual
                                          ? 0
                                          : 40),
                                );
                              },
                            ),
                          ],
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
