import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/enums.dart';
import '../../models/property_filter.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_chip.dart';

/// Bottom sheet for property facet filters. Returns the assembled
/// [PropertyFilter] via `Navigator.pop`, preserving the caller's search term,
/// sort and status.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial});

  final PropertyFilter initial;

  static Future<PropertyFilter?> show(
    BuildContext context,
    PropertyFilter initial,
  ) {
    return showModalBottomSheet<PropertyFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterSheet(initial: initial),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  ContractType? _contract;
  PropertyType? _propertyType;
  int? _minBedrooms;
  late final TextEditingController _minPrice;
  late final TextEditingController _maxPrice;
  late final TextEditingController _city;
  late final TextEditingController _district;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _contract = f.contractType;
    _propertyType = f.propertyType;
    _minBedrooms = f.minBedrooms;
    _minPrice = TextEditingController(text: _numText(f.minPrice));
    _maxPrice = TextEditingController(text: _numText(f.maxPrice));
    _city = TextEditingController(text: f.city ?? '');
    _district = TextEditingController(text: f.district ?? '');
  }

  @override
  void dispose() {
    _minPrice.dispose();
    _maxPrice.dispose();
    _city.dispose();
    _district.dispose();
    super.dispose();
  }

  static String _numText(double? v) {
    if (v == null) return '';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  double? _parseDouble(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  void _reset() {
    setState(() {
      _contract = null;
      _propertyType = null;
      _minBedrooms = null;
      _minPrice.clear();
      _maxPrice.clear();
      _city.clear();
      _district.clear();
    });
  }

  void _apply() {
    final result = widget.initial.copyWith(
      pageNumber: 1,
      contractType: () => _contract,
      propertyType: () => _propertyType,
      minBedrooms: () => _minBedrooms,
      minPrice: () => _parseDouble(_minPrice.text),
      maxPrice: () => _parseDouble(_maxPrice.text),
      city: () => _text(_city),
      district: () => _text(_district),
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        S.filters,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text(S.resetFilters),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      _label(context, S.contractType),
                      _chipsRow([
                        AppChoiceChip(
                          label: S.all,
                          selected: _contract == null,
                          onTap: () => setState(() => _contract = null),
                        ),
                        for (final t in ContractType.values)
                          AppChoiceChip(
                            label: t.label,
                            selected: _contract == t,
                            onTap: () => setState(() => _contract = t),
                          ),
                      ]),
                      const SizedBox(height: 20),
                      _label(context, S.propertyType),
                      _chipsRow([
                        AppChoiceChip(
                          label: S.all,
                          selected: _propertyType == null,
                          onTap: () => setState(() => _propertyType = null),
                        ),
                        for (final t in PropertyType.values)
                          AppChoiceChip(
                            label: t.label,
                            icon: t.icon,
                            selected: _propertyType == t,
                            onTap: () => setState(() => _propertyType = t),
                          ),
                      ]),
                      const SizedBox(height: 20),
                      _label(context, S.bedrooms),
                      _chipsRow([
                        AppChoiceChip(
                          label: S.all,
                          selected: _minBedrooms == null,
                          onTap: () => setState(() => _minBedrooms = null),
                        ),
                        for (final n in const [1, 2, 3, 4, 5])
                          AppChoiceChip(
                            label: n == 5 ? '+5' : '$n',
                            selected: _minBedrooms == n,
                            onTap: () => setState(() => _minBedrooms = n),
                          ),
                      ]),
                      const SizedBox(height: 20),
                      _label(context, S.priceRange),
                      Row(
                        children: [
                          Expanded(
                            child: _priceField(_minPrice, 'من'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _priceField(_maxPrice, 'إلى'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _label(context, S.city),
                      TextField(
                        controller: _city,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: S.city),
                      ),
                      const SizedBox(height: 16),
                      _label(context, S.district),
                      TextField(
                        controller: _district,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(hintText: S.district),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: AppButton(
                      label: S.filterResults,
                      icon: Icons.tune_rounded,
                      onPressed: _apply,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      );

  Widget _chipsRow(List<Widget> chips) =>
      Wrap(spacing: 8, runSpacing: 8, children: chips);

  Widget _priceField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(
        hintText: hint,
        suffixText: S.currency,
      ),
    );
  }
}
