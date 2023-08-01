import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/discover_view.dart';
import '../data.dart';

class DiscoverGrid extends StatelessWidget {
  const DiscoverGrid ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return GridView.count(
      padding: const EdgeInsets.all(10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.8,
      children: List.generate(Data.discovers.length, (index) => DiscoverView(
          index: index,
          title: Data.discovers[index].name,
          description: Data.discovers[index].description)));
  }
}