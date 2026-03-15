import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/user_profile.dart';
import '../../../../core/constants/turkey_data.dart';
import '../../../cv_builder/domain/models/social_media.dart';
import '../../../cv_builder/presentation/providers/social_media_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final DateTime? navigationStartTime;
  const ProfileScreen({super.key, this.navigationStartTime});

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
    CountryData(
      code: '+90',
      name: 'Türkiye',
      flag: '🇹🇷',
      mask: '### ### ## ##',
    ),
    CountryData(
      code: '+1',
      name: 'Amerika',
      flag: '🇺🇸',
      mask: '### ### ####',
    ),
    CountryData(
      code: '+49',
      name: 'Almanya',
      flag: '🇩🇪',
      mask: '#### ########',
    ),
  ];
  late CountryData _selectedCountry;
  DateTime? _selectedBirthDate;

  late final List<String> _sortedCities;

  bool _isSaving = false;
  bool _isFormInitialized = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _districtController = TextEditingController();
    _selectedCountry = _countryOptions.first;
    _sortedCities = turkeyCities.keys.toList()..sort();
    _isReady = true;
    
    if (widget.navigationStartTime != null) {
      final duration = DateTime.now().difference(widget.navigationStartTime!);
      debugPrint('PERF: ProfileScreen opened in ${duration.inMilliseconds}ms');
    }
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

  Widget _buildLoadingState() {
    return const _ProfileShimmer();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final user = ref.read(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişisel Bilgiler'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _showLogoutConfirmation(context, ref),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: profileAsync.when(
          data: (profile) {
            if (user == null) {
              return const Center(child: Text('Lütfen giriş yapın.'));
            }

            if (!_isReady) return _buildLoadingState();

            final currentProfile = profile ?? UserProfile(id: user.id);

            if (!_isFormInitialized) {
              _firstNameController.text = currentProfile.firstName ?? '';
              _lastNameController.text = currentProfile.lastName ?? '';
              String rawPhone = currentProfile.phone ?? '';
              if (rawPhone.startsWith('+')) {
                bool found = false;
                for (CountryData country in _countryOptions) {
                  if (rawPhone.startsWith(country.code)) {
                    _selectedCountry = country;
                    String numPart = rawPhone.substring(country.code.length);
                    _phoneController.text = _formatWithMask(numPart, country.mask);
                    found = true;
                    break;
                  }
                }
                if (!found) _phoneController.text = rawPhone;
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
            for (final city in _sortedCities) {
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
                    _buildNameSection(),
                    const SizedBox(height: 24),
                    _buildEmailSection(user.email ?? ''),
                    const SizedBox(height: 16),
                    _buildPhoneSection(),
                    const SizedBox(height: 16),
                    _buildBirthDateSection(),
                    const SizedBox(height: 16),
                    _buildLocationSection(validCity, districtItems),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildSocialMediaSection(),
                    const SizedBox(height: 40),
                    _buildSaveButton(currentProfile),
                  ],
                ),
              ),
            );
          },
          loading: () => _buildLoadingState(),
          error: (err, stack) => Center(child: Text('Hata: $err')),
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
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
      ],
    );
  }

  Widget _buildEmailSection(String email) {
    return TextFormField(
      initialValue: email,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'E-posta adresi',
        prefixIcon: Icon(Icons.email_outlined),
        helperText: 'Oturum açtığınız e-posta adresi (değiştirilemez)',
      ),
    );
  }

  Widget _buildPhoneSection() {
    return TextFormField(
      controller: _phoneController,
      inputFormatters: [PhoneInputFormatter(mask: _selectedCountry.mask)],
      decoration: InputDecoration(
        labelText: 'Telefon numarası',
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: const EdgeInsets.only(right: 8),
          decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.grey, width: 1))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CountryData>(
              value: _selectedCountry,
              items: _countryOptions.map((c) => DropdownMenuItem(value: c, child: Text('${c.flag} ${c.code} ${c.name}'))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCountry = val;
                    _phoneController.clear();
                  });
                }
              },
            ),
          ),
        ),
      ),
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildBirthDateSection() {
    return TextFormField(
      controller: TextEditingController(
        text: _selectedBirthDate != null ? "${_selectedBirthDate!.day.toString().padLeft(2, '0')}/${_selectedBirthDate!.month.toString().padLeft(2, '0')}/${_selectedBirthDate!.year}" : '',
      ),
      readOnly: true,
      onTap: _showDatePicker,
      decoration: const InputDecoration(
        labelText: 'Doğum tarihi',
        prefixIcon: Icon(Icons.cake_outlined, color: Colors.pinkAccent),
        hintText: 'Gün/Ay/Yıl seçin',
      ),
      validator: (v) => _selectedBirthDate == null ? 'Gerekli' : null,
    );
  }

  Widget _buildLocationSection(String? validCity, List<String> districtItems) {
    return Column(
      children: [
        Autocomplete<String>(
          initialValue: TextEditingValue(text: _cityController.text),
          optionsBuilder: (val) {
            if (val.text.isEmpty) return _sortedCities;
            return _sortedCities.where((c) => c.toLowerCase().startsWith(val.text.toLowerCase()));
          },
          onSelected: (val) {
            setState(() {
              _cityController.text = val;
              _districtController.clear();
            });
          },
          fieldViewBuilder: (ctx, ctrl, node, onSub) {
            return TextFormField(
              controller: ctrl,
              focusNode: node,
              decoration: const InputDecoration(labelText: 'Şehir', prefixIcon: Icon(Icons.location_city_outlined)),
              onChanged: (v) {
                _cityController.text = v;
                if (_districtController.text.isNotEmpty) {
                  _districtController.clear();
                  setState(() {});
                }
              },
              validator: (v) => v!.isEmpty ? 'Gerekli' : null,
            );
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey('district_${validCity ?? "none"}'),
          value: (_districtController.text.isNotEmpty && districtItems.contains(_districtController.text)) ? _districtController.text : null,
          decoration: InputDecoration(
            labelText: 'İlçe',
            prefixIcon: const Icon(Icons.map_outlined),
            hintText: validCity != null ? 'İlçe seçin' : 'Önce şehir seçin',
          ),
          items: validCity != null ? districtItems.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList() : null,
          onChanged: validCity == null ? null : (v) => setState(() => _districtController.text = v!),
          validator: (v) => (v == null || v.isEmpty) ? 'Gerekli' : null,
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sosyal Medya & Linkler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('LinkedIn, GitHub veya makale paylaştığın platformları ekleyerek profilini güçlendir.', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showSocialMediaManager,
            icon: const Icon(Icons.link),
            label: const Text('Sosyal Medya Hesaplarını Yönet'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(UserProfile currentProfile) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
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
    );
  }

  void _showDatePicker() {
    FocusScope.of(context).unfocus();
    final initialDate = _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 20));
    final minDate = DateTime.now().subtract(const Duration(days: 365 * 100));
    final maxDate = DateTime.now().subtract(const Duration(days: 365 * 13));
    DateTime tempSelectedDate = initialDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal', style: TextStyle(color: Colors.grey, fontSize: 16))),
                    Text('Doğum Tarihi', style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color, fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedBirthDate = tempSelectedDate);
                        Navigator.pop(ctx);
                      },
                      child: Text('Bitti', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _CustomDatePicker(
                  initialDate: initialDate,
                  minimumDate: minDate,
                  maximumDate: maxDate,
                  onDateChanged: (val) => tempSelectedDate = val,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSocialMediaManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SocialMediaManagerSheet(),
    );
  }

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

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back home
              ref.read(authRepositoryProvider).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}

class _SocialMediaManagerSheet extends ConsumerWidget {
  const _SocialMediaManagerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socialMediaAsync = ref.watch(socialMediaListProvider);

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sosyal Medya Hesapları', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            socialMediaAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Text('Henüz bir hesap eklenmedi.', style: TextStyle(color: Colors.grey))));
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: accounts.length,
                  separatorBuilder: (ctx, idx) => const Divider(),
                  itemBuilder: (ctx, idx) {
                    final account = accounts[idx];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: account.platform.color.withOpacity(0.1),
                        child: FaIcon(account.platform.icon, color: account.platform.color, size: 18),
                      ),
                      title: Text(account.platform.displayName, style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color, fontWeight: FontWeight.bold)),
                      subtitle: Text(account.url, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => ref.read(socialMediaListProvider.notifier).deleteAccount(account.id!),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Hata: $err', style: TextStyle(color: Theme.of(context).colorScheme.error))),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Hesap Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => const _AddSocialMediaDialog());
  }
}

class _AddSocialMediaDialog extends StatefulWidget {
  const _AddSocialMediaDialog();
  @override
  State<_AddSocialMediaDialog> createState() => _AddSocialMediaDialogState();
}

class _AddSocialMediaDialogState extends State<_AddSocialMediaDialog> {
  SocialMediaPlatform _selectedPlatform = SocialMediaPlatform.linkedIn;
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (ctx, ref, child) {
        return AlertDialog(
          title: const Text('Yeni Hesap Ekle'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<SocialMediaPlatform>(
                  value: _selectedPlatform,
                  decoration: const InputDecoration(labelText: 'Platform'),
                  items: SocialMediaPlatform.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          FaIcon(p.icon, color: p.color, size: 16),
                          const SizedBox(width: 12),
                          Text(p.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedPlatform = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'Profil Linki', hintText: 'https://...'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Gerekli' : (!v.startsWith('http') ? 'Geçerli bir URL girin' : null),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final user = ref.read(authRepositoryProvider).currentUser;
                  if (user != null) {
                    await ref.read(socialMediaListProvider.notifier).addAccount(
                      SocialMediaAccount(platform: _selectedPlatform, url: _urlController.text.trim(), profileId: user.id),
                    );
                    if (mounted) Navigator.pop(ctx);
                  }
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  final String mask;
  PhoneInputFormatter({required this.mask});
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldVal, TextEditingValue newVal) {
    String clean = newVal.text.replaceAll(RegExp(r'\D'), '');
    String formatted = '';
    int idx = 0;
    for (int i = 0; i < mask.length; i++) {
      if (idx >= clean.length) break;
      if (mask[i] == '#') {
        formatted += clean[idx];
        idx++;
      } else {
        formatted += mask[i];
      }
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class _CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime minimumDate;
  final DateTime maximumDate;
  final ValueChanged<DateTime> onDateChanged;
  const _CustomDatePicker({required this.initialDate, required this.minimumDate, required this.maximumDate, required this.onDateChanged});
  @override
  State<_CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<_CustomDatePicker> {
  late int _day, _month, _year;
  late FixedExtentScrollController _dayCtrl, _monthCtrl, _yearCtrl;
  final List<String> _months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

  @override
  void initState() {
    super.initState();
    _day = widget.initialDate.day;
    _month = widget.initialDate.month;
    _year = widget.initialDate.year;
    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _yearCtrl = FixedExtentScrollController(initialItem: _year - widget.minimumDate.year);
  }

  void _onChanged() {
    final max = DateUtils.getDaysInMonth(_year, _month);
    if (_day > max) {
      _day = max;
      _dayCtrl.jumpToItem(_day - 1);
    }
    widget.onDateChanged(DateTime(_year, _month, _day));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Theme.of(context).brightness,
          textTheme: CupertinoTextThemeData(
            pickerTextStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 18,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(child: CupertinoPicker.builder(scrollController: _dayCtrl, itemExtent: 44, onSelectedItemChanged: (i) { _day = i + 1; _onChanged(); }, childCount: DateUtils.getDaysInMonth(_year, _month), itemBuilder: (c, i) => Center(child: Text('${i + 1}')))),
            Expanded(child: CupertinoPicker.builder(scrollController: _monthCtrl, itemExtent: 44, onSelectedItemChanged: (i) { _month = i + 1; _onChanged(); }, childCount: 12, itemBuilder: (c, i) => Center(child: Text(_months[i])))),
            Expanded(child: CupertinoPicker.builder(scrollController: _yearCtrl, itemExtent: 44, onSelectedItemChanged: (i) { _year = widget.minimumDate.year + i; _onChanged(); }, childCount: widget.maximumDate.year - widget.minimumDate.year + 1, itemBuilder: (c, i) => Center(child: Text('${widget.minimumDate.year + i}')))),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dayCtrl.dispose(); _monthCtrl.dispose(); _yearCtrl.dispose();
    super.dispose();
  }
}

class CountryData {
  final String code, name, flag, mask;
  CountryData({required this.code, required this.name, required this.flag, required this.mask});
}

class _ProfileShimmer extends StatefulWidget {
  const _ProfileShimmer();
  @override
  State<_ProfileShimmer> createState() => _ProfileShimmerState();
}

class _ProfileShimmerState extends State<_ProfileShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, child) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _Skeleton(width: 80, height: 16, ctrl: _ctrl), const SizedBox(height: 12),
          _Skeleton(height: 56, ctrl: _ctrl), const SizedBox(height: 16),
          _Skeleton(width: 80, height: 16, ctrl: _ctrl), const SizedBox(height: 12),
          _Skeleton(height: 56, ctrl: _ctrl), const SizedBox(height: 24),
          _Skeleton(width: 120, height: 16, ctrl: _ctrl), const SizedBox(height: 12),
          _Skeleton(height: 56, ctrl: _ctrl), const SizedBox(height: 16),
          _Skeleton(width: 100, height: 16, ctrl: _ctrl), const SizedBox(height: 12),
          _Skeleton(height: 56, ctrl: _ctrl), const SizedBox(height: 24),
          const Divider(), const SizedBox(height: 16),
          _Skeleton(width: 150, height: 20, ctrl: _ctrl), const SizedBox(height: 12),
          _Skeleton(height: 100, ctrl: _ctrl), const SizedBox(height: 40),
          _Skeleton(height: 56, borderRadius: 16, ctrl: _ctrl),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  final double? width; final double height, borderRadius; final AnimationController ctrl;
  const _Skeleton({this.width, required this.height, this.borderRadius = 8, required this.ctrl});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity, height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? const [Color(0xFF2C2C2C), Color(0xFF3D3D3D), Color(0xFF2C2C2C)]
              : const [Color(0xFFE0E0E0), Color(0xFFF0F0F0), Color(0xFFE0E0E0)],
          stops: [0.0, ctrl.value, 1.0],
        ),
      ),
    );
  }
}
