import 'package:snapchat_ui_clone/models/article.dart';

import 'models/friend.dart';

class Data {

  static List<Chat> chatFriends = [
    Chat('Tom', 'Received', '2m', 178),
    Chat('Lily', 'Sent', '7m', 0),
    Chat('Cat', 'Sent', '22m', 134),

  ];

  static List<Chat> challenges = [
    Chat('Tom', 'Received', '2m', 178),
    Chat('Lily', 'Sent', '7m', 0),
    Chat('Cat', 'Sent', '21m', 134),

  ];

  static List<Article> subscriptions = [
    Article('Regina Folk Festival',
        'When? | August 21, 22. Book your tickets now'),
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