import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:qrreaderapp/src/models/scan_model.dart';
export 'package:qrreaderapp/src/models/scan_model.dart';



class DBProvider{
  static Database _database; 
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async{

    if( _database != null ) return _database;

    _database = await initDB();

    return _database;

  }

  initDB() async{
    Directory documentsDirectory = await getApplicationDocumentsDirectory();  //obtener el path de la base de datos
    String path = join(documentsDirectory.path, 'ScansDB.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db){},
      onCreate: (Database db, int version)async{
        await db.execute(
          'CREATE TABLE Scans ('
          ' id INTEGER PRIMARY KEY,'
          ' tipo TEXT,'
          ' valor TEXT'
          ')'
        );
      }
    );
  }


//Crear Registros de manera manual
  nuevoScanraw(ScanModel nuevoScan) async{
    final db = await database;                    //si ya tenemos informacion de la base de datos esperamos obtener la BD

    final res = await db.rawInsert(
      "INSERT Into Scans (id, tipo, valor) "
      "VALUES ('${nuevoScan.id}', '${nuevoScan.tipo}', '${nuevoScan.valor}')"
    );

    return res;

  }
//Crear Registros de manera automatica
  nuevoScan(ScanModel nuevoScan) async{
    final db = await database;
    final res = await db.insert('Scans', nuevoScan.toJson());

    return res;
  }

// SELECT - Obtener Informacion 
  Future<ScanModel> getScanId(int id) async{

    final db = await database;        //verificamos si podemos escribir en la base de datos  
    final res = await db.query('Scans', where: 'id = ?', whereArgs: [id]);

    return res.isEmpty ? ScanModel.fromJson(res.first) : null;
  }

  Future<List<ScanModel>> getTodosScans() async {
    final db  = await database;
    final res = await db.query('Scans');

    List<ScanModel> list = res.isNotEmpty 
                              ? res.map( (c) => ScanModel.fromJson(c) ).toList()
                              : [];
    return list;

  }

  Future<List<ScanModel>> getPorTipo(String tipo) async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM Scans WHERE tipo='$tipo'");

    List<ScanModel> list = res.isEmpty ? res.map( (c) => ScanModel.fromJson(c)).toList() : [];

    return list;

  }

//Actualizar Registros

  Future<int> updateScan(ScanModel nuevoScan)async{
    final db = await database;

    final res = await db.update('Scans', nuevoScan.toJson(), where: 'id = ?', whereArgs: [nuevoScan.id]);

    return res;
  }

// Eliminar Registros

  Future<int> deleteScan( int id ) async {
    final db = await database;
    final res = await db.delete('Scans', where: 'id = ?', whereArgs: [id]);

    return res;
  }


  Future<int> deleteAll() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM Scans');

    return res;
  }




}