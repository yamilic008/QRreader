import 'dart:async';

import 'package:qrreaderapp/src/bloc/validator.dart';
import 'package:qrreaderapp/src/providers/db_provider.dart';


class ScansBloc with Validators{                                    //Sele agrega el mixin
  static final ScansBloc _singleton = new ScansBloc._internal();

  factory ScansBloc(){    //Constructor que regresa una instancia  unica
    return _singleton;
  }

  ScansBloc._internal(){
    //Obtener Scans de la base de datos
    obtenerScans();

  }

  final _scansController = StreamController<List<ScanModel>>.broadcast();
//************************************************************** */
  Stream<List<ScanModel>> get scansStream => _scansController.stream.transform(validarGeo);                         //*****para escuchar lo que pasa por el stream****
  Stream<List<ScanModel>> get scansStreamHttp => _scansController.stream.transform(validarHttp);                         //*****para escuchar lo que pasa por el stream****
//****************************************************************** */
  dispose(){
    _scansController?.close();
  }

  


  obtenerScans() async {
    _scansController.sink.add(await DBProvider.db.getTodosScans());     //Trae toda la informacion  utilizando getTodosScans

  }

  agegarScan(ScanModel scan) async{
    await DBProvider.db.nuevoScan(scan);
    obtenerScans();
  }

  borrarScan(int id) async{
    await DBProvider.db.deleteScan(id);                               //Borra los elementos 
    obtenerScans();                                                   //Vuelve a cargar la base de datos
  }

  borrarScanTODOS() async{
    await DBProvider.db.deleteAll();
    obtenerScans();
  }





}