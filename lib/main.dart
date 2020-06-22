import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:word_puzzle/words_helper.dart';
import 'package:word_puzzle/category_helper.dart';
class Todo {
  final String title;
  final String description;
  Todo(this.title, this.description);
}

void main() {

  runApp(MaterialApp(
    title: 'Word Puzzle',
    home: TodosScreen(),
  ));
}

class TodosScreen extends StatelessWidget {
  List<ACategory> categories;
  List<List<AWord>> allWords = [];
  
  TodosScreen({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeDatabase(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot snapshot) {  // AsyncSnapshot<Your object type>
        if( snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(
            body:Center(child: CircularProgressIndicator()), 
          );
        }else{
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else
              return Scaffold(
/*                appBar: AppBar(
                  title: Text('Word Puzzle'),
                ),*/
                body: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(categories[index].category),
                      subtitle: Text(categories[index].time),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(category: categories[index].category, words: allWords[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
        }
      },
    );
  }

  Future _initializeDatabase() async {
    CategoryHelper helper = CategoryHelper.instance;
    await helper.initializeDatabase();
    int ccount = await helper.getCategoryCount();
    int wcount = await helper.getAllWordsCount();
    categories = await helper.getAllCategories();
    
    for(int i = 0; i< categories.length; i++){
      allWords.add(await helper.getWords(categories[i].category));
    }
    print("Database Loaded..  CCount : [$ccount]  WCount[$wcount]"); 
  }
}

class DetailScreen extends StatelessWidget {
  final String category;
  final List<AWord> words;

  DetailScreen({Key key, @required this.category, @required this.words}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(words.length.toString()),
      ),
      
    );
  }
}
