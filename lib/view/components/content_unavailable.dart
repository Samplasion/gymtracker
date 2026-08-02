import 'package:flutter/material.dart';

class ContentUnavailableView extends StatelessWidget {
  const ContentUnavailableView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final Widget icon;
  final Widget title;
  final Widget description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconTheme.merge(data: IconThemeData(size: 64), child: icon),
          const SizedBox(height: 16),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.titleLarge!,
            textAlign: TextAlign.center,
            child: title,
          ),
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color?.withAlpha(179),
            ),
            textAlign: TextAlign.center,
            child: description,
          ),
        ],
      ),
    );
  }
}
