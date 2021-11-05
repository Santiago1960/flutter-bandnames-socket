import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// IMPORTACIONES
import 'package:band_names/models/band.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band( id: '1', name: 'Metallica', votes: 5 ),
    Band( id: '2', name: 'Queen', votes: 6 ),
    Band( id: '3', name: 'Héroes del Silencio', votes: 1 ),
    Band( id: '4', name: 'Bon Jovi', votes: 5 ),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text( 'Nombres de las Bandas', style: TextStyle( color: Colors.black54 ), ),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      
      body: ListView.builder(

        itemCount: bands.length,
        itemBuilder: ( context, i ) => _bandTile( bands[i] ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: const Icon( Icons.add ),
        elevation: 1.0,
      ),
    );
  }

  Widget _bandTile( Band band ) {

    return Dismissible(
      key: Key( band.id ),
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction ) {

        print( 'direction: $direction' );
        print( 'id: ${band.id}' );
        // !LLAMAR EL BORRADO EN EL SERVER
      },
      background: Container(
        padding: const EdgeInsets.only( left: 20.0 ),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text( 'Borrar Banda', style: TextStyle( color: Colors.white ), ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text( band.name.substring( 0, 2 ).toUpperCase() ),
        ),
        title: Text( band.name ),
        trailing: Text( '${ band.votes }', style: const TextStyle( fontSize: 20 ), ),
        onTap: () {

          print( band.name );
        },
      ),
    );
  }

  addNewBand() {

    final textController = TextEditingController();

    if( Platform.isAndroid ) {

      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: ( context ) {

          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all( Radius.circular( 10.0 ) ),
            ),
            elevation: 10.0,
            title: const Text( 'Nombre de la nueva banda:' ),
            content: TextField(
              controller: textController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            actions: [
              MaterialButton(
                child: const Text( 'Añadir' ),
                textColor: Colors.blue,
                onPressed: () {

                  addBandToList( textController.text );
                  dispose();
                },
  
              ),
              MaterialButton(
                child: const Text( 'Cancelar' ),
                textColor: Colors.red,
                onPressed: () => Navigator.pop( context )
              )
            ],
          );
        }
      );
    }

    showCupertinoDialog(
      
      context: context,
      builder: ( _ ) {

        return CupertinoAlertDialog(
          title: const Text( 'Nombre de la nueva banda' ),
          content: CupertinoTextField(
            controller: textController ,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text( 'Añadir' ),
              onPressed: () => addBandToList( textController.text ),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text( 'Cancelar' ),
              onPressed: () => Navigator.pop( context ),
            )
          ],
        );
      }
    );
    
  }

  void addBandToList( String name ) {

    print( name );

    if( name.length > 1 ) {

      bands.add( Band(
          id: DateTime.now().toString(),
          name: name,
          votes: 0
        )
      );
      setState(() {});
    }
    Navigator.pop( context );
  }

}