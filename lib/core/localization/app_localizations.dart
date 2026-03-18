import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'CareerFlow',
      'auth_subtitle': 'Build your autonomous developer CV',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'sign_up': 'Sign Up',
      'forgot_password': 'Forgot Password',
      'dont_have_account': "Don't have an account? Sign Up",
      'already_have_account': 'Already have an account? Login',
      'error': 'Error',
      'reset_password_email_sent': 'Password reset link sent to your email.',
      'enter_email_for_reset': 'Please enter your email address for password reset.',
      'new_password': 'New Password',
      'confirm_password': 'Confirm Password',
      'update_password': 'Update Password',
      'password_min_length': 'Password must be at least 6 characters.',
      'passwords_dont_match': 'Passwords do not match.',
      'password_updated': 'Password updated successfully!',
      'set_new_password_msg': 'Please set a new password for your account.',
      'hata': 'Error',
    },
    'tr': {
      'app_title': 'CareerFlow',
      'auth_subtitle': 'Otonom geliştirici CV\'nizi oluşturun',
      'email': 'E-posta',
      'password': 'Şifre',
      'login': 'Giriş Yap',
      'sign_up': 'Kayıt Ol',
      'forgot_password': 'Şifremi Unuttum',
      'dont_have_account': 'Hesabınız yok mu? Kayıt Olun',
      'already_have_account': 'Zaten bir hesabınız var mı? Giriş Yapın',
      'error': 'Hata',
      'reset_password_email_sent': 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.',
      'enter_email_for_reset': 'Lütfen şifre sıfırlama için e-posta adresinizi girin.',
      'new_password': 'Yeni Şifre',
      'confirm_password': 'Şifreyi Onayla',
      'update_password': 'Şifreyi Güncelle',
      'password_min_length': 'Şifre en az 6 karakter olmalıdır.',
      'passwords_dont_match': 'Şifreler eşleşmiyor.',
      'password_updated': 'Şifreniz başarıyla güncellendi!',
      'set_new_password_msg': 'Lütfen hesabınız için yeni bir şifre belirleyin.',
      'hata': 'Hata',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}
