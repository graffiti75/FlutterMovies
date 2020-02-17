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