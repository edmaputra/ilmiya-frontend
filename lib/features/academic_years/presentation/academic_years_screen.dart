import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/academic_year.dart';
import '../../../core/services/academic_year_service.dart';
import '../../../state/auth_notifier.dart';
import '../dialogs/add_academic_term_dialog.dart';
import '../dialogs/create_academic_year_dialog.dart';
import '../widgets/academic_year_catalog_card.dart';
import '../widgets/active_academic_year_card.dart';

class AcademicYearsScreen extends StatefulWidget {
  const AcademicYearsScreen({super.key});

  @override
  State<AcademicYearsScreen> createState() => _AcademicYearsScreenState();
}

class _AcademicYearsScreenState extends State<AcademicYearsScreen> {
  List<AcademicYearResponse> _academicYears = [];
  AcademicYearResponse? _activeYear;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAcademicYears();
  }

  Future<void> _loadAcademicYears() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await academicYearService.listAcademicYears();
      AcademicYearResponse? active;
      try {
        active = await academicYearService.getActiveAcademicYear();
      } catch (_) {
        active = list.isNotEmpty ? list.first : null;
      }
      active ??= (list.isNotEmpty ? list.first : null);

      if (mounted) {
        setState(() {
          _academicYears = list;
          _activeYear = active;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load academic calendars: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _showCreateYearDialog() {
    CreateAcademicYearDialog.show(
      context,
      onYearCreated: _loadAcademicYears,
    );
  }

  void _showAddTermDialog(String yearId) {
    AddAcademicTermDialog.show(
      context,
      yearId: yearId,
      onTermAdded: _loadAcademicYears,
    );
  }

  Future<void> _handleActivateYear(String yearId) async {
    await academicYearService.activateYear(yearId);
    if (mounted) await _loadAcademicYears();
  }

  Future<void> _handleActivateTerm(String yearId, String termId) async {
    await academicYearService.activateTerm(yearId, termId);
    if (mounted) await _loadAcademicYears();
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final auth = context.watch<AuthNotifier>();
    final canWrite = auth.hasPermission('academic:year:write');

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.circleAlert,
                size: 48, color: AppColors.earthyTerra),
            const SizedBox(height: 12),
            Text(_error!, style: t.p),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _loadAcademicYears, child: const Text('Retry')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Academic Years & Terms',
                    style: t.h2.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Configure institutional academic calendar periods and term boundaries.',
                    style: t.muted,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: canWrite ? _showCreateYearDialog : null,
                icon: Icon(canWrite ? LucideIcons.plus : LucideIcons.lock,
                    size: 16),
                label: const Text('New Academic Year'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  disabledBackgroundColor: c.muted,
                  disabledForegroundColor: c.mutedForeground,
                  shape: const RoundedRectangleBorder(
                      borderRadius: KiteRadius.allMd),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Active Year Card
          if (_activeYear != null) ...[
            ActiveAcademicYearCard(
              activeYear: _activeYear!,
              canWrite: canWrite,
              onAddTerm: () => _showAddTermDialog(_activeYear!.id),
              onActivateTerm: (termId) =>
                  _handleActivateTerm(_activeYear!.id, termId),
            ),
            const SizedBox(height: 24),
          ],

          // Catalog
          AcademicYearCatalogCard(
            academicYears: _academicYears,
            canWrite: canWrite,
            onAddTerm: _showAddTermDialog,
            onActivateYear: _handleActivateYear,
          ),
        ],
      ),
    );
  }
}
