import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:task_map/home_page/bloc/create_data_bloc.dart';
import 'package:task_map/home_page/bloc/get_data_bloc.dart';
import 'dart:async'; // Add this import

void main() {
  runApp(const MyApp());
}

Dio dio = Dio(BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const DisplayData(),
    );
  }
}

class DisplayData extends StatelessWidget {
  const DisplayData({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) => GetDataBloc()..add(GetData()),
        ),
        BlocProvider(create: (context) => CreateDataBloc()),
      ],
      child: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: ElevatedButton(
          child: const Text('Create'),
          onPressed: () =>
              BlocProvider.of<CreateDataBloc>(context).add(CreateData(body: {
            "title": "NewOne",
            "body": "For Task",
            "userId": 1000,
          })),
        ),
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MapPage()));
              },
            )
          ],
        ),
        body: BlocListener<CreateDataBloc, CreateDataState>(
          listener: (context, state) {
            if (state is CreateDataSuccess) {
              Fluttertoast.showToast(
                msg:
                    'Data created successfully \nTitle: ${state.data['title']}\nBody: ${state.data['body']}\nUserId: ${state.data['userId']}\nId: ${state.data['id']}',
                toastLength: Toast
                    .LENGTH_SHORT, // Duration for which the toast is visible
                gravity: ToastGravity.BOTTOM, // Position of the toast message
                backgroundColor: Colors.black, // Background color of the toast
                textColor: Colors.white, // Text color of the toast message
              );
            }
          },
          child: BlocBuilder<GetDataBloc, GetDataState>(
            builder: (context, state) {
              if (state is GetDataLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GetDataFailed) {
                return Center(child: Text(state.error));
              }
              if (state is GetDataLoaded) {
                final List dataList = state.data;
                return dataList.isEmpty
                    ? const Text("No data found")
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: dataList.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (_, index) => ListTile(
                              title: Text(dataList[index]['title']),
                              trailing:
                                  Text(dataList[index]['userId'].toString()),
                              subtitle: Text(
                                dataList[index]['body'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  _onMapCreated(GoogleMapController controller) async {
    addmarker();
  }

  addmarker() async {
    List<LatLng> latlngList = [
      const LatLng(11.136640500480485, 78.59667601500081),
      const LatLng(11.136345749795277, 78.59804930596258),
      const LatLng(11.137008938417248, 78.59754505068757),
    ];
    List<String> profiles = [
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlciUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D",
      "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlciUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWWhdy5cHpAf-ERlSnLc0-iX7B470mSw8GOpES67sCQA&s"
    ];
    for (int i = 0; i < latlngList.length; i++) {
      Marker marker = Marker(
        markerId: MarkerId(i.toString()),
        position: latlngList[i],
        infoWindow: InfoWindow(
          title: i.toString(),
        ),
        icon: BitmapDescriptor.fromBytes(
          await _createMarkerImage(
            profiles[i], // URL of the image
          ),
          size: const Size(8, 8),
        ),
      );
      setState(() {
        markers[MarkerId(i.toString())] = marker;
      });
    }
  }

  Future<Uint8List> _createMarkerImage(String imageUrl) async {
    final imageProvider =
        CachedNetworkImageProvider(imageUrl, maxHeight: 68, maxWidth: 68);
    final Completer<Uint8List> completer = Completer();
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    imageStream.addListener(ImageStreamListener((imageInfo, _) async {
      final byteData =
          await imageInfo.image.toByteData(format: ImageByteFormat.png);
      final Uint8List uint8List = byteData!.buffer.asUint8List();
      completer.complete(uint8List);
    }));
    return completer.future;
  }

  Future<Uint8List> _getBytesFromAsset(
      String path, int width, int height) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width, targetHeight: height);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        key: widget.key,
        mapType: MapType.normal,
        myLocationEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: _onMapCreated,
        myLocationButtonEnabled: true,
        markers: Set<Marker>.of(markers.values),
        initialCameraPosition: const CameraPosition(
          target: LatLng(11.135882569544034, 78.5983282556892),
          zoom: 14.4746,
        ),
      ),
    );
  }
}
