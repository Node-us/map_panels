import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

abstract class MapPanel<T> {
  String name;
  T data;

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
  bool panelSnapping;
  bool isDraggable;

  MapPanelsController panelsController;

  PanelController get panelController => _panelController;

  String key;

  MapPanel({
    this.name,
    this.data,
    this.maxHeight,
    this.minHeight,
    this.parallaxEnabled,
    this.snapPoint = 0.5,
    this.borderRadius,
    this.onPanelClosed,
    this.onPanelSlide,
    this.defaultPanelState = PanelState.CLOSED,
    this.showAtSnapPoint = true,
    this.panelsController,
    this.parallaxOffset,
    this.panelSnapping = true,
    this.isDraggable = true,
    panelController,
  }) {
    _panelController = panelsController ?? PanelController();
  }

  List<Widget> stackWidgets(BuildContext context) => [];

  Widget panelBuilder(BuildContext context, ScrollController scrollController,
      MapPanelsController panelsController);

  void show(BuildContext context) {
    final panelsController =
        Provider.of<MapPanelsController>(context, listen: false);
    key = panelsController.addPanel(context, this);
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
  
  double get currentPanelMaxHeight => _panels.entries.last.value.widget.maxHeight;
  double get currentPanelMinHeight => _panels.entries.last.value.widget.minHeight;

  void removeCurrent() async {
    final current = _panels.entries.last.value;
	

    _panels.remove(current.key);
    if (_panels.entries.length > 0 && autoRestoreLastPanel) {
      final last = _panels.entries.last.value;

	  if (!last.controller.isPanelShown) await last.controller.show();
      await last.controller.animatePanelToPosition(last.lastPos);
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

  String addPanel(BuildContext context, MapPanel panel) {
    final key = _genKey();

    final widget = SlidingUpPanel(
      key: Key(key),
      maxHeight: panel.maxHeight ??
          ui.window.physicalSize.height / ui.window.devicePixelRatio,
      minHeight: panel.minHeight ?? 0,
      parallaxEnabled: panel.parallaxEnabled,
      parallaxOffset: panel.parallaxOffset,
      snapPoint: panel.snapPoint,
      panelBuilder: (ScrollController scrollController) =>
          panel.panelBuilder(context, scrollController, this),
      borderRadius: panel.borderRadius,
      onPanelClosed: panel.onPanelClosed,
      onPanelSlide: panel.onPanelSlide,
	  isDraggable: panel.isDraggable,
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

  _setState() {
    setState(() {
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(_setState);
  }

  void dispose() {
   _controller.removeListener(_setState);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> ps = (_controller?.value ?? {}).values.map<List<Widget>>((p) => [
      p.widget, ...(p.panel.stackWidgets != null ? p.panel.stackWidgets(context) : [])
    ]).expand((i) => i).toList();

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
