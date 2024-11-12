/// Adapted from https://github.com/2-5-perceivers/flutter-master-detail-flow
///
/// MIT License
///
/// Copyright (c) 2022 2.5 Perceivers
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
library;

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';

typedef DetailsBuilder = Widget Function(BuildContext context);

enum MDVFocus {
  /// Focus on the master
  master,

  /// Focus on details
  details,
}

class MDVConfiguration extends InheritedWidget {
  /// Creates a Flow Settings to be used by a details item. If selfPage is true
  /// goBack must be specified.
  const MDVConfiguration({
    required super.child,
    // required this.appBarSize,
    this.selfPage = false,
    this.goBack,
    super.key,
  }) : assert(
          selfPage == (goBack != null),
          'goBack must be specified only when selfPage is true',
        );

  /// If details is a page by itself. Is false if the details should be showed
  /// in lateral view.
  final bool selfPage;

  /// The function that would move the focus back to master in a selfPage scenario.
  final void Function()? goBack;

  /// The selected app bar type
  // final DetailsAppBarSize appBarSize;

  /// Obtains the settings to be used by a details item or one of it's ancestors.
  static MDVConfiguration? of(BuildContext context) {
    final MDVConfiguration? result =
        context.dependOnInheritedWidgetOfExactType<MDVConfiguration>();
    return result;
  }

  static Widget? backButtonOf(BuildContext context) {
    return of(context)?.selfPage == true
        ? IconButton(
            icon: const BackButtonIcon(),
            onPressed: MDVConfiguration.of(context)?.goBack,
          )
        : null;
  }

  @override
  bool updateShouldNotify(MDVConfiguration oldWidget) {
    return selfPage != oldWidget.selfPage;
  }

  void push(
    BuildContext context,
    Widget widget, {
    String? id,
  }) {
    MasterDetailView._push(
      context,
      MasterItem(
        Container(),
        detailsBuilder: (_) => widget,
        id: id,
      ),
    );
  }
}

class MasterDetailView extends StatefulWidget {
  final Breakpoints breakpoint;
  final double masterWidth;
  final Widget? appBarTitle;
  final List<Widget> appBarActions;
  final Widget? leading;
  final List items;
  final Widget? nothingSelectedWidget;
  final Duration transitionAnimationDuration;
  final double detailsPanelCornersRadius;

  const MasterDetailView({
    this.breakpoint = Breakpoints.l,
    this.masterWidth = 320,
    this.appBarTitle,
    this.appBarActions = const [],
    this.leading,
    this.items = const [],
    this.nothingSelectedWidget,
    this.transitionAnimationDuration = const Duration(milliseconds: 500),
    this.detailsPanelCornersRadius = 16,
    super.key,
  });

  static void _push(BuildContext context, MasterItem item) {
    _MasterDetailViewState state =
        context.findAncestorStateOfType<_MasterDetailViewState>()!;
    state._push(item);
  }

  @override
  State<MasterDetailView> createState() => _MasterDetailViewState();
}

