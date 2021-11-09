// import 'dart:html';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

// IMPORTACIONES
import 'package:band_names/models/band.dart';
import 'package:provider/provider.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /* List<Band> bands = [
    Band( id: '1', name: 'Metallica', votes: 5 ),
    Band( id: '2', name: 'Queen', votes: 6 ),
    Band( id: '3', name: 'Héroes del Silencio', votes: 1 ),
    Band( id: '4', name: 'Bon Jovi', votes: 5 ),
  ]; */
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('bandas-activas', _handleActiveBands );
    super.initState();
  }

  _handleActiveBands( dynamic payload ) {

    bands = (payload as List)
        .map((banda) => Band.fromMap(banda))
        .toList();

    setState(() {});
  }

  // Dejar de escuchar al destruir la página
  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('bandas-activas');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    Map<String, double> votos = {};

    if( bands.isNotEmpty) {

      for (var banda in bands) {

        votos[banda.name] = banda.votes.toDouble();
      }
    } else {

      votos = {'No hay datos disponibles':0};
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text( 'Nombres de las Bandas', style: TextStyle( color: Colors.black54 ), ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        actions: [
          Container(
            margin: const EdgeInsets.only( right: 10.0 ),
            child:
              ( socketService.serverStatus == ServerStatus.online) ?
              const Icon( Icons.signal_cellular_alt, color: Colors.green, ) :
              const Icon( Icons.signal_cellular_off, color: Colors.red, ),
          )
        ],
      ),
      
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only( top: 30.0, bottom: 20.0 ),
            child: _showGraph( votos ),
          ),
          Expanded(
            child: ListView.builder(
          
              itemCount: bands.length,
              itemBuilder: ( context, i ) => _bandTile( bands[i] ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: const Icon( Icons.add ),
        elevation: 1.0,
      ),
    );
  }

  Widget _bandTile( Band band ) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.socket.emit('borrar-banda', { 'id': band.id }),
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
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
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
                onPressed: () => addBandToList( textController.text ),
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

  addBandToList( String name ) {

    if( name.length > 1 ) {

      int coincidencia = 0;

      for (var element in bands) {

        if( element.name.toUpperCase() == name.toUpperCase() ) {
          coincidencia ++;
        }
      }

      if( coincidencia == 0 ) {

        final socketService = Provider.of<SocketService>(context, listen: false);

        final id = DateTime.now().toString();

        bands.add( Band(
            id: id,
            name: name,
            votes: 0
          )
        );
        socketService.socket.emit('nueva-banda', {'name': name } );
        Navigator.pop( context );
      } else {

        Navigator.pop( context );

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
              content: const Text( 'Esta banda ya está registrada' ),
              actions: [
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
    }
    
  }

  Widget _showGraph( votos ) {

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: PieChart(
        chartType: ChartType.ring,
        chartRadius: 150.0,
        chartLegendSpacing: 40.0,
        centerText: 'Porcentaje',
        ringStrokeWidth: 20,
        legendOptions: const LegendOptions(
                                            legendPosition: LegendPosition.right,
                                            legendShape: BoxShape.circle
                                          ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          decimalPlaces: 0,
          showChartValuesInPercentage: true,
        ),
        dataMap: votos
      ),
    );
  }


}