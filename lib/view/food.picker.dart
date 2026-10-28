part of 'food.dart';

Future<void> showFoodPicker(
  BuildContext context,
  WidgetRef ref, {
  NutritionCategory? category,
}) async {
  final date = ref.read(foodSelectedDateProvider);
  await Go.to(
    () => FoodPickerView(
      onAdd: (food) => ref
          .read(foodProvider.notifier)
          .addFood(date, food, category: category),
      onRemove: (food) =>
          ref.read(foodProvider.notifier).removeFood(date, food),
    ),
  );
}

/// The same session UI can write diary entries or composition ingredients.
class FoodPickerView extends ConsumerStatefulWidget {
  const FoodPickerView({
    super.key,
    required this.onAdd,
    required this.onRemove,
    this.allowCombine = true,
  });
  final Future<Food> Function(Food) onAdd;
  final Future<void> Function(Food) onRemove;
  final bool allowCombine;

  @override
  ConsumerState<FoodPickerView> createState() => _FoodPickerViewState();
}

class _FoodPickerViewState extends ConsumerState<FoodPickerView> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final _added = <Food>[];
  Timer? _debounce;
  String _query = '';
  bool _busy = false;
  List<Food>? _recentFoods;
  bool _showAllCatalog = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _searchNow() {
    _debounce?.cancel();
    final query = _search.text.trim();
    if (query != _query) {
      setState(() {
        _query = query;
        _showAllCatalog = false;
      });
    }
  }

  Future<void> _add(VagueFood source, {bool details = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final food = details
          ? await showAddFoodView(
              context,
              source,
              inheritAmount: source is Food,
            )
          : source is Food
          ? source
          : Food(
              name: source.name,
              brand: source.brand,
              barcode: source.barcode,
              unit: source.unit,
              servingSizes: source.servingSizes,
              nutritionalValuesPer100g: source.nutritionalValuesPer100g,
              downloadedFromOFF: source.downloadedFromOFF,
              origin: source is CatalogFood ? 'catalog' : null,
              catalogId: source is CatalogFood ? source.catalogId : null,
              amount: source.servingSizes.firstOrNull?.amount ?? 100,
            );
      if (food == null || !mounted) return;
      final saved = await widget.onAdd(food);
      if (!mounted) return;
      setState(() => _added.add(saved));
      _notice(context.t.food.picker.addedNotice);
    } catch (_) {
      if (mounted) _notice(context.t.food.picker.failed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notice(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _scan({bool custom = false}) async {
    if (_busy) return;
    final code = await Go.to<String>(() => const FoodBarcodeReaderView());
    if (code == null || !mounted) return;
    final food = custom
        ? await showAddCustomFoodView(context, ref, barcode: code)
        : await searchFoodByBarcode(context, ref, code);
    if (food != null && mounted) await _add(food);
  }

  Future<void> _more() async {
    final strings = context.t.food.picker;
    final action = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(strings.withoutBarcode),
              onTap: () => Navigator.pop(context, 0),
            ),
            ListTile(
              leading: const Icon(GTIcons.scan_barcode),
              title: Text(strings.withBarcode),
              onTap: () => Navigator.pop(context, 1),
            ),
            if (widget.allowCombine)
              ListTile(
                leading: const Icon(GTIcons.combine),
                title: Text(context.t.food.combine.title),
                onTap: () => Navigator.pop(context, 2),
              ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    if (action == 1) {
      await _scan(custom: true);
      return;
    }
    final food = action == 0
        ? await showAddCustomFoodView(context, ref)
        : await showCombineFoodsView(context, ref);
    if (food != null && mounted) await _add(food);
  }

  Future<void> _showAdded() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${context.t.food.picker.added} (${_added.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (_added.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(context.t.food.picker.noAdded),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _added.length,
                    itemBuilder: (context, index) {
                      final food = _added[index];
                      return ListTile(
                        title: Text(food.name),
                        subtitle: Text(_summary(food)),
                        trailing: IconButton(
                          tooltip: context.t.actions.remove,
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _busy
                              ? null
                              : () async {
                                  setState(() => _busy = true);
                                  update(() {});
                                  try {
                                    await widget.onRemove(food);
                                    if (mounted) {
                                      setState(() => _added.remove(food));
                                    }
                                  } catch (_) {
                                    if (mounted) {
                                      _notice(
                                        this.context.t.food.picker.failed,
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _busy = false);
                                    if (context.mounted) update(() {});
                                  }
                                },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _summary(Food food) => [
    if (food.brand?.isNotEmpty == true) food.brand!,
    food.unit.formatAmount(food.amount, pieces: food.pieces, context: context),
    NutritionUnit.KCAL.formatAmount(
      food.nutritionalValues.calories,
      context: context,
    ),
  ].join(' · ');

  Widget _rows(List<VagueFood> foods) => M3ECardList(
    padding: EdgeInsets.zero,
    itemCount: foods.length,
    itemBuilder: (context, index) {
      final food = foods[index];
      final portion = food is Food
          ? food
          : Food(
              name: food.name,
              brand: food.brand,
              unit: food.unit,
              amount: food.servingSizes.firstOrNull?.amount ?? 100,
              nutritionalValuesPer100g: food.nutritionalValuesPer100g,
            );
      return ListTile(
        dense: true,
        title: Text(food.name),
        subtitle: Text(_summary(portion)),
        onTap: _busy ? null : () => _add(food, details: true),
        trailing: IconButton.filledTonal(
          tooltip: '${context.t.food.picker.title}: ${food.name}',
          onPressed: _busy ? null : () => _add(food),
          icon: const Icon(Icons.add),
        ),
      );
    },
  );

  Widget _modeAction(
    String label,
    IconData icon,
    VoidCallback action, {
    bool selected = false,
  }) {
    final textHeight = MediaQuery.textScalerOf(context).scale(14);
    return Expanded(
      child: Semantics(
        selected: selected,
        child: M3EButton(
          onPressed: _busy ? null : action,
          style: selected ? M3EButtonStyle.filled : M3EButtonStyle.tonal,
          size: M3EButtonSize.custom(
            height: 82 + math.max(0, textHeight - 14) * 2.4,
            hPadding: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.t.food.picker;
    final history = ref.watch(foodLogsStreamProvider).asData;
    // Freeze the session's history after its first successful load. Diary writes
    // must not move the row the user is about to tap or change its last portion.
    if (_recentFoods == null && history != null) {
      final recent = <Food>[];
      for (final entry in history.value.reversed) {
        final food = entry.value;
        if (!recent.any(
          (f) => f
              .copyWith(amount: 100, id: '')
              .equalsForSearch(food.copyWith(amount: 100, id: '')),
        )) {
          recent.add(food);
        }
      }
      _recentFoods = recent;
    }
    final tokens = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty);
    final matches = (_recentFoods ?? <Food>[])
        .where((food) {
          final text = '${food.name} ${food.brand ?? ''}'.toLowerCase();
          return tokens.every(text.contains);
        })
        .take(20)
        .toList();
    final results = _query.isEmpty
        ? null
        : ref.watch(searchFoodCatalogProvider(_query));
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 8,
          title: TextButton.icon(
            onPressed: _busy ? null : _showAdded,
            icon: Badge(
              label: Text('${_added.length}'),
              child: const Icon(Icons.playlist_add_check),
            ),
            label: Text(strings.added),
          ),
          actions: [
            IconButton(
              tooltip: strings.done,
              onPressed: _busy ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    _modeAction(
                      strings.search,
                      Icons.search,
                      () => FocusScope.of(context).requestFocus(_searchFocus),
                      selected: true,
                    ),
                    const SizedBox(width: 8),
                    _modeAction(strings.barcode, GTIcons.scan_barcode, _scan),
                    const SizedBox(width: 8),
                    _modeAction(strings.more, Icons.more_horiz, _more),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchBar(
                  elevation: const WidgetStatePropertyAll(0),
                  controller: _search,
                  focusNode: _searchFocus,
                  leading: const Icon(Icons.search),
                  hintText: context.t.food.searchBar.hint,
                  onChanged: (_) {
                    _debounce?.cancel();
                    _debounce = Timer(
                      const Duration(milliseconds: 300),
                      _searchNow,
                    );
                  },
                  onSubmitted: (_) => _searchNow(),
                  trailing: [
                    if (_search.text.isNotEmpty)
                      IconButton(
                        tooltip: context.t.food.picker.search,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          _searchNow();
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Keep the list in the same slot and at the same position while
              // saving: inserting a sibling here used to remount its subtree.
              SizedBox(
                height: 4,
                child: _busy ? const LinearProgressIndicator() : null,
              ),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    if (results != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          strings.results,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      results.when(
                        skipLoadingOnRefresh: false,
                        data: (foods) => foods.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(strings.empty),
                              )
                            : Column(
                                children: [
                                  _rows(
                                    _showAllCatalog
                                        ? foods
                                        : foods.take(10).toList(),
                                  ),
                                  if (!_showAllCatalog && foods.length > 10)
                                    TextButton(
                                      onPressed: () => setState(
                                        () => _showAllCatalog = true,
                                      ),
                                      child: Text(strings.showMore),
                                    ),
                                  if (_showAllCatalog && foods.length == 50)
                                    ref
                                        .watch(
                                          remainingFoodCatalogProvider(_query),
                                        )
                                        .when(
                                          data: (rest) => _rows(rest),
                                          loading: () => const Center(
                                            child: GBLoadingIndicator(),
                                          ),
                                          error: (_, _) => TextButton(
                                            onPressed: () => ref.invalidate(
                                              remainingFoodCatalogProvider(
                                                _query,
                                              ),
                                            ),
                                            child: Text(strings.retry),
                                          ),
                                        ),
                                ],
                              ),
                        loading: () =>
                            const Center(child: GBLoadingIndicator()),
                        error: (_, _) => Column(
                          children: [
                            Text(strings.failed),
                            TextButton(
                              onPressed: () => ref.invalidate(
                                searchFoodCatalogProvider(_query),
                              ),
                              child: Text(strings.retry),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (matches.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          strings.recent,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _rows(matches),
                    ] else if (_query.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(context.t.food.searchBar.noHistory),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.all(16),
          child: M3EButton(
            onPressed: _busy ? null : () => Navigator.pop(context),
            size: M3EButtonSize.md,
            child: Text(strings.done),
          ),
        ),
      ),
    );
  }

  final _searchFocus = FocusNode();
}
