import 'package:snapchat_ui_clone/models/article.dart';

import 'models/friend.dart';

class Data {
  static List<Friend> friends = [
    Friend('assets/images/bitmojis/2.png', 'Tom', 0, '2m', 178),
    Friend('assets/images/bitmojis/3.png', 'Lily', 1, '7m', 0),
    Friend('assets/images/bitmojis/4.png', 'Cat', 1, '21m', 134),
    Friend('assets/images/bitmojis/5.png', 'Tasha', 9, '1h', 0),
    Friend('assets/images/bitmojis/6.png', 'Paige', 4, '1h', 0),
    Friend('assets/images/bitmojis/1.png', 'Bill', 4, '1h', 95),
    Friend('assets/images/bitmojis/2.png', 'Mac', 12, '1h', 0),
    Friend('assets/images/bitmojis/4.png', 'Taylor', 3, '2h', 83),
    Friend('assets/images/bitmojis/5.png', 'Cassidy', 3, '5h', 0),
    Friend('assets/images/bitmojis/6.png', 'Millie', 14, '6h', 0),
    Friend('assets/images/bitmojis/2.png', 'Nick', 0, '2m', 178),
    Friend('assets/images/bitmojis/3.png', 'Addie', 1, '7m', 0),
    Friend('assets/images/bitmojis/4.png', 'Katy', 1, '21m', 134),
    Friend('assets/images/bitmojis/5.png', 'Julia', 9, '1h', 0),
  ];

  static List<Article> subscriptions = [
    Article('The Washington Post',
        'Opinion | What\'s up with Amnesty International and its moral myopia on Ukraine?'),
    Article(
      'The Telegraph',
      'Teens might have to study maths and English after GCSE.',
    ),
    Article(
      'LAD BIBLE',
      'Fans Angry With Kim K Over Sus Body Scan 👀',
    ),
    Article(
      'staytuned',
      'A virtual Sunday service',
    ),
    Article(
      'WORLD STAR',
      'Kanye West Trolls "Skete" After Break Up With Kim!',
    ),
  ];

  static List<Article> discovers = [
    Article(
      'EUROPE ON AMERICA',
      'European Girls Think American Boys Are...',
    ),
    Article(
      'cbcnews',
      'The boat started taking on water when it jumped in',
    ),
    Article(
      'INSIDER',
      'Frank Ocean has released a \$25,000...',
    ),
    Article(
      'Refresh',
      'Dana White tells us the real reason why Jake pulled out!',
    ),
    Article(
      'WSJ',
      'Data Show Gender Pay Gap Opens Early',
    ),
    Article(
      'WORLDNEWS',
      'China Could Crush Russia, End War In Ukraine',
    ),
    Article(
      'TMZ',
      'FDA Checks On TikTok Viral Pink Sauce',
    ),
    Article(
      'NEWS INSIDER',
      'How Illegal Items Are Destroyed At Airports',
    ),
    Article(
      'ANSWERS',
      '"Birds Aren\'t Real"',
    ),
    Article(
      'U N S E E N',
      '911 Hangs Up On Girl Missing for 10 Years!',
    ),
  ];
}
