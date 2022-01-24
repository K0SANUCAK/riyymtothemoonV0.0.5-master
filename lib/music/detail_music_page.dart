import 'package:flutter/material.dart';
import 'package:riyym/dataBase/authentication.dart';
import 'package:riyym/dataBase/firestoredata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'music_api.dart';
import 'music_home.dart';

class DetailMusicPage extends StatefulWidget {
  final Musics music;

  // ignore: use_key_in_widget_constructors
  const DetailMusicPage(this.music);
  @override
  _DetailMusicPageState createState() => _DetailMusicPageState();
}

class _DetailMusicPageState extends State<DetailMusicPage> {
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
    final List<String> favorites = (prefs.getStringList('favoritesM') ?? []);
    favs = prefs.getStringList('favoritesM') ?? [];
    if (!favorites.contains(name)) {
      favorites.add(name);
      favs.add(name);
    } else {
      favorites.remove(name);
      favs.remove(name);
    }

    setState(() {
      _favorites =
          prefs.setStringList('favoritesM', favorites).then((bool success) {
        return favorites;
      });
    });
  }

  late final Music msc;
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
                            FavoritesM(favorites: _favorites)));
              },
              child: const Text(
                "Go To Favorites",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
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
                  widget.music.poster,
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
                      widget.music.title,
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
                        Column(children: <Widget>[
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                NetworkImage(widget.music.singerUrl),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          Text(
                            widget.music.singer,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          )
                        ]),
                        const Expanded(child: Text("")),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.people,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                Text(
                                  "${widget.music.rank}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                Text(
                                  (Duration(seconds: widget.music.duration)
                                              .inMinutes +
                                          (((widget.music.duration) -
                                                  Duration(
                                                              seconds: widget
                                                                  .music
                                                                  .duration)
                                                          .inMinutes *
                                                      60) *
                                              0.01))
                                      .toStringAsFixed(2),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: () async {
                              await launch(
                                  "https://www.youtube.com/results?search_query=${widget.music.singer} ${widget.music.title}",
                                  forceSafariVC: false);
                            },
                            icon: const Icon(
                              Icons.play_circle_outline_sharp,
                              size: 30,
                              color: Colors.blue,
                            )),
                        Padding(
                          padding: const EdgeInsets.only(right: 9.0),
                          child: GestureDetector(
                            child: favs.contains(widget.music.title +
                                    "-riyym-" +
                                    widget.music.poster)
                                ? const Icon(Icons.favorite, color: Colors.red)
                                : const Icon(Icons.favorite,
                                    color: Colors.grey),
                            onTap: () {
                              _addToFavorites(widget.music.title +
                                  "-riyym-" +
                                  widget.music.poster);
                              if (!favs.contains(widget.music.title +
                                  "-riyym-" +
                                  widget.music.poster)) {
                                FireStore().addMusicFav(
                                    widget.music, Authentication().userUID);
                              }
                              if (widget.music.isFavorite) {
                                widget.music.isFavorite = false;
                                if (mounted) {
                                  setState(() {});
                                }
                              } else {
                                widget.music.isFavorite = true;

                                if (mounted) {
                                  setState(() {});
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class FavoritesM extends StatefulWidget {
  Future<List<String>> favorites;
  FavoritesM({Key? key, required this.favorites}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<FavoritesM> {
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
