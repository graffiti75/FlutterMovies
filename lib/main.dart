import 'package:flutter/material.dart';
import 'package:flutter_movies/ui/movie_detail.dart';
import 'package:provider/provider.dart';

import 'bloc/movie_bloc.dart';
import 'bloc/movie_detail_bloc_provider.dart';
import 'model/api_response.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<MovieBloc>(
      // ignore: deprecated_member_use
      builder: (context) => MovieBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      child: MaterialApp(
        title: 'CEABS Code Challenge',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Movie> movies;
  List<int> maxMovies = [];

  @override
  void initState() {
    super.initState();

    maxMovies.addAll(List.generate(5000, (x) => x));
    movies = [];
  }

  bool onNotification(ScrollNotification scrollInfo, MovieBloc bloc) {
    print(scrollInfo);
    if (scrollInfo is OverscrollNotification) {
      bloc.sink.add(scrollInfo);
    }
    return false;
  }

  Widget buildListView(
      BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
    if (!snapshot.hasData) {
      return Center(child: CircularProgressIndicator());
    }
    movies.addAll(snapshot.data);

    return GridView.builder(
        itemCount: (maxMovies.length > movies.length)
            ? movies.length + 1
            : movies.length,
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) => (index == movies.length)
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : GridTile(
                child: InkResponse(
                  enableFeedback: true,
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w185${movies[index].posterPath}',
                    fit: BoxFit.cover,
                  ),
                  onTap: () => openDetailPage(movies[index], index),
                ),
              ));
  }

  openDetailPage(Movie data, int index) {
    final movie = data;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return MovieDetailBlocProvider(
          child: MovieDetail(
            title: movie.title,
            posterUrl: movie.backdropPath,
            description: movie.overview,
            releaseDate: movie.releaseDate,
            voteAverage: movie.voteAverage.toString(),
            movieId: movie.id,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MovieBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("CEABS Code Challenge"),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) => onNotification(notification, bloc),
        child: StreamBuilder<List<Movie>>(
          stream: bloc.stream,
          builder: (context, AsyncSnapshot<List<Movie>> snapshot) {
            return buildListView(context, snapshot);
          },
        ),
      ),
    );
  }
}