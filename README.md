# map_panels

A Flutter package that you can use to create panel style map app easily.

![image](https://media.giphy.com/media/mGbINGJpV4051si2Z0/giphy.gif)

## Usage


#### 1. Wrap your app (or screen/widget) with `MapPanelsProvider`
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapPanelsProvider(child: YourScreen())
    );
  }
}
```

#### 2. Write your own panel
```dart

class MainPanel extends MapPanel {
  MainPanel() : super();

  @override
  Widget panelBuilder(BuildContext context, ScrollController scrollController, MapPanelsController panelsController) {
    return Container(child: Text('My awesome panel'));
  }
}
```
#### 3. Show your panel
```dart

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
          subdomains: ['a', 'b', 'c']
        ),
      ]
    );
  }
}
```

## Credit
This package is built with [sliding_up_panel](https://github.com/akshathjain/sliding_up_panel)
