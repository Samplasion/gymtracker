import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gymtracker/model/exercise.dart';

class EquipmentIcon extends StatelessWidget {
  final GTGymEquipment equipment;
  final Color? color;

  const EquipmentIcon({
    Key? key,
    required this.equipment,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = "assets/svg/equipment/${equipment.name}.svg";
    return SvgPicture.asset(
      key,
      width: 24,
      height: 24,
      color: color ?? IconTheme.of(context).color,
    );
  }
}
