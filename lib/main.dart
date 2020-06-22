import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:word_puzzle/words_helper.dart';
import 'package:word_puzzle/category_helper.dart';
import 'dart:math';
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




int gridW = 10;
int gridH = 10;
double gridSize = 30.0;
List<List<String>> gridMap = [];
List<String> wordsList = [];
class DetailScreen extends StatelessWidget {
  final String category;
  final List<AWord> words;
  Size panSize;

  DetailScreen({Key key, @required this.category, @required this.words}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeGame(), // function where you call your api
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
                appBar: AppBar(
                  title: Text(category),
                ),
                body: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    color: Colors.white,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: panSize.width,
                          height: panSize.height,
                          color: Colors.yellow,
                          child: CustomPaint(painter: FaceOutlinePainter()),
                        ),
                      ),
                    // Inner yellow container
                    /*child: */
                  ),
              );
        }
      },
    );
  }
  
  Future _initializeGame() async {
    gridMap = List<List<String>>.generate(gridH, (i) => List<String>.generate(gridW, (j) => ""));
    panSize = Size(gridW.toDouble() * gridSize, gridH.toDouble() * gridSize);
    wordsList = List<String>.generate(words.length, (index) => words[index].word);
    wordsList.sort((b, a) => a.length.compareTo(b.length));
    
    var random = new Random();
    if(wordsList.length == 0)
      return;
    
//    int direction = random.nextInt(8);
    var first = generate(5, wordsList[0]);
    Point pt = Point(random.nextInt(gridW),random.nextInt(gridH));
    print(first);

//    print(wordsList);
//    print(panSize);
  }
  List<List<String>> generate(int direction, String aword){
    List<List<String>> grid;
    if(direction == 0){
      grid = List<List<String>>.generate(1, (i) => List<String>.generate(aword.length, (j) => aword[j]));
    }else if(direction == 1){
      grid = List<List<String>>.generate(aword.length, (i) => List<String>.generate(aword.length, (j) => i==j ? aword[i] : ""));
    }else if(direction == 2){
      grid = List<List<String>>.generate(aword.length, (i) => List<String>.generate(1, (j) => aword[i]));      
    }else if(direction == 3){
      grid = List<List<String>>.generate(aword.length, (i) => List<String>.generate(aword.length, (j) => i+j+1 == aword.length ? aword[i] : ""));
    }else if(direction == 4){
      grid = List<List<String>>.generate(1, (i) => List<String>.generate(aword.length, (j) => aword[aword.length - 1 - j]));      
    }else if(direction == 5){
      grid = List<List<String>>.generate(aword.length, (i) => List<String>.generate(aword.length, (j) => i==j ? aword[aword.length - i - 1] : ""));
    }else if(direction == 6){
      grid = List<List<String>>.generate(aword.length, (i) => List<String>.generate(1, (j) => aword[aword.length - i - 1]));      
    }else if(direction == 7){
      grid = List<List<String>>.generate(aword.length, (i) => List<String>.generate(aword.length, (j) => i+j+1 == aword.length ? aword[j] : ""));      
    }
    return grid;
  }
}

class FaceOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define a paint object
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.indigo;
    // Left eye
//    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(20)), paint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    for(int i = 0; i< gridMap.length; i++)
      for(int j = 0; j < gridMap[i].length; j++){
          final textStyle = TextStyle( color: Colors.black, fontSize: 20);
          final textSpan = TextSpan( text: gridMap[i][j], style: textStyle);
          final textPainter = TextPainter( text: textSpan, textDirection: TextDirection.ltr );
          textPainter.layout();
          final offset = Offset(i * gridSize + (gridSize - textPainter.width) / 2, j * gridSize);
          textPainter.paint(canvas, offset);
        }
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => false;
}