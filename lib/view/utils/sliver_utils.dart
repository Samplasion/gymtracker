import 'package:flutter/material.dart';

class SliverBottomSafeArea extends StatelessWidget {
  const SliverBottomSafeArea({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(height: MediaQuery.of(context).padding.bottom),
    );
  }
}
