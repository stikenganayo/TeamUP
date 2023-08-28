import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends'),
      ),
      body: const SearchContent(),
    );
  }
}

class SearchContent extends StatefulWidget {
  const SearchContent({Key? key}) : super(key: key);

  @override
  _SearchContentState createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  final TextEditingController _searchController = TextEditingController();
  List<String> placeholderUsers = ['Hassan', 'Curtis', 'Tsuyog']; // Placeholder usernames

  List<String> searchResults = [];

  void _searchUsers(String query) {
    setState(() {
      searchResults = placeholderUsers
          .where((user) => user.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addUser(String user) {
    // Add your logic to add the user to the list or perform any other action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$user added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _searchUsers,
            decoration: const InputDecoration(
              labelText: 'Search for usernames',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(searchResults[index]),
                trailing: ElevatedButton(
                  onPressed: () => _addUser(searchResults[index]),
                  child: const Text('Add'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
