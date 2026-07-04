import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gymtracker/model/exercise.dart';

class EquipmentIcon extends StatelessWidget {
  final GTGymEquipment equipment;
  final Color? color;
  final double size;

  const EquipmentIcon({
    super.key,
    required this.equipment,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final key = "assets/svg/equipment/${equipment.name}.svg";
    return SvgPicture.asset(
      key,
      width: size,
      height: size,
      color: color ?? IconTheme.of(context).color,
    );
  }
}
