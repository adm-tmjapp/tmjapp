import 'package:tmjapp/features/profile/domain/entities/profile_details.dart';

class ProfileState {
  const ProfileState({
    this.isLoading = true,
    this.isSaving = false,
    this.profile,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSaving;
  final ProfileDetails? profile;
  final String? errorMessage;

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    ProfileDetails? profile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
