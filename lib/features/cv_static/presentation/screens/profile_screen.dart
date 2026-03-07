import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  String _cvLanguage = 'Türkçe';
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
      final updatedProfile = currentProfile.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        birthDate: _selectedBirthDate,
        cvLanguage: _cvLanguage,
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

  Future<void> _selectDate(BuildContext context) async {
    DateTime tempDate = _selectedBirthDate ?? DateTime(1995);
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedBirthDate = tempDate);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Tamam'),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate,
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    tempDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final user = ref.read(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişisel Bilgiler'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('CV dili ', style: TextStyle(fontSize: 12)),
                DropdownButton<String>(
                  value: _cvLanguage,
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) setState(() => _cvLanguage = newValue);
                  },
                  items: <String>['Türkçe', 'English', 'Deutsch']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (user == null) return const Center(child: Text('Lütfen giriş yapın.'));
          final currentProfile = profile ?? UserProfile(id: user.id);

          if (!_isFormInitialized) {
            _firstNameController.text = currentProfile.firstName ?? '';
            _lastNameController.text = currentProfile.lastName ?? '';
            _phoneController.text = currentProfile.phone ?? '';
            _cityController.text = currentProfile.city ?? '';
            _districtController.text = currentProfile.district ?? '';
            _cvLanguage = currentProfile.cvLanguage ?? 'Türkçe';
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

          return Form(
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
                  decoration: const InputDecoration(
                    labelText: 'Telefon numarası',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
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
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Doğum tarihi'),
                    child: Text(
                      _selectedBirthDate == null
                          ? 'Gün / Ay / Yıl'
                          : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveProfile(currentProfile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Değişiklikleri Kaydet'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}
