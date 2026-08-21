import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../domain/models/user_model.dart';
import '../domain/models/role.dart';

class AuthState {
  final SocietyUser? user;
  final SocietyRole? role;
  final bool isLoading;

  AuthState({this.user, this.role, this.isLoading = false});

  AuthState copyWith({SocietyUser? user, SocietyRole? role, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void switchToUser(String uid) {
    state = state.copyWith(isLoading: true);
    
    final user = MockData.users.firstWhere((u) => u.uid == uid);
    final role = MockData.roles.firstWhere((r) => r.name == user.roleName);
    
    state = AuthState(user: user, role: role, isLoading: false);
  }

  bool login(String email, String password) {
    state = state.copyWith(isLoading: true);
    
    final emailLower = email.trim().toLowerCase();
    final userIndex = MockData.users.indexWhere((u) => u.email.toLowerCase() == emailLower);
    
    if (userIndex != -1) {
      final user = MockData.users[userIndex];
      final role = MockData.roles.firstWhere((r) => r.name == user.roleName);
      state = AuthState(user: user, role: role, isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  void register(String name, String email, String domainName, String roleName) {
    state = state.copyWith(isLoading: true);
    
    String domainId = 'dom-tech';
    if (domainName == 'Creative') {
      domainId = 'dom-creative';
    } else if (domainName == 'Public Relations' || domainName == 'Marketing') {
      domainId = 'dom-pr';
    } else if (domainName == 'Operations') {
      domainId = 'dom-ops';
    }
    
    final newUid = 'user-${DateTime.now().millisecondsSinceEpoch}';
    final newUser = SocietyUser(
      uid: newUid,
      orgId: MockData.orgId,
      domainId: domainId,
      name: name,
      email: email.trim(),
      roleName: roleName,
      status: UserStatus.pending,
      createdAt: DateTime.now(),
    );
    
    MockData.users.add(newUser);
    
    final role = MockData.roles.firstWhere((r) => r.name == roleName);
    state = AuthState(user: newUser, role: role, isLoading: false);
  }

  void logout() {
    state = AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<SocietyUser?>((ref) {
  return ref.watch(authStateProvider).user;
});

final currentRoleProvider = Provider<SocietyRole?>((ref) {
  return ref.watch(authStateProvider).role;
});
