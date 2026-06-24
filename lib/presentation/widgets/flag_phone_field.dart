import 'package:aneuso_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/helpers.dart';
import 'package:intl_phone_field/phone_number.dart';

/// Phone field that always shows country flag images (PNG), including on Windows.
class FlagPhoneField extends StatefulWidget {
  const FlagPhoneField({
    super.key,
    this.initialCountryCode = 'PK',
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.style,
    this.dropdownTextStyle,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  final String? initialCountryCode;
  final String? initialValue;
  final InputDecoration decoration;
  final TextStyle? style;
  final TextStyle? dropdownTextStyle;
  final void Function(PhoneNumber phone)? onChanged;
  final String? Function(PhoneNumber? phone)? validator;
  final bool enabled;

  @override
  State<FlagPhoneField> createState() => _FlagPhoneFieldState();
}

class _FlagPhoneFieldState extends State<FlagPhoneField> {
  late Country _selectedCountry;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selectedCountry = countries.firstWhere(
      (c) => c.code == widget.initialCountryCode,
      orElse: () => countries.firstWhere((c) => c.code == 'PK'),
    );

    String initialNumber = '';
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      try {
        final parsed = PhoneNumber.fromCompleteNumber(completeNumber: widget.initialValue!);
        if (parsed.countryISOCode.isNotEmpty) {
          _selectedCountry = countries.firstWhere((c) => c.code == parsed.countryISOCode);
        }
        initialNumber = parsed.number;
      } catch (_) {
        initialNumber = widget.initialValue!;
      }
    }

    _controller = TextEditingController(text: initialNumber);
    _controller.addListener(_notifyChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_notifyChanged);
    _controller.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged?.call(_currentPhone());
  }

  PhoneNumber _currentPhone() {
    return PhoneNumber(
      countryISOCode: _selectedCountry.code,
      countryCode: '+${_selectedCountry.fullCountryCode}',
      number: _controller.text,
    );
  }

  Future<void> _openCountryPicker() async {
    if (!widget.enabled) return;

    final picked = await showDialog<Country>(
      context: context,
      builder: (ctx) => _FlagCountryPickerDialog(selected: _selectedCountry),
    );

    if (picked != null && mounted) {
      setState(() => _selectedCountry = picked);
      _notifyChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<PhoneNumber>(
      initialValue: _currentPhone(),
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controller,
              enabled: widget.enabled,
              keyboardType: TextInputType.phone,
              style: widget.style,
              decoration: widget.decoration.copyWith(
                errorText: field.errorText,
                prefixIcon: InkWell(
                  onTap: _openCountryPicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CountryFlagImage(code: _selectedCountry.code, width: 28),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: widget.dropdownTextStyle?.color ?? AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          '+${_selectedCountry.dialCode}',
                          style: widget.dropdownTextStyle ??
                              const TextStyle(color: AppColors.primaryDeep, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 118, minHeight: 48),
              ),
              onChanged: (_) => field.didChange(_currentPhone()),
            ),
          ],
        );
      },
    );
  }
}

class CountryFlagImage extends StatelessWidget {
  const CountryFlagImage({super.key, required this.code, this.width = 32});

  final String code;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        'assets/flags/${code.toLowerCase()}.png',
        package: 'intl_phone_field',
        width: width,
        height: width * 0.67,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) {
          Country? country;
          for (final c in countries) {
            if (c.code == code) {
              country = c;
              break;
            }
          }
          return SizedBox(
            width: width,
            child: Text(country?.flag ?? '🏳', style: TextStyle(fontSize: width * 0.55)),
          );
        },
      ),
    );
  }
}

class _FlagCountryPickerDialog extends StatefulWidget {
  const _FlagCountryPickerDialog({required this.selected});

  final Country selected;

  @override
  State<_FlagCountryPickerDialog> createState() => _FlagCountryPickerDialogState();
}

class _FlagCountryPickerDialogState extends State<_FlagCountryPickerDialog> {
  late List<Country> _filtered;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = List<Country>.from(countries)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      _filtered = countries.stringSearch(query)..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select country',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: _filter,
                    decoration: InputDecoration(
                      hintText: 'Search country',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.scaffold,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                itemBuilder: (context, index) {
                  final country = _filtered[index];
                  final isSelected = country.code == widget.selected.code;
                  return ListTile(
                    leading: CountryFlagImage(code: country.code, width: 36),
                    title: Text(
                      country.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF2D1B4E),
                      ),
                    ),
                    trailing: Text(
                      '+${country.dialCode}',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: isSelected ? const Color(0xFF6F38C5) : const Color(0xFF7A6B8A),
                      ),
                    ),
                    selected: isSelected,
                    onTap: () => Navigator.of(context).pop(country),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
