import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/services/socket_service.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text( 'Server Status: ${socketService.serverStatus}' )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon( Icons.message ),
        onPressed: () {

            socketService.socket.emit( 'emitir-mensaje',
            { 
              'nombre': 'Flutter',
              'mensaje': 'Hola desde Flutter' 
            });
        },
      ),
    );
  }
}