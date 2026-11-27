import 'package:flutter/material.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

import 'core/services/api_client.dart';
import 'core/services/http_overrides.dart';
import 'core/services/session_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/academic_years/presentation/academic_years_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/grades/presentation/grades_screen.dart';
import 'features/iam_management/presentation/iam_management_screen.dart';
import 'features/messaging/presentation/messaging_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/preview/presentation/preview_screen.dart';
import 'features/profile/presentation/user_profile_screen.dart';
import 'features/school_profile/presentation/school_profile_screen.dart';
import 'features/school_profile/presentation/schools_campuses_screen.dart';
import 'features/school_profile/presentation/tenant_management_screen.dart';
import 'shared_widgets/adaptive_scaffold.dart';
import 'state/app_navigation_guard.dart';
import 'state/app_state.dart';
import 'state/auth_notifier.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupHttpOverrides();
  await sessionStorageService.init();
  await apiClient.loadRuntimeConfig();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
      ],
      child: const IlmiyaApp(),
    ),
  );
}

class IlmiyaApp extends StatefulWidget {
  const IlmiyaApp({super.key});

  @override
  State<IlmiyaApp> createState() => _IlmiyaAppState();
}

class _IlmiyaAppState extends State<IlmiyaApp> {
  void Function()? _unsubAuthExpired;
  void Function()? _unsubAccessDenied;
  void Function()? _unsubLogout;
  void Function()? _unsubLogin;
  AuthNotifier? _auth;
  AppState? _appState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_unsubLogout == null) {
      final auth = context.read<AuthNotifier>();
      final state = context.read<AppState>();
      _auth = auth;
      _appState = state;
      state.setTabAccessGuard(
        (tab) => AppNavigationGuard.canAccessTab(tab, auth),
        fallbackTab: AppNavigationGuard.firstAccessibleTab(auth),
      );
      auth.addListener(_ensureAccessibleTab);
      _unsubLogout = auth.onLogout(() {
        state.resetSession();
      });
      _unsubLogin = auth.onLogin(() {
        state.resetSession();
      });
    }
  }

  /// Redirects away from tabs the user lost access to (login, tenant switch,
  /// permission change) so no hidden screen can stay active.
  void _ensureAccessibleTab() {
    final auth = _auth;
    final state = _appState;
    if (auth == null || state == null) return;
    if (!auth.isAuthenticated) {
      state.setTabAccessGuard(
        (tab) => AppNavigationGuard.canAccessTab(tab, auth),
        fallbackTab: AppNavigationGuard.schoolProfileTab,
      );
      return;
    }
    final fallback = AppNavigationGuard.firstAccessibleTab(auth);
    state.setTabAccessGuard(
      (tab) => AppNavigationGuard.canAccessTab(tab, auth),
      fallbackTab: fallback,
    );
    if (!AppNavigationGuard.canAccessTab(state.currentTab, auth)) {
      state.setTab(fallback);
    }
  }

  @override
  void initState() {
    super.initState();
    _unsubAuthExpired = apiClient.onAuthExpired((_) {
      appNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    });
    _unsubAccessDenied = apiClient.onAccessDenied((reason) {
      appScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.gpp_bad_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reason?.toString() ??
                      'Access denied (403): You do not have sufficient permission to access this resource.',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  void dispose() {
    _auth?.removeListener(_ensureAccessibleTab);
    _unsubAuthExpired?.call();
    _unsubAccessDenied?.call();
    _unsubLogout?.call();
    _unsubLogin?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.themeMode == ThemeMode.dark;
    final accent = appState.accent;

    return ShadTheme(
      data: AppTheme.shadTheme(
        accent,
        isDark ? Brightness.dark : Brightness.light,
      ),
      child: MaterialApp(
        title: 'Ilmiya - School Information System',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: appScaffoldMessengerKey,
        navigatorKey: appNavigatorKey,
        theme: AppTheme.lightTheme(accent),
        darkTheme: AppTheme.darkTheme(accent),
        themeMode: appState.themeMode,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        home: Consumer2<AppState, AuthNotifier>(
          builder: (context, state, auth, _) {
            return ListenableBuilder(
              listenable: apiClient,
              builder: (context, _) {
                if (!auth.isAuthenticated) {
                  return const LoginScreen();
                }
                final modeSuffix = apiClient.isMockMode ? 'mock' : 'live';
                return AdaptiveScaffold(
                  body: _LazyTabBody(
                    key: ValueKey(
                        'lazy_tab_${auth.sessionId}_${auth.tenantId}_$modeSuffix'),
                    currentTab: state.currentTab,
                    tenantId: auth.tenantId,
                    modeSuffix: modeSuffix,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LazyTabBody extends StatefulWidget {
  final int currentTab;
  final String tenantId;
  final String modeSuffix;

  const _LazyTabBody({
    super.key,
    required this.currentTab,
    required this.tenantId,
    required this.modeSuffix,
  });

  @override
  State<_LazyTabBody> createState() => _LazyTabBodyState();
}

class _LazyTabBodyState extends State<_LazyTabBody> {
  final Set<int> _activatedTabs = {};

  @override
  void initState() {
    super.initState();
    _activatedTabs.add(widget.currentTab);
  }

  @override
  void didUpdateWidget(covariant _LazyTabBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _activatedTabs.add(widget.currentTab);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.currentTab.clamp(0, 10),
      children: List.generate(11, (index) {
        if (!_activatedTabs.contains(index)) {
          return const SizedBox.shrink();
        }
        switch (index) {
          case 0:
            return SchoolProfileScreen(
                key: ValueKey(
                    'school_profile_${widget.tenantId}_${widget.modeSuffix}'));
          case 1:
            return AcademicYearsScreen(
                key: ValueKey(
                    'academic_years_${widget.tenantId}_${widget.modeSuffix}'));
          case 2:
            return IamManagementScreen(
                key: ValueKey(
                    'iam_management_${widget.tenantId}_${widget.modeSuffix}'));
          case 3:
            return const PreviewScreen();
          case 4:
            return DashboardScreen(
                key: ValueKey('dashboard_${widget.tenantId}'));
          case 5:
            return const GradesScreen();
          case 6:
            return const MessagingScreen();
          case 7:
            return const NotificationsScreen();
          case 8:
            return TenantManagementScreen(
                key: ValueKey(
                    'tenant_mgmt_${widget.tenantId}_${widget.modeSuffix}'));
          case 9:
            return SchoolsCampusesScreen(
                key: ValueKey(
                    'schools_campuses_${widget.tenantId}_${widget.modeSuffix}'));
          case 10:
            return UserProfileScreen(
                key: ValueKey(
                    'profile_${widget.tenantId}_${widget.modeSuffix}'));
          default:
            return const NotificationsScreen();
        }
      }),
    );
  }
}
