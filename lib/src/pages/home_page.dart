import 'dart:io';

import 'package:flutter/material.dart';

import 'package:qrreaderapp/src/bloc/scans_bloc.dart';
import 'package:qrreaderapp/src/models/scan_model.dart';

import 'package:qrreaderapp/src/pages/direcciones_page.dart';
import 'package:qrreaderapp/src/pages/mapas_page.dart';

import 'package:qrcode_reader/qrcode_reader.dart';
import 'package:qrreaderapp/src/utils/utils.dart' as utils;


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final scansBloc = new ScansBloc();                    //Todo debe de pasar por aqui

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: (){
              scansBloc.borrarScanTODOS();
            },
          )
        ],
      ),
      body: _callPage(currentIndex),
      bottomNavigationBar: _crearBottomNavigationBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.filter_center_focus),
        onPressed: (){
          _scanQR(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  _scanQR(BuildContext context) async{

    //http://google.com
    //geo:25.60408761009088,-103.40692177256471

    // String futureString = 'http://google.com';
     String futureString = '';


    try{
      futureString  = await new QRCodeReader().scan();
    } catch(e) {
      futureString = e.toString();
    }

    // print( 'futureString $futureString' );

    if ( futureString != null ){
      final scan = ScanModel(valor: futureString);
      scansBloc.agegarScan(scan);
      // DBProvider.db.nuevoScan(scan);               //Funciona pero no notifica al striming

      // final scan2 = ScanModel(valor: 'geo:25.60408761009088,-103.40692177256471');
      // scansBloc.agegarScan(scan2);
      if ( Platform.isIOS ){ 
        Future.delayed( Duration(milliseconds: 750),(){
          utils.abrirScan(context, scan);
        });
      } else {
        utils.abrirScan(context, scan);
      }

    }

  }




  Widget _crearBottomNavigationBar(){
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index){
        setState(() {
         currentIndex=index; 
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          title: Text('Maps')
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.brightness_5),
          title: Text('Direcciones')
        )
      ],
    );
  }

  Widget _callPage(int paginaActual){

        switch(paginaActual){
          case 0: return MapasPage();
          case 1: return DireccionesPage();

          default: return MapasPage();
        }
  }
}