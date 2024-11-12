import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:gymtracker/controller/boutique_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/boutique.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/skeletons.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/components/master_detail.dart';
import 'package:gymtracker/view/components/routines.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';

const defaultIcon = GTIcons.boutique;

class BoutiqueView extends StatefulWidget {
  const BoutiqueView({super.key});

  @override
  State<BoutiqueView> createState() => _BoutiqueViewState();
}

class _BoutiqueViewState
    extends ControlledState<BoutiqueView, BoutiqueController> {
  BoutiqueApiResponse<List<BoutiqueCategory>>? _categories;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future _refresh() async {
    setState(() {
      _categories = controller.getCategories();
    });
    return _categories;
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar.large(
          title: Text("boutique.title".t),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            FutureBuilder<
                BoutiqueResponse<List<BoutiqueCategory>, BoutiqueError>>(
              future: _categories,
              builder: (context, snapshot) {
                if (snapshot.error != null || snapshot.data?.isError == true) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "boutique.errors.${snapshot.data!.error?.name ?? "unknown"}"
                              .t,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                final isLoading =
                    snapshot.connectionState != ConnectionState.done ||
                        !snapshot.hasData;
                final data = isLoading
                    ? List.generate(5,
                        (index) => skeletonBoutiqueCategory(0x1989 + 3 * index))
                    : snapshot.data!.success!
                        .where((e) => !e.isHidden)
                        .toList();
                return SliverList.builder(
                  itemBuilder: (context, index) {
                    final category = data[index];
                    return Skeletonizer(
                      enabled: isLoading,
                      child: BoutiqueCategoryCard(
                        category: category,
                        enabled: !isLoading,
                      ),
                    );
                  },
                  itemCount: data.length,
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverBottomSafeArea(),
          ],
        ),
      ),
    );
  }
}

class BoutiqueCategoryCard extends StatelessWidget {
  final BoutiqueCategory category;
  final bool enabled;

  const BoutiqueCategoryCard({
    super.key,
    required this.category,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final background = !enabled || category.color == null
        ? null
        : getContainerColor(context, category.color!);
    final foreground = !enabled || category.color == null
        ? null
        : getOnContainerColor(context, category.color!);
    final icon = category.icon != null
        ? GTIcons.values[category.icon!] ?? defaultIcon
        : defaultIcon;
    return SafeArea(
      top: false,
      bottom: false,
      child: Card.outlined(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: background,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled
              ? () {
                  Go.to(() => BoutiqueCategoryView(category: category));
                }
              : null,
          child: Stack(
            children: [
              Positioned.directional(
                textDirection: Directionality.of(context),
                end: 36,
                bottom: 24,
                child: Skeleton.ignore(
                  child: Transform.scale(
                    scale: 6,
                    child: Opacity(
                      opacity: 0.1,
                      child: Transform.rotate(
                        angle: -math.pi / 4.5,
                        child: Icon(icon, color: foreground),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        getName(context),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: foreground),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(icon, color: foreground, size: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return category.name[locale.languageCode] ?? category.name['en'] ?? '';
  }
}

class BoutiqueCategoryView extends StatefulWidget {
  final BoutiqueCategory category;

  const BoutiqueCategoryView({
    required this.category,
    super.key,
  });

  @override
  State<BoutiqueCategoryView> createState() => _BoutiqueCategoryViewState();
}

class _BoutiqueCategoryViewState
    extends ControlledState<BoutiqueCategoryView, BoutiqueController> {
  BoutiqueApiResponse<List<BoutiquePackage>>? _packages;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future _refresh() async {
    setState(() {
      _packages = controller.getPackages(
        widget.category.id,
        language: Get.context!.locale.languageCode,
      );
    });
    return _packages;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
        BoutiqueResponse<List<BoutiquePackage>, BoutiqueError>>(
      future: _packages,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.success != null) {
          return _buildLoaded(context, snapshot.data!.success!);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.category.name[context.locale.languageCode] ??
                widget.category.name['en'] ??
                ''),
          ),
          body: () {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.isError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "boutique.errors.${snapshot.data!.error?.name ?? "unknown"}"
                        .t,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return const SizedBox();
          }(),
        );
      },
    );
  }

  Widget _buildLoaded(BuildContext context, List<BoutiquePackage> data) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: MasterDetailView(
        appBarTitle: Text(widget.category.name[context.locale.languageCode] ??
            widget.category.name['en'] ??
            ''),
        appBarActions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.code),
              onPressed: () => controller.routineConverter(widget.category.id),
            ),
        ],
        items: [
          for (final package in data)
            MasterItem(
              Text(package.name),
              id: package.id,
              subtitle: Text.rich(TextSpan(children: [
                TextSpan(text: "${package.description}\n"),
                TextSpan(
                  text: "general.routines".plural(package.routines.length),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ])),
              detailsBuilder: (context) => DetailsView(
                child: BoutiquePackageView(package: package),
              ),
            ),
        ],
      ),
    );
  }
}

class BoutiquePackageView extends StatelessWidget {
  final BoutiquePackage package;

  const BoutiquePackageView({
    required this.package,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isEmpty = package.routines.isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(package.name),
        automaticallyImplyLeading: false,
        leading: MDVConfiguration.of(context)?.selfPage ?? true
            ? IconButton(
                icon: const BackButtonIcon(),
                onPressed: () {
                  MDVConfiguration.of(context)!.goBack?.call();
                },
              )
            : null,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(package.description),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: FilledButton(
                onPressed: isEmpty
                    ? null
                    : () {
                        Get.find<BoutiqueController>().install(package);
                      },
                child: Text("boutique.package.install".t),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverList.builder(
            itemBuilder: (context, index) {
              final routine = package.routines[index];
              return RoutineListTile(
                routine: routine,
                onTap: () {
                  Go.to(() => Scaffold(
                        body: RoutinePreview(
                          routine: routine,
                          automaticallyImplyLeading: true,
                        ),
                      ));
                },
              );
            },
            itemCount: package.routines.length,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverBottomSafeArea(),
        ],
      ),
    );
  }
}
