import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:word_puzzle/words_helper.dart';
import 'package:word_puzzle/database_helper.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'dart:async';
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
                            builder: (context) => GameWidget(category: categories[index].category, words: allWords[index], bestTime: categories[index].time),
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
    DatabaseHelper helper = DatabaseHelper.instance;
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

List<List<String>> gridMap = [];
double gridSize = 20.0;
List<Point> touchItems = [];

List<List<Point>> foundMap = [];
List<Color> foundColor = [];
List<String> foundWords = [];
class GameWidget extends StatefulWidget {
  final String category;
  final List<AWord> words;
  final String bestTime;
  
  GameWidget({Key key, @required this.category, @required this.words, @required this.bestTime}) : super(key: key);
  @override
  _GameWidgetState createState() => _GameWidgetState();
}
class _GameWidgetState extends State<GameWidget> {
  int gridW;
  int gridH;
  List<String> wordsList = [];
  
  Size panSize;

  double x = 0.0;
  double y = 0.0;
  int timeElapsed = 10;
  
  GlobalKey _keyRed = GlobalKey();
  bool validTouchFlag;


  static const duration = const Duration(seconds: 1);
  int secondsPassed = 0;
  bool isActive = false;
  Timer timer;
  void handleTick() {
//    if(isActive) {
      setState(() {
        secondsPassed = secondsPassed + 1;
      });
//    }
  }
  
  void finishGame(){
    Navigator.of(context).pop();
    showDialog(context: context, child:
        new AlertDialog(
          title: new Text("Congratulations!"),
          content: new Text("Your Score is ${secondsPassed ~/ 60} m ${secondsPassed % 60} s"),
        )
    );
    timer.cancel();
  }

  void _incrementDown(PointerEvent details) {
    _updateLocation(details); 
    setState(() {
      touchItems.clear();
      validTouchFlag = true;
    });
    finishGame();
//    print("down");
  }
  void _incrementUp(PointerEvent details) {
    _updateLocation(details);
    String selectedStr = "";
    touchItems.forEach((element) {
      selectedStr = selectedStr + gridMap[element.y][element.x];
    });
    if(wordsList.contains(selectedStr) && !foundWords.contains(selectedStr)){
      foundMap.add(List<Point>.generate(touchItems.length, (index) => touchItems[index]));
      foundColor.add(Color.fromARGB(100, Random().nextInt(255), Random().nextInt(255), Random().nextInt(255)));
      foundWords.add(selectedStr);

      if(foundWords.length == wordsList.length)
        finishGame();
      print(foundWords);

    }
      touchItems.clear();
//    print("up");
  }
  void _updateLocation(PointerEvent details) {
    if(validTouchFlag == true)
      setState(() {
        x = details.position.dx - _getPositions().dx;
        y = details.position.dy - _getPositions().dy;
        
        int itemX = x ~/ gridSize;
        int itemY = y ~/ gridSize;
        if(!touchItems.contains(Point(itemX, itemY)) && itemX >=0 && itemX < gridW && itemY >=0 && itemY < gridH){
          Offset itemPos = Offset(itemX * gridSize + gridSize / 2, itemY * gridSize + gridSize / 2);
          Offset touchPos = Offset(x, y);
          if((itemPos - touchPos).distance < gridSize / 2.5)
            if(touchItems.length < 2){
              touchItems.add(Point(itemX, itemY));
            }else if(itemX + touchItems[touchItems.length - 2].x == touchItems[touchItems.length - 1].x * 2 && itemY + touchItems[touchItems.length - 2].y == touchItems[touchItems.length - 1].y * 2){
              touchItems.add(Point(itemX, itemY));
            }
        }
      });
  }
  Offset _getPositions() {
    final RenderBox renderBox = _keyRed.currentContext.findRenderObject();
    Offset position = renderBox.localToGlobal(Offset.zero);
    return position;
  }
  @override
  void initState() {
    super.initState();
    foundMap.clear();
    foundColor.clear();
    foundWords.clear();
    touchItems.clear();
    _initializeGame();
  }


