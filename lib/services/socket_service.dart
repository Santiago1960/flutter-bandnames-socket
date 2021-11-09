// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketService with ChangeNotifier {

  // ignore: unused_field
  ServerStatus _serverStatus = ServerStatus.connecting;
  IO.Socket _socket = IO.io('http://192.168.122.1:3000', {

                        'transports': ['websocket'],
                        'autoConnect': true,
                      });

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;

  SocketService() {

    _initConfig();
  }

  void _initConfig() {

    // Dart client
    _socket = IO.io('http://192.168.122.1:3000', {

      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket.onConnect((_) {

      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {

      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    /* _socket.on( 'nuevo-mensaje', ( payload ) {

      print( 'Nuevo mensaje:');
      print( 'Nombre: ${payload['nombre']}' );
      print( 'Mensaje: ${payload['mensaje']}' );
      print( 'Variable inexistente: ${payload.containsKey('mensaje2') ? payload['mensaje2'] : 'No se envió el dato'}' );
    }); */
  }
}