class _MasterDetailViewState extends State<MasterDetailView> {
  MDVFocus focus = MDVFocus.master;
  MasterItem? selectedItem;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) =>
          buildView(context, Breakpoints.computeBreakpoint(size.maxWidth)),
    );
  }

  Widget buildView(BuildContext context, Breakpoints breakpoint) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final bool large = breakpoint >= widget.breakpoint;

    if (large) {
      return Scaffold(
        appBar: AppBar(
          title: widget.appBarTitle,
          leading: widget.leading,
          actions: widget.appBarActions,
          notificationPredicate: (notification) {
            return focus == MDVFocus.master;
          },
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                maxWidth: widget.masterWidth,
              ),
              child: ListTileTheme(
                data: ListTileThemeData(
                  selectedColor: colorScheme.onSecondaryContainer,
                  selectedTileColor: colorScheme.secondaryContainer,
                  iconColor: colorScheme.onSurfaceVariant,
                  textColor: colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  contentPadding: const EdgeInsetsDirectional.only(
                    start: 16,
                    end: 24,
                  ),
                ),
                style: ListTileStyle.drawer,
                child: DividerTheme(
                  data: const DividerThemeData(
                    indent: 32,
                    endIndent: 32,
                  ),
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      if (index == widget.items.length) {
                        return Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).padding.bottom,
                            ),
                            if (kDebugMode) ...[
                              Text("${selectedItem?.id}"),
                            ],
                          ],
                        );
                      }
                      final MasterItemBase itemBase = widget.items[index];
                      if (itemBase is Widget) {
                        return itemBase as Widget;
                      }
                      final MasterItem item = itemBase as MasterItem;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              theme.listTileTheme.contentPadding?.horizontal ??
                                  16,
                          vertical: 2,
                        ),
                        child: _listTileBuilder(item),
                      );
                    },
                    itemCount: widget.items.length + 1,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SafeArea(
                left: false,
                top: false,
                bottom: false,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    padding: MediaQuery.of(context).padding.copyWith(
                          left: 0,
                          right: 0,
                        ),
                  ),
                  child: AnimatedSwitcher(
                    duration: widget.transitionAnimationDuration,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) =>
                            const FadeUpwardsPageTransitionsBuilder()
                                .buildTransitions<void>(
                      null,
                      null,
                      animation,
                      null,
                      child,
                    ),
                    child: Padding(
                      key: _getKey(),
                      padding: const EdgeInsetsDirectional.only(
                        end: 12,
                      ),
                      child: Material(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                                widget.detailsPanelCornersRadius),
                          ),
                        ),
                        color: ElevationOverlay.applySurfaceTint(
                          colorScheme.surface,
                          colorScheme.surfaceTint,
                          selectedItem == null ? 0 : 1,
                        ),
                        elevation: selectedItem == null ? 0 : 10,
                        clipBehavior: Clip.antiAlias,
                        child: MDVConfiguration(
                          selfPage: false,
                          child: selectedItem?.detailsBuilder?.call(context) ??
                              Center(
                                child: widget.nothingSelectedWidget ??
                                    const SizedBox(),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return ClipRect(
        clipBehavior: Clip.hardEdge,
        child: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 500),
          reverse: focus == MDVFocus.master,
          transitionBuilder: (
            Widget child,
            Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation,
          ) {
            return SharedAxisTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              fillColor: Theme.of(context).colorScheme.surface,
              child: child,
            );
          },
          child: focus == MDVFocus.details && selectedItem != null
              ? MDVConfiguration(
                  key: ValueKey<MDVFocus>(focus),
                  selfPage: true,
                  goBack: () {
                    if (mounted) {
                      setState(() {
                        focus = MDVFocus.master;
                        selectedItem = null;
                      });
                    }
                  },
                  child: Scaffold(
                    body: selectedItem!.detailsBuilder!(context),
                  ),
                )
              : Scaffold(
                  key: _getKey(),
                  body: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar.large(
                        title: widget.appBarTitle,
                        leading: widget.leading,
                        actions: widget.appBarActions,
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final MasterItemBase itemBase = widget.items[index];
                            if (itemBase is Widget) {
                              return itemBase as Widget;
                            }
                            final MasterItem item = itemBase as MasterItem;
                            return _listTileBuilder(item, page: true);
                          },
                          childCount: widget.items.length,
                        ),
                      ),
                      const SliverBottomSafeArea(),
                    ],
                  ),
                ),
        ),
      );
    }
  }

  ValueKey _getKey() {
    if (selectedItem?.id != null) {
      return ValueKey<String>(selectedItem!.id!);
    }
    return ValueKey<MasterItem?>(selectedItem);
  }

  Widget _listTileBuilder(MasterItem item, {bool page = false}) {
    return ListTile(
      title: item.title,
      subtitle: item.subtitle,
      leading: item.leading,
      trailing: item.trailing,
      selected: item.id == null
          ? (selectedItem == item)
          : (selectedItem?.id == item.id),
      onTap: () {
        if (item.onTap != null) {
          item.onTap!();
        } else {
          _push(item);
        }
      },
    );
  }

  _push(MasterItem item) {
    if (mounted) {
      setState(() {
        focus = MDVFocus.details;
        selectedItem = item;
      });
    }
  }
}

class MasterItemBase {
  const MasterItemBase();
}

class MasterItemWidget extends StatelessWidget implements MasterItemBase {
  const MasterItemWidget({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class MasterItemDivider extends MasterItemWidget {
  const MasterItemDivider({super.key}) : super(child: const Divider());
}

class MasterItem extends MasterItemBase {
  const MasterItem(
    this.title, {
    this.detailsBuilder,
    this.subtitle,
    this.onTap,
    this.leading,
    this.trailing,
    this.id,
  }) : assert(
          detailsBuilder != null || onTap != null,
          'You need to specify at least one of detailsBuilder or onTap.',
        );

  /// The title showed in the list tile
  final Widget title;

  /// The optional subtitle showed in the list tile
  final Widget? subtitle;

  /// [ListTile.leading] and [ListTile.trailing] corespondents
  final Widget? leading, trailing;

  /// A builder functions that constructs a details page. The details page
  /// should use [MasterDetailsFlowSettings] to adapt and function.
  ///
  /// See:
  ///   * [DetailsItem]
  final DetailsBuilder? detailsBuilder;

  /// An override for the onTap callback so the list tile doesn't open a details
  /// page.
  final GestureTapCallback? onTap;

  /// Used to highlight the current item.
  final String? id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MasterItem &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.leading == leading &&
        other.trailing == trailing;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        subtitle.hashCode ^
        leading.hashCode ^
        trailing.hashCode;
  }
}

class DetailsView extends StatelessWidget {
  final Widget child;

  const DetailsView({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final MDVConfiguration? settings = MDVConfiguration.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    var canvasColor = _getCanvasColor(settings, colorScheme);
    return Material(
      color: canvasColor,
      child: Theme(
        data: theme.copyWith(
          appBarTheme: theme.appBarTheme.copyWith(
            backgroundColor: canvasColor,
          ),
          scaffoldBackgroundColor: canvasColor,
          colorScheme: colorScheme.copyWith(
            surface: canvasColor,
          ),
        ),
        child: child,
      ),
    );
  }
}

Color _getCanvasColor(MDVConfiguration? settings, ColorScheme colorScheme) {
  if (settings?.selfPage ?? true) return colorScheme.surface;
  return colorScheme.surfaceContainerLow;
}

class CustomPageRouteBuilder<T> extends PageRoute<T> {
  final Widget Function(BuildContext context, PageRoute<T> pr) pageBuilder;

  CustomPageRouteBuilder({required this.pageBuilder});

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return pageBuilder(context, this);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 900);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Theme.of(context).pageTransitionsTheme.buildTransitions(
          this,
          context,
          animation,
          secondaryAnimation,
          child,
        );
  }
}
