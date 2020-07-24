import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_panels/map_panels.dart';

import 'park.dart';

void main() {
  runApp(MyApp());
}

class MainPanel extends MapPanel {
  MainPanel() : super(snapPoint: 0.25);

  @override
  Widget panelBuilder(BuildContext context, ScrollController scrollController,
      MapPanelsController panelsController) {
    final parks = Park.taiwanParks;
    // TODO: implement panelBuilder
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'National parks of Taiwan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 250,
              child: ListView.builder(
                  itemCount: parks.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => ParkItem(parks[index])),
            )
          ],
        ));
  }
}

class ParkItem extends StatelessWidget {
  Park park;
  ParkItem(this.park);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ParkPanel(park).show(context);
      },
      child: Container(
        padding: EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 160,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                image: DecorationImage(
                    fit: BoxFit.cover, image: NetworkImage(park.imageUrl)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              park.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ParkPanel extends MapPanel {
  Park park;
  ParkPanel(this.park)
      : super(
          name: 'park',
          snapPoint: 0.45,
        );

  @override
  Widget panelBuilder(BuildContext context, ScrollController scrollController,
      MapPanelsController panelsController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width,
            height: 160,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: NetworkImage(park.imageUrl)),
            ),
            padding: EdgeInsets.only(top: 10, right: 10),
            alignment: Alignment.topRight,
            child: ClipOval(
              child: Material(
                color: Colors.black.withOpacity(0.25), // button color
                child: InkWell(
                  child: SizedBox(
                      width: 26,
                      height: 26,
                      child: Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 20,
                      )),
                  onTap: () {
                    panelsController.removeCurrent();
                  },
                ),
              ),
            )),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                park.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                park.description,
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  MapPanelsController panelsController =
      MapPanelsController(onNewPanelCreated: (controller) {
    final int previousIndex = controller.value.length - 2;
    if (previousIndex < 0) return;
    DisplayingPanel last = controller.value.values.toList()[previousIndex];
    if (last.name == 'park') {
      controller.remove(last.key);
    }
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MapPanelsProvider(
          controller: panelsController,
          child: MapPage(title: 'Flutter Demo Home Page')),
    );
  }
}

class MapPage extends StatefulWidget {
  MapPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void didChangeDependencies() {
    Timer(Duration(seconds: 1), () async {
      MainPanel().show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FlutterMap(
      options: MapOptions(
        center: LatLng(23.130847, 120.883967),
        zoom: 7,
      ),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        MarkerLayerOptions(markers: [
          ...Park.taiwanParks.map(
            (park) => Marker(
                point: park.location,
                builder: (ctx) => GestureDetector(
                      onTap: () {
                        ParkPanel(park).show(context);
                      },
                      child: Icon(
                        Icons.location_on,
                        color: Colors.deepOrange,
                        size: 28.0,
                      ),
                    ),
                height: 30),
          )
        ]),
      ],
    ));
  }
}
