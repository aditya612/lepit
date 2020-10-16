import 'package:random_words/random_words.dart';
import 'package:three_words/three_words.dart';

class RandomWordPair {
  get words => Words()
      .randomWords(number: 2)
      .map((str) => str[0].toUpperCase() + str.substring(1))
      .join();

  Iterable<WordPair> wordPair = generateWordPairs();
}
