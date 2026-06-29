import 'dart:io'; // Importação necessária para o File
import 'package:flutter/foundation.dart';
import 'package:tmjapp/core/presentation/controllers/disposable_change_notifier.dart';
import 'package:tmjapp/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:tmjapp/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:tmjapp/features/profile/presentation/controllers/profile_state.dart';

class ProfileController extends ChangeNotifier with DisposableChangeNotifier {
  ProfileController({
    required ProfileLocalDataSource localDataSource,
    required ProfileRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  final ProfileLocalDataSource _localDataSource;
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileState _state = const ProfileState();
  ProfileState get state => _state;

  Future<void> initialize() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final userId = await _localDataSource.getUserId();
      if (isDisposed) return;
      final cachedProfile = await _localDataSource.getCachedProfile();
      if (isDisposed) return;

      if (userId == null || userId.trim().isEmpty) {
        if (cachedProfile != null) {
          _state = _state.copyWith(
            isLoading: false,
            profile: cachedProfile,
            errorMessage:
                'Sessao expirada. Faça login novamente para atualizar seus dados.',
          );
        } else {
          throw Exception('Sessao expirada. Faça login novamente.');
        }
        notifyListeners();
        return;
      }

      final profile = await _remoteDataSource.fetchProfile(userId);
      if (isDisposed) return;
      await _localDataSource.saveBasicProfile(
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
      );
      if (isDisposed) return;
      _state = _state.copyWith(
        isLoading: false,
        profile: profile,
        clearError: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
    notifyListeners();
  }

  Future<void> refresh() => initialize();

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final current = _state.profile;
    if (current == null) {
      return;
    }

    _state = _state.copyWith(isSaving: true, clearError: true);
    notifyListeners();

    try {
      final updated = await _remoteDataSource.updateProfile(
        userId: current.userId,
        name: name,
        phone: phone,
      );
      if (isDisposed) return;
      await _localDataSource.saveBasicProfile(
        name: updated.name,
        email: updated.email,
        phone: updated.phone,
      );
      if (isDisposed) return;
      _state = _state.copyWith(
        isSaving: false,
        profile: updated,
        clearError: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isSaving: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
    notifyListeners();
  }

  // 👇 MÉTODO ADICIONADO PARA ATUALIZAR A FOTO
  Future<void> updatePhoto(File imageFile) async {
    final current = _state.profile;
    if (current == null) return;

    _state = _state.copyWith(isSaving: true, clearError: true);
    notifyListeners();

    try {
      // 1. Chama o DataSource remoto para fazer o upload
      final newPhotoUrl = await _remoteDataSource.updateProfilePhoto(imageFile);
      if (isDisposed) return;

      // 2. Atualiza o objeto de perfil localmente com a nova URL (usando o copyWith da entidade)
      final updatedProfile = current.copyWith(profilePhotoUrl: newPhotoUrl);

      _state = _state.copyWith(
        isSaving: false,
        profile: updatedProfile,
        clearError: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isSaving: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
    notifyListeners();
  }

  Future<void> requestAccountDeletion() async {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
    // Aqui você poderia registrar um log de intenção de exclusão no Firebase/Backend se necessário
  }

  Future<void> signOut() => _localDataSource.clearSession();
}
