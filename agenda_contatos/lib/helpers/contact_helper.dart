import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String idColumn = "idColumn",
    nameColumn = "nameColumn",
    ContactTable = "contactTable";
final String emailColumn = "emailColumn",
    phoneColumn = "phoneColumn",
    imgColumn = "imgColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();
  Database _db;

 Future<Database> get db async {
    if (_db != null)
      return _db;
    else
      _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");
    return openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(" CREATE TABLE $ContactTable("
          "$idColumn INTEGER PRIMARY KEY, "
          "$nameColumn TEXT, $emailColumn TEXT,"
          "$phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  Future<Contact> SaveContact(Contact contact) async
  {
    Database dbContact = await db;
    contact.id = await dbContact.insert(ContactTable, contact.toMap());
    return contact;
  }

  Future <Contact> GetContact(int id) async
  {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(ContactTable,columns: [idColumn,nameColumn, emailColumn,phoneColumn,imgColumn],
    where: "$idColumn = ?", whereArgs: [id]);
    if(maps.length > 0)
      return Contact.fromMap(maps.first);
    else
      return null;
  }
  Future<int> DeleteContact(int id) async
  {
    Database dbContact = await db;
    return await dbContact.delete(ContactTable, where: "$idColumn = ?",whereArgs: [id]);
  }

  Future<int> UpdateContact(Contact contact) async{
   Database dbContact = await db;
   return await dbContact.update(ContactTable, contact.toMap(),where: "$idColumn = ?", whereArgs: [contact.id]);
  }
  Future<List> GetAllContacts() async
  {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $ContactTable");
    List<Contact> listContact = [];
    for(Map m in listMap)
        listContact.add(Contact.fromMap(m));
    return listContact;
  }

  Future<int> GetNumber() async {
    Database dbContact = await db;
   return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $ContactTable"));
  }
  Future Close() async
  {
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
      imgColumn: img
    };
    if (id != null) map[idColumn] = id;

    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
