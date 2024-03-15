import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class ControlledState<T extends StatefulWidget, C> extends State<T> {
  C get controller => Get.find<C>();
}
