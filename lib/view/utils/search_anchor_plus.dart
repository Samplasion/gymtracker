import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef SearchSuggestionBuilder = FutureOr<Iterable<Widget>> Function(
    BuildContext context, SearchController searchController);

class SearchAnchorPlus extends StatefulWidget {
  final SearchSuggestionBuilder suggestionsBuilder;
  final SearchController? searchController;
  final List<Widget> barTrailing;
  final String? hintText;
  final void Function(String)? onSubmitted;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final Widget? viewFloatingActionButton;

  const SearchAnchorPlus({
    super.key,
    required this.suggestionsBuilder,
    this.searchController,
    this.barTrailing = const [],
    this.hintText,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction = TextInputAction.search,
    this.keyboardType = TextInputType.text,
    this.viewFloatingActionButton,
  });

  @override
  State<SearchAnchorPlus> createState() => _SearchAnchorPlusState();
}

class _SearchAnchorPlusState extends State<SearchAnchorPlus> {
  late SearchController searchController =
      widget.searchController ?? SearchController();

  @override
  void didUpdateWidget(covariant SearchAnchorPlus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchController != widget.searchController) {
      if (oldWidget.searchController == null &&
          widget.searchController != null) {
        searchController = widget.searchController!;
      } else if (oldWidget.searchController != null &&
          widget.searchController == null) {
        searchController = SearchController();
      } else {
        searchController = widget.searchController ?? SearchController();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedColor: Colors.transparent,
      middleColor: Colors.transparent,
      openColor: Colors.transparent,
      closedElevation: 0,
      openElevation: 0,
      clipBehavior: Clip.none,
      openBuilder: (context, close) {
        return _SearchAnchorViewPlus(
          searchController: searchController,
          suggestionsBuilder: widget.suggestionsBuilder,
          viewHintText: widget.hintText,
          closeView: close,
          onSubmitted: (query) {
            close();
            SchedulerBinding.instance.addPostFrameCallback((_) {
              widget.onSubmitted?.call(query);
            });
          },
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          keyboardType: widget.keyboardType,
          floatingActionButton: widget.viewFloatingActionButton,
        );
      },
      closedBuilder: (context, open) {
        return SearchBar(
          controller: searchController,
          hintText: widget.hintText,
          trailing: widget.barTrailing,
          onChanged: (query) {
            open();
          },
          onTap: () {
            open();
          },
          onSubmitted: (query) =>
              SchedulerBinding.instance.addPostFrameCallback((_) {
            widget.onSubmitted?.call(query);
          }),
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          keyboardType: widget.keyboardType,
        );
      },
    );
  }
}

class _SearchAnchorViewPlus extends StatefulWidget {
  final SearchController searchController;
  final SearchSuggestionBuilder suggestionsBuilder;
  final void Function() closeView;
  final String? viewHintText;
  final void Function(String)? onSubmitted;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final Widget? floatingActionButton;

  const _SearchAnchorViewPlus({
    required this.searchController,
    required this.suggestionsBuilder,
    required this.closeView,
    this.viewHintText,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction = TextInputAction.search,
    this.keyboardType = TextInputType.text,
    this.floatingActionButton,
  });

  @override
  State<_SearchAnchorViewPlus> createState() => _SearchAnchorViewPlusState();
}

class _SearchAnchorViewPlusState extends State<_SearchAnchorViewPlus> {
  Iterable<Widget> searchResults = [];
  final _focusNode = FocusNode();

  @override
  initState() {
    super.initState();
    widget.searchController.addListener(onType);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      onType();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.searchController.removeListener(onType);
    super.dispose();
  }

  @override
  void didUpdateWidget(_SearchAnchorViewPlus oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.searchController != widget.searchController) {
      oldWidget.searchController.removeListener(onType);
      widget.searchController.addListener(onType);
    }
  }

  void onType() {
    Future.microtask(() {
      return widget.suggestionsBuilder(context, widget.searchController);
    }).then((value) {
      searchResults = value;
      if (mounted) setState(() {});
    });
  }

  Widget _innerView() {
    return ListView(
      key: ValueKey(widget.searchController.text),
      children: searchResults.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget defaultLeading = IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );

    final List<Widget> defaultTrailing = <Widget>[
      if (widget.searchController.text.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
          onPressed: () {
            widget.searchController.clear();
          },
        ),
    ];

    final SearchViewThemeData viewTheme = SearchViewTheme.of(context);
    final DividerThemeData dividerTheme = DividerTheme.of(context);

    final TextStyle? effectiveTextStyle = viewTheme.headerTextStyle;
    final TextStyle? effectiveHintStyle =
        viewTheme.headerHintStyle ?? viewTheme.headerTextStyle;
    final Color? effectiveDividerColor =
        viewTheme.dividerColor ?? dividerTheme.color;
    final Widget viewDivider = DividerTheme(
      data: dividerTheme.copyWith(color: effectiveDividerColor),
      child: const Divider(height: 1),
    );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SafeArea(
            // top: false,
            bottom: false,
            child: SearchBar(
              autoFocus: true,
              focusNode: _focusNode,
              leading: defaultLeading,
              trailing: defaultTrailing,
              hintText: widget.viewHintText,
              backgroundColor:
                  const WidgetStatePropertyAll<Color>(Colors.transparent),
              overlayColor:
                  const WidgetStatePropertyAll<Color>(Colors.transparent),
              elevation: const WidgetStatePropertyAll<double>(0.0),
              textStyle: WidgetStatePropertyAll<TextStyle?>(effectiveTextStyle),
              hintStyle: WidgetStatePropertyAll<TextStyle?>(effectiveHintStyle),
              controller: widget.searchController,
              onChanged: (String value) {
                onType();
              },
              onSubmitted: widget.onSubmitted,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.textInputAction,
              keyboardType: widget.keyboardType,
            ),
          ),
          viewDivider,
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Builder(builder: (context) {
                final padding = MediaQuery.of(context).padding;
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    padding: padding.copyWith(
                      bottom: widget.floatingActionButton != null
                          ? kFloatingActionButtonMargin + 56
                          : 0,
                    ),
                  ),
                  child: _innerView(),
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
