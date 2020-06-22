import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


// database table and column names
final String tableWords = 'words';
final String columnCategory = 'category';
final String columnWord = 'word';

// data model class
class AWord {
  String category;
  String word;
  AWord(String c, String w){
    category = c;
    word = w;
  }
  AWord.empty() : this("", "");

  AWord.fromMap(Map<String, dynamic> map) {
    category = map[columnCategory];
    word = map[columnWord];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnCategory: category,
      columnWord: word
    };
    return map;
  }
}

// singleton class to manage the database
class WordsHelper {
  static final _databaseName = "Word-Puzzle.db";
  static final _databaseVersion = 1;
  WordsHelper._privateConstructor();
  static final WordsHelper instance = WordsHelper._privateConstructor();
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }
  _initDatabase() async {
/*    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);*/
  }

  // SQL string to create the database 
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableWords (
            $columnCategory TEXT PRIMARY KEY,
            $columnWord TEXT
          )
          ''');
  }

  // Database helper methods:

  Future<int> initializeDatabase() async {
    Database db = await database;
    /*List<String> words_face = ['hair','skin','eyebrow','eyelash','ear','nose','mole','lip','chin','forehead','temple','eye','cheek','nostril','mouth'];
    List<String> words_fruits = ['orange','lime','lemon','apricot','watermelon','grapes','raspberry','blackberry','strawberry','grapefruit','peach','plum','mango','banana','papaya'];
    List<String> words_vegetables = ['corn','green bean','lettuce','cucumber','zucchini','pumpkin','pepper','carrot','asparagus','potato','onion','artichoke','radish','broccoli','celery'];
    List<String> words_colors = ['red','blue','green','yellow','orange','purple','teal','pink','gray','white','black','brown'];
    List<String> words_occupations = ['lawyer','accountant','scientist','teacher','pilot','doctor','actress','dancer','musician','photographer','painter','librarian','receptionist','travel agent','journalist'];
    List<String> words_musical = ['piano','saxophone','guitar','violin','viola','harp','cello','french horn','tuba','drum','trumpet','keyboard','mandolin','bass','flute'];
    List<String> words_flowers = ['lily','flowers','carnation','tulip','orchid','gladiolus','daisy','acacia','chrysanthemum','iris','rose','freesia','gerbera'];
    List<String> words_bar = ['martini','cocktail','wine','beer','gin','whiskey','scotch','rum'];
    List<String> words_bathroom = ['sink','bathtub','shower','shower head','toilet','toilet brush','drain','sponge','deoderant','mouthwash','toothpaste','toothbrush','aftershave','soap','bubble bath'];
    List<String> words_house = ['window','front door','chimney','roof','sidewalk','gutter','dormer window','shutter','porch','shingle','balcony','foyer','doorbell','hand rail','staircase'];
    List<String> words_makeup = ['hair dye','eyeshadow','mascara','eyeliner','blusher','foundation','lipstick','lip gloss','face powder','tweezers','mirror','concealer','brush','lip liner'];
    List<String> words_family = ['grandmother','grandfather','mother','father','uncle','aunt','brother','sister','son','daughter','cousin','grandson','granddaughter','niece','nephew'];
    for(int i = 0; i< words_face.length; await db.insert(tableWords, AWord('Face', words_face[i]).toMap()), i++); 
    for(int i = 0; i< words_fruits.length; await db.insert(tableWords, AWord('Fruits', words_fruits[i]).toMap()), i++); 
    for(int i = 0; i< words_vegetables.length; await db.insert(tableWords, AWord('Vegetables', words_vegetables[i]).toMap()), i++); 
    for(int i = 0; i< words_colors.length; await db.insert(tableWords, AWord('Colors', words_colors[i]).toMap()), i++); 
    for(int i = 0; i< words_occupations.length; await db.insert(tableWords, AWord('Occupations', words_occupations[i]).toMap()), i++); 
    for(int i = 0; i< words_musical.length; await db.insert(tableWords, AWord('Musical Instruments', words_musical[i]).toMap()), i++); 
    for(int i = 0; i< words_flowers.length; await db.insert(tableWords, AWord('Flowers', words_flowers[i]).toMap()), i++); 
    for(int i = 0; i< words_bar.length; await db.insert(tableWords, AWord('Bar', words_bar[i]).toMap()), i++); 
    for(int i = 0; i< words_bathroom.length; await db.insert(tableWords, AWord('Bathroom', words_bathroom[i]).toMap()), i++); 
    for(int i = 0; i< words_house.length; await db.insert(tableWords, AWord('House', words_house[i]).toMap()), i++); 
    for(int i = 0; i< words_makeup.length; await db.insert(tableWords, AWord('Makeup', words_makeup[i]).toMap()), i++); 
    for(int i = 0; i< words_family.length; await db.insert(tableWords, AWord('Family', words_family[i]).toMap()), i++); */
    return 1;
  }

  Future<int> insert(AWord word) async {
    Database db = await database;
    int id = await db.insert(tableWords, word.toMap());
    return id;
  }

  Future<AWord> queryCategory(String category, String word) async {
    Database db = await database;
    List<Map> maps = await db.query(tableWords,
        columns: [columnCategory, columnWord],
        where: '$columnCategory = ? and $columnWord = ?',            
        whereArgs: [category, word]);
    if (maps.length > 0) {
      return AWord.fromMap(maps.first);
    }
    return null;
  }

  Future<List<String>> getAllCategories() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('$tableWords');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return AWord(maps[i]['category'], maps[i]['word']).word;
    });
  }


  Future<int> getAllWordsCount() async {
    //database connection
    Database db = await this.database;
    var qCnt = await db.rawQuery('SELECT COUNT (*) from $tableWords');
    int count = Sqflite.firstIntValue(qCnt);
    return count;
  }
  Future<int> getCount(String pCategory) async {
    //database connection
    Database db = await this.database;
    var qCnt = await db.rawQuery('SELECT COUNT (*) from $tableWords where category = $pCategory');
    int count = Sqflite.firstIntValue(qCnt);
    return count;
  }
  Future<int> delete(String c, String w) async {
    final db = await this.database;
    var result = await db.delete(tableWords, where: 'category = ? and word = ?', whereArgs: [c, w]);
    return result;
  }
  // TODO: queryAllWords()
  // TODO: delete(int id)
  // TODO: update(Word word)
}