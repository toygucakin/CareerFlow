import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
  String? get providerToken;

  Future<void> signUp({required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
  Future<UserProfile?> getProfile(String userId);
  Future<void> updateProfile(UserProfile profile);
  Future<void> sendPasswordResetEmail(String email, {String? redirectTo});
}
