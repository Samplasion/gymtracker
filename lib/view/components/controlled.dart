import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef ControlledWidget<T extends GetLifeCycleBase?> = GetWidget<T>;

abstract class ControlledState<T extends StatefulWidget,
    C extends GetLifeCycleBase?> extends State<T> {
  C get controller => Get.find<C>();
}
