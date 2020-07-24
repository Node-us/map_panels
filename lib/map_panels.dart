import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

abstract class MapPanel<T> {
  String name;
  T data;
  Marker Function(T data) markerBuilder;

  double maxHeight = ui.window.physicalSize.height / ui.window.devicePixelRatio;
  double minHeight = 0;
  bool parallaxEnabled;
  double parallaxOffset;
  double snapPoint;
//      Widget Function(ScrollController) panelBuilder,
//      MapPanel panel;
  BorderRadius borderRadius;
  PanelController _panelController;
  Function onPanelClosed;
  Function(double) onPanelSlide;
  PanelState defaultPanelState = PanelState.CLOSED;
  bool showAtSnapPoint = true;

  MapPanelsController panelsController;

  PanelController get panelController => _panelController;

  String key;

  MapPanel({
    this.name,
    this.data,
    this.markerBuilder,
    this.maxHeight,
    this.minHeight,
    this.parallaxEnabled,
    this.snapPoint,
    this.borderRadius,
    this.onPanelClosed,
    this.onPanelSlide,
    this.defaultPanelState = PanelState.CLOSED,
    this.showAtSnapPoint = true,
    this.panelsController,
    this.parallaxOffset,
    panelController,
  }) {
    _panelController = panelsController ?? PanelController();
  }

  Widget panelBuilder(ScrollController scrollController);

  Marker get marker => markerBuilder(data);

  void show(BuildContext context) {
    final panelsController =
        Provider.of<MapPanelsController>(context, listen: false);
    key = panelsController.addPanel(this);
  }
}

class DisplayingPanel {
  String name;
  PanelController controller;
  SlidingUpPanel widget;
  MapPanel panel;
  String key;
  dynamic data;
  double lastPos;
  DisplayingPanel(
      {this.name,
      this.panel,
      this.controller,
      this.widget,
      this.lastPos,
      this.key,
//        this.type,
      this.data});
}

class MapPanelsController extends ValueNotifier<LinkedHashMap> {
  LinkedHashMap<String, DisplayingPanel> _panels = LinkedHashMap();
  LinkedHashMap<String, DisplayingPanel> get value => _panels;

  Function(MapPanelsController) onNewPanelCreated;
  Function(MapPanelsController) onCurrentPanelRemoved;

  bool autoRestoreLastPanel;

  MapPanelsController({
    this.onNewPanelCreated,
    this.onCurrentPanelRemoved,
    this.autoRestoreLastPanel = true,
  }) : super(LinkedHashMap());

  String _genKey() {
    while (true) {
      final key = Random().nextInt(1000).toString();
      if (_panels[key] == null) return key;
    }
  }

  void closeCurrent() async {
    final DisplayingPanel current = _panels.entries.last.value;
    if (current.controller.isAttached) await current.controller.close();
  }

  PanelController get currentController {
    final DisplayingPanel current = _panels.entries.last.value;
    return current.controller;
  }

  double currentPanelPosition() {
    final current = _panels.entries.last.value.controller;
    if (!current.isAttached) return 0;
    final panel = _panels.entries.last;
    final pos = current.panelPosition;
    final max = panel.value.widget.maxHeight;
    final min = panel.value.widget.minHeight;
//    current.value.panelPosition;
//    panel.value.minHeight;
    return (((max - min) * pos) + min) / max; //current.value.panelPosition;
  }

  void removeCurrent() async {
    final current = _panels.entries.last.value;
    await current.controller.animatePanelToPosition(0);
//    controllers.remove(current.key);
    _panels.remove(current.key);
    if (_panels.entries.length > 0 && autoRestoreLastPanel) {
      final last = _panels.entries.last.value;
//      if (last.type == PanelType.main) {
//        last.controller.animatePanelToSnapPoint();
//      } else {
      await last.controller.animatePanelToPosition(last.lastPos);
//      }
    }
    Timer(Duration(milliseconds: 100), () async {
      if (onCurrentPanelRemoved != null) onCurrentPanelRemoved(this);
    });
    super.notifyListeners();
  }

  void remove(
    String key,
  ) async {
    _panels.remove(key);
    super.notifyListeners();
  }

  String addPanel(MapPanel panel) {
    final key = _genKey();

    final widget = SlidingUpPanel(
      key: Key(key),
      maxHeight: panel.maxHeight ??
          ui.window.physicalSize.height / ui.window.devicePixelRatio,
      minHeight: panel.minHeight ?? 0,
      parallaxEnabled: panel.parallaxEnabled,
      parallaxOffset: panel.parallaxOffset,
      snapPoint: panel.snapPoint,
      panelBuilder: panel.panelBuilder,
      borderRadius: panel.borderRadius,
      onPanelClosed: panel.onPanelClosed,
      onPanelSlide: panel.onPanelSlide,
      controller: panel.panelController,
      defaultPanelState: panel.defaultPanelState,
    );

    final _controller = panel.panelController;
    _panels[key] = DisplayingPanel(
      widget: widget,
      name: panel.name,
      controller: panel.panelController,
      key: key,
      data: panel.data,
      panel: panel,
//        type: type
    );
    Timer(Duration(milliseconds: 100), () async {
      if (_controller.isAttached) {
        if (panel.showAtSnapPoint == true) {
          await _controller.animatePanelToSnapPoint();
        }
      }
      if (_panels.entries.length > 1) {
        final DisplayingPanel current =
            _panels.entries.elementAt(_panels.entries.length - 2).value;
        current.lastPos = current.controller.panelPosition;
        await current.controller.close();
//        if (type == PanelType.home && current.type == PanelType.home) {
//          controllers.remove(current.key);
//          panels.remove(current.key);
//        }
      }
      if (onNewPanelCreated != null) {
        onNewPanelCreated(this);
      }
    });
    super.notifyListeners();
    return key;
  }
}

class MapPanelsProvider extends StatefulWidget {
  MapPanelsController _controller;
  Widget child;
  MapPanelsProvider({
    MapPanelsController controller,
    this.child,
  }) {
    _controller = controller ?? MapPanelsController();
  }
  MapPanelsProviderState createState() =>
      MapPanelsProviderState(_controller, child);
}

class MapPanelsProviderState extends State<MapPanelsProvider> {
  MapPanelsController _controller;
  Widget child;

  bool Function(MapPanel panel) filter;

  MapPanelsProviderState(this._controller, this.child, {this.filter});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var ps = (_controller?.value ?? {}).values.map((p) => p.widget);

    return InheritedProvider.value(
      value: _controller,
      child: Material(
        child: Stack(
          children: <Widget>[
            child,
            ...ps,
          ],
        ),
      ),
    );
  }
}
