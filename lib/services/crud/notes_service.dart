import 'dart:async';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];
  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  //singleton of service in Dark
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  Future<void> _enshureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    log(email);
    try {
      log('comes here 1');

      final user = await getUser(email: email);
      log(user.toString());
      return user;
    } on CouldNotFindUser {
      log('comes here');
      final createdUser = await createUser(email: email);
      log(createdUser.toString());
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _casheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _enshureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatedCount = await db.update(
        noteTable, {textColumn: text, isSyncedWithCloudColumn: 0},
        where: 'id = ?', whereArgs: [note.id]);

    if (updatedCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == note.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _enshureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _enshureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final notes =
        await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);

      log(note.id.toString());
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _enshureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    await _enshureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _enshureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email.toLowerCase());

    if (dbUser != owner) {
      log("not the same user");
      throw CouldNotFindUser();
    }

    const text = '';
    log('Creating-1');

    final noteId = await db.insert(
      noteTable,
      {userIdColumn: owner.id, textColumn: text, isSyncedWithCloudColumn: 1},
    );

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);
    log(note.id.toString());

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _enshureDbIsOpen();
    final db = _getDatabaseOrThrow();

    log("GET USER 1");
    log("GET USER EMAIL:" + email);

    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    log("GET USER 2");

    log("GET USER:" + result.first.toString());

    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _enshureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _enshureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email= ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //create user table
      await db.execute(createUserTable);
      //create note table
      await db.execute(createNoteTable);
      await _casheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectly();
    }
  }
}

class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email=$email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id
      .hashCode; //the id will become it's main identifier even if you will add two object with the same id into the list it will update tht list;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSynctWithCloud=$isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';

const idColumn = 'id';
const emailColumn = 'email';

const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "user" (
          "id"	INTEGER NOT NULL,
          "email"	TEXT NOT NULL UNIQUE,
          PRIMARY KEY("id" AUTOINCREMENT)
        );
      ''';

const createNoteTable = ''' 
      CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';