import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


// database table and column names
final String tableCategories = 'categories';
final String tableWords = 'words';

final String columnCategory = 'category';
final String columnTime = 'time';
final String columnWord = 'word';

bool isInitialized = false;

// data model class
class ACategory {
  String category;
  String time;
  ACategory(String c){
    category = c;
    time = "0.0s";
  }
  ACategory.withTime(this.category, this.time){
    this.category = category;
    this.time = time;
  }
  ACategory.empty() : this("");

  ACategory.fromMap(Map<String, dynamic> map) {
    category = map[columnCategory];
    time = map[columnTime];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnCategory: category,
      columnTime: time
    };
    return map;
  }
}
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
class CategoryHelper {
  static final _databaseName = "Word-Puzzle.db";
  static final _databaseVersion = 1;
  CategoryHelper._privateConstructor();
  static final CategoryHelper instance = CategoryHelper._privateConstructor();
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL string to create the database 
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableCategories (
            $columnCategory TEXT PRIMARY KEY,
            $columnTime TEXT DEFAULT '0.0s'
          )
          ''');
    await db.execute('''
          CREATE TABLE $tableWords (
            $columnCategory TEXT NOT NULL,
            $columnWord TEXT NOT NULL
          )
          ''');
  }

  // Database helper methods:

  Future<int> initializeDatabase() async {
    if(isInitialized == true)
      return 0;
    Database db = await database;
    await db.rawQuery('delete from $tableCategories');
    await db.rawQuery('delete from $tableWords');
    List<String> cats = ['Face','Fruits','Vegetables','Colors','Occupations','Musical Instruments','Flowers','Bar','Bathroom','House','Makeup','Family'];
    List<String> wface = ['hair','skin','eyebrow','eyelash','ear','nose','mole','lip','chin','forehead','temple','eye','cheek','nostril','mouth'];
    List<String> wfruits = ['orange','lime','lemon','apricot','watermelon','grapes','raspberry','blackberry','strawberry','grapefruit','peach','plum','mango','banana','papaya'];
    List<String> wvegetables = ['corn','green bean','lettuce','cucumber','zucchini','pumpkin','pepper','carrot','asparagus','potato','onion','artichoke','radish','broccoli','celery'];
    List<String> wcolors = ['red','blue','green','yellow','orange','purple','teal','pink','gray','white','black','brown'];
    List<String> woccupations = ['lawyer','accountant','scientist','teacher','pilot','doctor','actress','dancer','musician','photographer','painter','librarian','receptionist','travel agent','journalist'];
    List<String> wmusical = ['piano','saxophone','guitar','violin','viola','harp','cello','french horn','tuba','drum','trumpet','keyboard','mandolin','bass','flute'];
    List<String> wflowers = ['lily','flowers','carnation','tulip','orchid','gladiolus','daisy','acacia','chrysanthemum','iris','rose','freesia','gerbera'];
    List<String> wbar = ['martini','cocktail','wine','beer','gin','whiskey','scotch','rum'];
    List<String> wbathroom = ['sink','bathtub','shower','shower head','toilet','toilet brush','drain','sponge','deoderant','mouthwash','toothpaste','toothbrush','aftershave','soap','bubble bath'];
    List<String> whouse = ['window','front door','chimney','roof','sidewalk','gutter','dormer window','shutter','porch','shingle','balcony','foyer','doorbell','hand rail','staircase'];
    List<String> wmakeup = ['hair dye','eyeshadow','mascara','eyeliner','blusher','foundation','lipstick','lip gloss','face powder','tweezers','mirror','concealer','brush','lip liner'];
    List<String> wfamily = ['grandmother','grandfather','mother','father','uncle','aunt','brother','sister','son','daughter','cousin','grandson','granddaughter','niece','nephew'];
    for(int i = 0; i < cats.length; i++)  await db.insert(tableCategories, ACategory(cats[i]).toMap());
    for(int i = 0; i< wface.length; await db.insert(tableWords, AWord('Face', wface[i]).toMap()), i++); 
    for(int i = 0; i< wfruits.length; await db.insert(tableWords, AWord('Fruits', wfruits[i]).toMap()), i++); 
    for(int i = 0; i< wvegetables.length; await db.insert(tableWords, AWord('Vegetables', wvegetables[i]).toMap()), i++); 
    for(int i = 0; i< wcolors.length; await db.insert(tableWords, AWord('Colors', wcolors[i]).toMap()), i++); 
    for(int i = 0; i< woccupations.length; await db.insert(tableWords, AWord('Occupations', woccupations[i]).toMap()), i++); 
    for(int i = 0; i< wmusical.length; await db.insert(tableWords, AWord('Musical Instruments', wmusical[i]).toMap()), i++); 
    for(int i = 0; i< wflowers.length; await db.insert(tableWords, AWord('Flowers', wflowers[i]).toMap()), i++); 
    for(int i = 0; i< wbar.length; await db.insert(tableWords, AWord('Bar', wbar[i]).toMap()), i++); 
    for(int i = 0; i< wbathroom.length; await db.insert(tableWords, AWord('Bathroom', wbathroom[i]).toMap()), i++); 
    for(int i = 0; i< whouse.length; await db.insert(tableWords, AWord('House', whouse[i]).toMap()), i++); 
    for(int i = 0; i< wmakeup.length; await db.insert(tableWords, AWord('Makeup', wmakeup[i]).toMap()), i++); 
    for(int i = 0; i< wfamily.length; await db.insert(tableWords, AWord('Family', wfamily[i]).toMap()), i++);
    isInitialized = true;
    return 1;
  }
  Future<void> dropTables() async{
    Database db = await database;
    await db.rawQuery('drop table $tableCategories');
    await db.rawQuery('drop table $tableWords');
  }

  Future<int> insert(ACategory word) async {
    Database db = await database;
    int id = await db.insert(tableCategories, word.toMap());
    return id;
  }

  Future<ACategory> queryCategory(String category, String time) async {
    Database db = await database;
    List<Map> maps = await db.query(tableCategories,
        columns: [columnCategory, columnTime],
        where: '$columnCategory = ? and $columnTime = ?',            
        whereArgs: [category, time]);
    if (maps.length > 0) {
      return ACategory.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ACategory>> getAllCategories() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('$tableCategories');
    return List.generate(maps.length, (i) {
      return ACategory.withTime(maps[i]['category'], maps[i]['time']);
    });
  }
  
  Future<List<AWord>> getWords(String category) async {
    final Database db = await database;
    List<Map> maps = await db.query(tableWords,
        columns: [columnCategory, columnWord],
        where: '$columnCategory = ?',            
        whereArgs: [category]);
    return List.generate(maps.length, (i) {
      return AWord(maps[i]['category'], maps[i]['word']);
    });
  }


  Future<int> getCategoryCount() async {
    //database connection
    Database db = await this.database;
    var x = await db.rawQuery('SELECT COUNT (*) from $tableCategories');
    int count = Sqflite.firstIntValue(x);
    return count;
  }
  Future<int> getAllWordsCount() async {
    //database connection
    Database db = await this.database;
    var x = await db.rawQuery('SELECT COUNT (*) from $tableWords');
    int count = Sqflite.firstIntValue(x);
    return count;
  }
  Future<int> delete(String c) async {
    final db = await this.database;
    var result = await db.delete(tableCategories, where: 'category = ?', whereArgs: [c]);
    return result;
  }
  // TODO: queryAllWords()
  // TODO: delete(int id)
  // TODO: update(Word word)
}