import 'package:flutter/material.dart';
import 'package:riyym/dataBase/authentication.dart';
import 'package:riyym/dataBase/firestoredata.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'movie_api.dart';

import 'package:url_launcher/url_launcher.dart';

class DetailMoviePage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  Movies movie;
  DetailMoviePage(this.movie, {Key? key}) : super(key: key);
  @override
  _DetailMoviePageState createState() => _DetailMoviePageState();
}

class _DetailMoviePageState extends State<DetailMoviePage> {
  //DatabaseController databaseController = DatabaseController();
  void customLaunch(command) async {
    await launch(command, forceSafariVC: false);
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<List<String>> _favorites;
  late List<String> favs = [];

  @override
  void initState() {
    super.initState();
    _addToFavorites("");
    _addToFavorites("");
  }

  Future<void> _addToFavorites(String name) async {
    final SharedPreferences prefs = await _prefs;
    final List<String> favorites = (prefs.getStringList('favorites') ?? []);
    favs = prefs.getStringList('favorites') ?? [];
    if (!favorites.contains(name)) {
      favorites.add(name);
      favs.add(name);
    } else {
      favorites.remove(name);
      favs.remove(name);
    }

    setState(() {
      _favorites =
          prefs.setStringList('favorites', favorites).then((bool success) {
        return favorites;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Favorites(favorites: _favorites)));
              },
              child: const Text(
                "Go To Favorites",
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
              )),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black87,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 500,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  widget.movie.poster,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black87,
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: GestureDetector(
                            child: favs.contains(widget.movie.title +
                                    "-riyym-" +
                                    widget.movie.poster)
                                ? const Icon(Icons.favorite, color: Colors.red)
                                : const Icon(Icons.favorite,
                                    color: Colors.grey),
                            onTap: () {
                              _addToFavorites(widget.movie.title +
                                  "-riyym-" +
                                  widget.movie.poster);
                              if (!favs.contains(widget.movie.title +
                                  "-riyym-" +
                                  widget.movie.poster)) {
                                FireStore().addMovieFav(
                                    widget.movie, Authentication().userUID);
                              }
                              if (widget.movie.isFavorite) {
                                widget.movie.isFavorite = false;
                                if (mounted) {
                                  setState(() {});
                                }
                              } else {
                                widget.movie.isFavorite = true;

                                if (mounted) {
                                  setState(() {});
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.movie.vote_average.toString(),
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: 5),
                        ...List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            color: (index <
                                    (widget.movie.vote_average / 2).floor())
                                ? Colors.yellow
                                : Colors.white30,
                          ),
                        ),
                        FutureBuilder<List<Youtube>>(
                            future: fetchYoutube(widget.movie.imdbId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return IconButton(
                                  onPressed: () {
                                    customLaunch(
                                        "https://www.youtube.com/results?search_query=${widget.movie.title} trailer");
                                  },
                                  icon: const Icon(Icons.play_circle_outlined),
                                  iconSize: 40,
                                  color: Colors.blue,
                                );
                              } else if (snapshot.hasData) {
                                String link = "https://youtube.com/watch?v=" +
                                    snapshot.data![0].key;
                                return IconButton(
                                  onPressed: () {
                                    customLaunch(link);
                                  },
                                  icon: const Icon(Icons.play_circle_outlined),
                                  iconSize: 40,
                                  color: Colors.blue,
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              "Overview",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
            child: Text(
              widget.movie.overview,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class Favorites extends StatefulWidget {
  Future<List<String>> favorites;
  Favorites({Key? key, required this.favorites}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Center(
          child: FutureBuilder<List<String>>(
              future: widget.favorites,
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return list(snapshot.data!);
                    }
                }
              })),
    );
  }
}

Widget list(List<String> ls) {
  return ListView.builder(
    itemCount: ls.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListTile(
          title: Text(ls[index].split("-riyym-").first),
          leading: Image.network(ls[index].split("-riyym-")[1]),
        ),
      );
    },
  );
}
