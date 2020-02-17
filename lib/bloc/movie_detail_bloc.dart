import 'package:rxdart/rxdart.dart';

class MovieDetailBloc {
  final _movieId = PublishSubject<int>();
  MovieDetailBloc();

  dispose() async {
    _movieId.close();
  }
}