class Friend {
  Friend(this.image, this.name, this.status, this.time, this.streak);

  final String image;
  final String name;
  final int status; // 0 = new image, 1 = new video, 2 = new message,
  // 3 = received image, 4 = received video, 5 = received message,
  // 6 = sent unopened image, 7 = sent unopened video, 8 = sent unopened message
  // 9 = sent opened image, 10 = sent opened video, 11 = sent opened message
  // 12 = call ended, 13 = call started, 14 = call missed
  final String time;
  final int streak;
}