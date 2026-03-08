import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/user_profile.dart';
import '../../../../core/constants/turkey_data.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  
  final List<CountryData> _countryOptions = [
    CountryData(code: '+90', name: 'Türkiye', flag: '🇹🇷', mask: '### ### ## ##'),
    CountryData(code: '+1', name: 'Amerika', flag: '🇺🇸', mask: '### ### ####'),
    CountryData(code: '+49', name: 'Almanya', flag: '🇩🇪', mask: '#### ########'),
  ];
  late CountryData _selectedCountry;
  DateTime? _selectedBirthDate;

  bool _isSaving = false;
  bool _isFormInitialized = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _districtController = TextEditingController();
    _selectedCountry = _countryOptions.first; // Default Turkey
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(UserProfile currentProfile) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      // Remove mask characters (spaces) for saving to DB
      final unmaskedPhone = _phoneController.text.replaceAll(' ', '');
      
      final updatedProfile = currentProfile.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: '${_selectedCountry.code}$unmaskedPhone',
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        birthDate: _selectedBirthDate,
        email: ref.read(authRepositoryProvider).currentUser?.email,
        updatedAt: DateTime.now(),
      );

      await ref.read(authRepositoryProvider).updateProfile(updatedProfile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final user = ref.read(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişisel Bilgiler'),
      ),
      body: profileAsync.when(
        data: (profile) {
          if (user == null) return const Center(child: Text('Lütfen giriş yapın.'));
          final currentProfile = profile ?? UserProfile(id: user.id);

          if (!_isFormInitialized) {
            _firstNameController.text = currentProfile.firstName ?? '';
            _lastNameController.text = currentProfile.lastName ?? '';
            
            // Ülke kodu ve telefon numarasını ayrıştırma
            String rawPhone = currentProfile.phone ?? '';
            if (rawPhone.startsWith('+')) {
              bool found = false;
              for (CountryData country in _countryOptions) {
                if (rawPhone.startsWith(country.code)) {
                  _selectedCountry = country;
                  // format the remaining parts according to the new mask
                  String numPart = rawPhone.substring(country.code.length);
                  _phoneController.text = _formatWithMask(numPart, country.mask);
                  found = true;
                  break;
                }
              }
              if (!found) {
                 _phoneController.text = rawPhone;
              }
            } else {
              _phoneController.text = _formatWithMask(rawPhone, _selectedCountry.mask);
            }

            _cityController.text = currentProfile.city ?? '';
            _districtController.text = currentProfile.district ?? '';
            _selectedBirthDate = currentProfile.birthDate;
            _isFormInitialized = true;
          }

          final inputCity = _cityController.text.trim().toLowerCase();
          String? validCity;
          for (final city in turkeyCities.keys) {
            if (city.toLowerCase() == inputCity) {
              validCity = city;
              break;
            }
          }
          final districtItems = validCity != null ? turkeyCities[validCity]! : <String>[];

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                TextFormField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'İsim'),
                  validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Soy isim'),
                  validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  initialValue: user.email,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'E-posta adresi',
                    prefixIcon: Icon(Icons.email_outlined),
                    helperText: 'Oturum açtığınız e-posta adresi (değiştirilemez)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  inputFormatters: [
                    PhoneInputFormatter(mask: _selectedCountry.mask),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Telefon numarası',
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.grey, width: 1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CountryData>(
                          value: _selectedCountry,
                          items: _countryOptions.map((CountryData country) {
                            return DropdownMenuItem<CountryData>(
                              value: country,
                              child: Text('${country.flag} ${country.code} ${country.name}'),
                            );
                          }).toList(),
                          onChanged: (CountryData? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCountry = newValue;
                                // clear text or reformat existing to new mask if needed.
                                // For simplicity, we just clear to avoid mask clashing
                                _phoneController.clear();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => FocusScope.of(context).unfocus(), // First dismiss keyboard
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _selectedBirthDate != null
                          // Show in DD/MM/YYYY format
                          ? "${_selectedBirthDate!.day.toString().padLeft(2, '0')}/${_selectedBirthDate!.month.toString().padLeft(2, '0')}/${_selectedBirthDate!.year}"
                          : '',
                    ),
                    readOnly: true,
                    onTap: _showDatePicker,
                    decoration: const InputDecoration(
                      labelText: 'Doğum tarihi',
                      prefixIcon: Icon(Icons.cake_outlined, color: Colors.pinkAccent),
                      hintText: 'Gün/Ay/Yıl seçin',
                    ),
                    validator: (v) => _selectedBirthDate == null ? 'Gerekli' : null,
                  ),
                ),
                const SizedBox(height: 16),
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: _cityController.text),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return turkeyCities.keys.toList()..sort();
                    }
                    return turkeyCities.keys.where((String city) {
                      return city.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
                    }).toList()..sort();
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _cityController.text = selection;
                      _districtController.clear();
                    });
                    FocusScope.of(context).unfocus(); // İmleci ve klavyeyi gizle
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Şehir',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      onChanged: (v) {
                        _cityController.text = v;
                        _districtController.clear();
                        setState(() {});
                      },
                      validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey('district_${validCity ?? "none"}'),
                  value: (_districtController.text.isNotEmpty && districtItems.contains(_districtController.text))
                      ? _districtController.text
                      : null,
                  decoration: InputDecoration(
                    labelText: 'İlçe',
                    prefixIcon: const Icon(Icons.map_outlined),
                    hintText: validCity != null ? 'İlçe seçin' : 'Önce şehir seçin',
                  ),
                  items: validCity != null
                      ? districtItems.map((String district) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Text(district),
                          );
                        }).toList()
                      : null,
                  onChanged: validCity == null
                      ? null
                      : (String? newValue) {
                          if (newValue != null) {
                            setState(() => _districtController.text = newValue);
                          }
                        },
                  validator: (v) => (v == null || v.isEmpty) ? 'Gerekli' : null,
                ),
                const SizedBox(height: 40),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveProfile(currentProfile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Değişiklikleri Kaydet'),
                ),
              ],
            ),
           ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }

  void _showDatePicker() {
    FocusScope.of(context).unfocus();
    
    // Set initial date to either selected date or 20 years ago
    final initialDate = _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 20));
    final minDate = DateTime.now().subtract(const Duration(days: 365 * 100)); // Max age 100
    final maxDate = DateTime.now().subtract(const Duration(days: 365 * 13));  // Min age 13

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext builder) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              // Header with Done button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                    const Text('Doğum Tarihi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        // If user hasn't scrolled, ensure the initially displayed date is saved
                        if (_selectedBirthDate == null) {
                           setState(() => _selectedBirthDate = initialDate);
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('Bitti', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _CustomDatePicker(
                  initialDate: initialDate,
                  minimumDate: minDate,
                  maximumDate: maxDate,
                  onDateChanged: (DateTime newDate) {
                    setState(() {
                      _selectedBirthDate = newDate;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Helper to pre-format data coming from DB
  String _formatWithMask(String text, String mask) {
    String cleanText = text.replaceAll(RegExp(r'\D'), '');
    String formattedText = '';
    int textIndex = 0;
    for (int i = 0; i < mask.length; i++) {
      if (textIndex >= cleanText.length) break;
      if (mask[i] == '#') {
        formattedText += cleanText[textIndex];
        textIndex++;
      } else {
        formattedText += mask[i];
      }
    }
    return formattedText;
  }
}

class CountryData {
  final String code;
  final String name;
  final String flag;
  final String mask;

  CountryData({
    required this.code,
    required this.name,
    required this.flag,
    required this.mask,
  });
}

class PhoneInputFormatter extends TextInputFormatter {
  final String mask;

  PhoneInputFormatter({required this.mask});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only numbers 
    String cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');

    String formattedText = '';
    int textIndex = 0;

    for (int i = 0; i < mask.length; i++) {
      if (textIndex >= cleanText.length) {
        break;
      }
      if (mask[i] == '#') {
        formattedText += cleanText[textIndex];
        textIndex++;
      } else {
        formattedText += mask[i];
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime minimumDate;
  final DateTime maximumDate;
  final ValueChanged<DateTime> onDateChanged;

  const _CustomDatePicker({
    required this.initialDate,
    required this.minimumDate,
    required this.maximumDate,
    required this.onDateChanged,
  });

  @override
  State<_CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<_CustomDatePicker> {
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  final List<String> _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate.day;
    _selectedMonth = widget.initialDate.month;
    _selectedYear = widget.initialDate.year;

    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthController = FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _yearController = FixedExtentScrollController(initialItem: _selectedYear - widget.minimumDate.year);
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int get _daysInMonth => DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);

  void _onDateChanged() {
    final daysInCurrentMonth = _daysInMonth;
    if (_selectedDay > daysInCurrentMonth) {
      _selectedDay = daysInCurrentMonth;
      _dayController.jumpToItem(_selectedDay - 1);
    }
    
    // Ensure we don't exceed min/max dates
    DateTime newDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    if (newDate.isBefore(widget.minimumDate)) {
      newDate = widget.minimumDate;
      _syncControllersToDate(newDate);
    } else if (newDate.isAfter(widget.maximumDate)) {
      newDate = widget.maximumDate;
      _syncControllersToDate(newDate);
    }

    widget.onDateChanged(newDate);
    setState(() {});
  }

  void _syncControllersToDate(DateTime date) {
    _selectedYear = date.year;
    _selectedMonth = date.month;
    _selectedDay = date.day;
    _yearController.jumpToItem(_selectedYear - widget.minimumDate.year);
    _monthController.jumpToItem(_selectedMonth - 1);
    _dayController.jumpToItem(_selectedDay - 1);
  }

  @override
  Widget build(BuildContext context) {
    final int minYear = widget.minimumDate.year;
    final int maxYear = widget.maximumDate.year;
    final int yearsCount = maxYear - minYear + 1;

    return SizedBox(
      height: 180,
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.light,
          textTheme: CupertinoTextThemeData(
            pickerTextStyle: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
        child: Row(
          children: [
            // DAY PICKER
            Expanded(
              flex: 1,
              child: CupertinoPicker.builder(
                scrollController: _dayController,
                itemExtent: 32,
                childCount: _daysInMonth,
                onSelectedItemChanged: (index) {
                  _selectedDay = index + 1;
                  _onDateChanged();
                },
                itemBuilder: (context, index) {
                  return Center(child: Text('${index + 1}'));
                },
              ),
            ),
            // MONTH PICKER
            Expanded(
              flex: 2,
              child: CupertinoPicker.builder(
                scrollController: _monthController,
                itemExtent: 32,
                childCount: 12,
                onSelectedItemChanged: (index) {
                  _selectedMonth = index + 1;
                  _onDateChanged();
                },
                itemBuilder: (context, index) {
                  return Center(child: Text(_months[index]));
                },
              ),
            ),
            // YEAR PICKER
            Expanded(
              flex: 1,
              child: CupertinoPicker.builder(
                scrollController: _yearController,
                itemExtent: 32,
                childCount: yearsCount,
                onSelectedItemChanged: (index) {
                  _selectedYear = minYear + index;
                  _onDateChanged();
                },
                itemBuilder: (context, index) {
                  return Center(child: Text('${minYear + index}'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

