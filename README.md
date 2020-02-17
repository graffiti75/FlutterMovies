# Project Description

As a Flutter engineer you've been tasked with the development of an app for cinephiles and movie hobbyists. This first version (MVP) of the app will be very simple and limited to show the list of upcoming movies. The app will be fed with content from The Movie Database (TMDb). No design specs were given, so you're free to follow your UX and UI personal preferences. The choice of platform is: Flutter.

# Functional Requirements

The first release of the app will be very limited in scope, but will serve as the foundation for future releases. It's expected that user will be able to:

- Scroll through the list of upcoming movies - including movie name, poster or backdrop image, genre and release date. List should not be limit to show only the first 20 movies as returned by the API.
- Select a specific movie to see details (name, poster image, genre, overview and release date).
- Search for movies by entering a partial or full movie name (Optional).

# Technical Requirements

You should see this project as an opportunity to create an app following modern development best practices (given your platform of choice), but also feel free to use your own app architecture preferences (coding standards, code organization, third-party libraries, etc).

A TMDb API key is already available so you don't need to request your own: 53133282dc48b97f36b50a6a54ac8d48 . The API documentation and examples of use can be found here: https://developers.themoviedb.org/3

# Deliverables

The project source code and dependencies should be made available in GitHub. Here are the steps you should follow:

1. Create a public repository on GitHub (create an account if you don't have one)
2. Create a "development" branch and commit the code to it. Do not push the code to the master branch.
3. Create a "screenshots" sub-folder and include at least two screenshots of the app
4. Include a README file that describes:
- Special build instructions, if any
- List of third-party libraries used and short description of why/how they were used
5. Once the work is complete, create a pull request and send us the link.

# Notes

Here at CEABS we're big believers of collective code ownership, so remember that you’re writing code that will be reviewed, tested, maintained by other developers. Things to keep in mind:

- First of all, it should compile and run without errors
- Be as clean and consistent as possible
- Despite the project simplicity, don't ignore development and architecture
best practices. It's expected that code architecture will be structured to support project growth.

This project description is intentionally vague in some aspects, but if you need assistance feel free to ask for help. We wish you good luck!

# List of third-party libraries

Here I include the list of third-party libraries I used, and short description of why/how they were used.

1. http: ^0.12.0+2

This library is used to perform HTTP request from the Web.

More specifically, in this project, in the class `network.dart`:

```
import 'dart:convert';

import 'package:flutter_movies/model/api_response.dart';
import "package:http/http.dart" as http;

class API {
  String url = "http://api.themoviedb.org/3/movie";
  final apiKey = "53133282dc48b97f36b50a6a54ac8d48";

  Future<List<Movie>> getUpcomingMovies(int pageId) async {
    final response = await http.get(Uri.parse("$url/upcoming?api_key=$apiKey&page=$pageId"));

    if (response.statusCode == 200) {
      var apiResponse = ApiResponse.fromJSON(json.decode(response.body));
      return apiResponse.results;
    } else {
      throw Exception('Failed to load data.');
    }
  }
}
```

2. provider: ^3.1.0

This library is used to bind the notifications of the Pagination with the Widget used in `main.dart`. It is a mixture between dependency injection (DI) and state management, built with widgets for widgets.

In this project, this is used in class `main.dart`:

```
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

class _MyHomePageState extends State<MyHomePage> {
  List<Movie> movies;
  List<int> maxMovies = [];

  ...

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
```

3. rxdart: ^0.22.2

This library is also used to manage the notifications of the Pagination of data retrieved from the TMDb API.

More specifically, in this project, in the class `movie_bloc.dart`:

```
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_movies/api/network.dart';
import 'package:flutter_movies/model/api_response.dart';
import 'package:rxdart/rxdart.dart';

class MovieBloc {
  final API api = API();
  int pageNumber = 1;
  double pixels = 0.0;

  ReplaySubject<List<Movie>> _subject = ReplaySubject();
  final ReplaySubject<ScrollNotification> _controller = ReplaySubject();

  Observable<List<Movie>> get stream => _subject.stream;
  Sink<ScrollNotification> get sink => _controller.sink;

  MovieBloc() {
    _subject.addStream(Observable.fromFuture(api.getUpcomingMovies(pageNumber)));
    _controller.listen((notification) => loadMovies(notification));
  }

  Future<void> loadMovies([
    ScrollNotification notification,
  ]) async {
    if (notification.metrics.pixels == notification.metrics.maxScrollExtent &&
        pixels != notification.metrics.pixels) {
      pixels = notification.metrics.pixels;

      pageNumber++;
      List<Movie> list = await api.getUpcomingMovies(pageNumber);
      _subject.sink.add(list);
    }
  }

  void dispose() {
    _controller.close();
    _subject.close();
  }
}
```