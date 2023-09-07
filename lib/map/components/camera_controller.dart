import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

enum CameraState {
  locked,
  controllable,
  fly,
}

class CameraController extends Component{
  Vector2 _position = Vector2(0, 0);
  double _zoom = 1.0;
  Camera camera;
  FlyAnimation? flyAnimation;
  double scaleStartZoom = 0.0;
  Function onCameraDrag = () {};
  final maxZoom = 1/2.0;
  final minZoom = 1/15.0;
  var state = CameraState.controllable;

  CameraController({required this.camera});

  set position(n){
    if(_position != n){
      if(state == CameraState.controllable){
        onCameraDrag();
      }
      _position = n;
    }
    camera.snapTo(_position-camera.viewport.effectiveSize/2/camera.zoom);
  }

  Vector2 get position => _position;
  Vector2 get topLeftPosition => _position-camera.viewport.effectiveSize/2*camera.zoom;

  set zoom(double n){
    _zoom = n.clamp(minZoom, maxZoom).toDouble();
    camera.zoom = zoom;
    position = position;
  }

  double get zoom => _zoom;

  void fly(Vector2 endPosition, {double targetZoom = 0.18, double speed = 0.0}){
    if(speed == 0.0){
      var maxTime = 3.0;
      var scaleFactor = 0.00005;
      var distance = position.distanceTo(endPosition);
      var time = -pow(e, -scaleFactor*(distance-log(maxTime)/scaleFactor))+maxTime;
      if(time == 0){return;}
      speed = distance/time;
    }
    flyAnimation = FlyAnimation(
      startPosition: position,
      endPosition: endPosition,
      initialZoom: zoom,
      finalZoom: targetZoom,
      speed: speed,
      scaleFactor: 0.001,
    );
    state = CameraState.fly;
  }


  @override
  void update(double dt) {
    switch(state){
      case CameraState.fly:
        if(flyAnimation != null){
          flyAnimation!.update(dt);
          position = flyAnimation!.position;
          zoom = flyAnimation!.zoom;
          if(flyAnimation!.complete){
            state = CameraState.controllable;
          }
        }
    }
    super.update(dt);
  }

  void controlPosition(Vector2 newPosition){
    if(state == CameraState.controllable){
      position = newPosition;
    }
  }

  void controlZoom(double newZoom){
    if(state == CameraState.controllable){
      zoom = newZoom;
    }
  }
}

class FlyAnimation {
  final Vector2 startPosition;
  final Vector2 endPosition;
  final double initialZoom;
  final double finalZoom;
  final double speed;
  final double scaleFactor;

  double _distanceCovered = 0.0;

  FlyAnimation({
    required this.startPosition,
    required this.endPosition,
    required this.initialZoom,
    required this.finalZoom,
    required this.speed,
    required this.scaleFactor,
  });

  void update(double dt){
    _distanceCovered += dt*speed;
    _distanceCovered = min(_distanceCovered, totalDistance);
  }

  Vector2 get position => startPosition*(1-_distanceCovered/startPosition.distanceTo(endPosition))+endPosition*(_distanceCovered/startPosition.distanceTo(endPosition));
  double get zoom {
    var peakMod = max(1/initialZoom, 1/finalZoom);
    var targetZoom = totalDistance/2 > _distanceCovered ? 1/initialZoom : 1/finalZoom;
    return 1/(-((_distanceCovered)*(_distanceCovered-totalDistance)*(totalDistance*scaleFactor-targetZoom+peakMod)/pow(totalDistance/2, 2))+targetZoom);
  }

  double get totalDistance => startPosition.distanceTo(endPosition);

  bool get complete => _distanceCovered >= totalDistance;
}