  Widget build(BuildContext context) {
    if (timer == null)
    timer = Timer.periodic(duration, (Timer t)
    {
      handleTick();
    });

    

    int seconds = secondsPassed % 60;
    int minutes = secondsPassed ~/ 60;
    print("Updated");
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        color: Colors.white,
        child:Column(
          children: <Widget>[
            Center(
              child:Container(
                alignment: Alignment.topRight,
                child: Row(children: <Widget>[
                  Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  padding: EdgeInsets.all(5),
                  decoration: new BoxDecoration( borderRadius: new BorderRadius.circular(10), color: Colors.cyan[800]),
                  child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Text('Time',
                        style: TextStyle(
                          color: Colors.white,fontSize : 16, fontWeight: FontWeight.bold
                        )),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      decoration: new BoxDecoration( borderRadius: new BorderRadius.circular(10), color: Colors.yellow[700]),
                      child:Text(
                        //'$timeElapsed',
                        "$minutes:$seconds",
                        style: TextStyle(
                            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    ),
                  ])),

                  Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  padding: EdgeInsets.all(5),
                  decoration: new BoxDecoration( borderRadius: new BorderRadius.circular(10), color: Colors.cyan[800]),
                  child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Text('Best Time',
                        style: TextStyle(
                          color: Colors.white,fontSize : 16, fontWeight: FontWeight.bold
                        )),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      decoration: new BoxDecoration( borderRadius: new BorderRadius.circular(10), color: Colors.yellow[700]),
                      child:Text(
                        '${widget.bestTime}',
                        style: TextStyle(
                            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    ),
                  ])),
                ],)
              ),
            ),
            Container(
              child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                child: Listener(
                  onPointerDown: _incrementDown,
                  onPointerMove: _updateLocation,
                  onPointerUp: _incrementUp,
                    child: Container(
                      child:Column (
                        children: <Widget>[
                          Container(
                            width: panSize.width,
                            height: panSize.height,
                            color: Colors.white,
                            child: CustomPaint(painter: CharacterMapPainter(), key: _keyRed),
                          ),
                        ]
                      )
                    )
                  ),
                ),
              ),
            ),
            Container(
              width: 300,
              height: 200,
              child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(20),
                //crossAxisSpacing: 10,
                //mainAxisSpacing: 1 / 10,
                crossAxisCount: 3,
                childAspectRatio: 3,
                children: wordsList.map((data) =>
        
                Container(
                  child: Container(
                    margin:EdgeInsets.symmetric(vertical: 5, horizontal: 5),

                    //color: Colors.green,
                    child: Center(
                        child: Text(data, 
                        style: TextStyle(
                            fontSize: 16, 
                            color: foundWords.contains(data)? foundColor[foundWords.indexOf(data)] : Colors.black,
                          ), 
                        textAlign: TextAlign.center
                      )
                    )
                  )
                )
        
                ).toList(),
              ) 
            ),
          ]
        )
      ),
          // Inner yellow container
          /*child: */
    );
  }
  void _initializeGame() {
    gridSize = 20.0;
    gridH = 15;
    gridW = 15;
    gridMap = List<List<String>>.generate(gridH, (i) => List<String>.generate(gridW, (j) => ""));
    panSize = Size(gridW.toDouble() * gridSize, gridH.toDouble() * gridSize);
    wordsList = List<String>.generate(widget.words.length, (index) => widget.words[index].word);
    wordsList.sort((b, a) => a.length.compareTo(b.length));
    var random = new Random();
    if(wordsList.length == 0)
      return;
    var first = generate(random.nextInt(8), wordsList[0]);
    Point pt = Point(random.nextInt(gridW -first.first.length + 1),random.nextInt(gridH - first.length + 1));
    putOnGrid(first, pt);
    for(int wi = 1; wi < wordsList.length; wi++){
      int dir;
      checkFound:
      for(dir = 0; dir < 8; dir++){ //find if words match exist
        var piece = generate(dir, wordsList[wi]);
        for(int i = 0; i < gridH - piece.length; i++)
          for(int j = 0; j < gridW - piece.first.length; j++){
            int matchCharCount = 0, dismatchCharCount = 0;
            for(int ii = 0; ii < piece.length; ii++)
              for(int jj = 0; jj < piece.first.length; jj++)
                if(piece[ii][jj] == gridMap[i+ii][j+jj] && piece[ii][jj] != "")
                  matchCharCount ++;
                else if(piece[ii][jj] != gridMap[i+ii][j+jj] && gridMap[i+ii][j+jj] != "")
                  dismatchCharCount ++;
            if(matchCharCount > 0 && dismatchCharCount == 0){
              putOnGrid(piece, Point(j,i));
              break checkFound;
            }
          }
      }
      if(dir == 8){
        putAsAnother:
        while(true){
          var piece = generate(random.nextInt(8), wordsList[wi]);
          int i = random.nextInt(gridH - piece.length);
          int j = random.nextInt(gridW - piece.first.length);
          int matchCharCount = 0;
          for(int ii = 0; ii < piece.length; ii++)
            for(int jj = 0; jj < piece.first.length; jj++)
              if(gridMap[i+ii][j+jj] != "")
                matchCharCount ++;
          if(matchCharCount == 0){
            putOnGrid(piece, Point(j,i));
            break putAsAnother;
          }
        }
      }
    }
  }
  void putOnGrid(List<List<String>> piece, Point pt){
    for(int i = 0; i < piece.length; i++)
      for(int j = 0; j < piece[i].length; j++)
        gridMap[pt.y + i][pt.x + j] = piece[i][j];
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

class CharacterMapPainter extends CustomPainter {
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
          final offset = Offset(j * gridSize + (gridSize - textPainter.width) / 2, i * gridSize + (gridSize - textPainter.height) / 2);
          textPainter.paint(canvas, offset);
        }
    //----- Found Words history
    List<Offset> offset = [];
    Path path = Path();
    paint.strokeWidth = gridSize;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;
    for(int i = 0; i < foundWords.length; i++){
      offset.clear();
      path.reset();
      paint.color = foundColor[i];

      //print(paint.color);
      for(int j = 0; j < foundMap[i].length ; j++)
        offset.add(Offset(foundMap[i][j].x * gridSize + gridSize / 2,foundMap[i][j].y * gridSize + gridSize / 2));
      path.addPolygon(offset, false);
      canvas.drawPath(path, paint);
    }
    //print(foundMap);

    //----- Current drawing
    List<Offset> offsets = [];
    for(int i = 0; i < touchItems.length ; i++)
      offsets.add(Offset(touchItems[i].x * gridSize + gridSize / 2,touchItems[i].y * gridSize + gridSize / 2));
    path.reset();
    path.addPolygon(offsets, false);
    paint.color = Color.fromRGBO(255, 0, 0, 80);
    canvas.drawPath(path, paint);
//    for(int i = 1; i < touchItems.length ; i++)
//      canvas.drawLine(Offset(touchItems[i-1].x * gridSize + gridSize / 2,touchItems[i-1].y * gridSize + gridSize / 2), Offset(touchItems[i].x * gridSize + gridSize / 2,touchItems[i].y * gridSize + gridSize / 2), paint);

//    for(int i = 1; i< touchPoints.length; i++)
//      canvas.drawLine(touchPoints[i-1], touchPoints[i], paint);
    //print(gridMap);
  }

  @override
  bool shouldRepaint(CharacterMapPainter oldDelegate) => true;
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}