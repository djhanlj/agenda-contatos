import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contacTable = 'contactTable';
final String idColumn = 'idColumn';
final String nameColumn = 'nameColumn';
final String emailColumn = 'emailColumn';
final String phoneColumn = 'phoneColumn';
final String imgColumn = 'imgColumn';

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'contacts.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          'create table $contacTable ($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,'
          '$phoneColumn TEXT, $imgColumn TEXT)');
    });
  }

  Future<Contact> saveContact(Contact contact) async{
    Database dbContact = await db;
    try{
      contact.id = await dbContact.insert(contacTable, contact.toMap());
      print('salvar ' + contact.toString());
      return contact;
    }catch(e){
      print('Erro em saveContact ' + e.toString());
    }
  }

  Future<Contact> getContact(int id) async{
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contacTable,
        columns: [idColumn,nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if (maps.length > 0){
      return Contact.fromMap(maps.first);
    }else{
      return null;
    }
  }

  Future<int> deleteContact(int id) async{
    Database dbContact = await db;
    return await dbContact.delete(contacTable,
        where: "$idColumn = ?",
        whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async{
    Database dbContact = await db;
    return await dbContact.update(contacTable,
        contact.toMap(),
        where: "$idColumn = ?",
        whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async{
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery('select * from $contacTable');
    List<Contact> listContact = List();
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async{
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery('Select count(*) from $contacTable'));
  }

  Future close() async{
    Database dbContact = await db;
    dbContact.close();
  }

}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    print('from map' + map.toString());
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email)';
  }
}
