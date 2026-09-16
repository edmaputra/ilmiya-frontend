import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/academic_year.dart';
import '../../../core/services/academic_year_service.dart';
import '../../../state/auth_notifier.dart';

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
      final years = await academicYearService.listAcademicYears();
      final active = await academicYearService.getActiveAcademicYear();
      if (mounted) {
        setState(() {
          _academicYears = years;
          _activeYear = active;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load academic years: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _showCreateYearDialog() {
    final nameCtrl = TextEditingController(text: 'Tahun Ajaran 2027/2028');
    final startCtrl = TextEditingController(text: '2027-07-15');
    final endCtrl = TextEditingController(text: '2028-06-25');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: AppColors.forestSage),
            SizedBox(width: 8),
            Text('New Academic Year', style: TextStyle(fontFamily: 'serif', fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Academic Year Name')),
            const SizedBox(height: 10),
            TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)')),
            const SizedBox(height: 10),
            TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: Colors.white),
            onPressed: () async {
              await academicYearService.createAcademicYear(CreateAcademicYearRequest(
                name: nameCtrl.text.trim(),
                startDate: startCtrl.text.trim(),
                endDate: endCtrl.text.trim(),
              ));
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) await _loadAcademicYears();
            },
            child: const Text('Create Calendar Year'),
          ),
        ],
      ),
    );
  }

  void _showAddTermDialog(String yearId) {
    final nameCtrl = TextEditingController(text: 'Semester 1 (Ganjil)');
    final displayCtrl = TextEditingController(text: 'Ganjil Term');
    final startCtrl = TextEditingController(text: '2026-07-15');
    final endCtrl = TextEditingController(text: '2026-12-20');
    String termType = 'SEMESTER_1';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.date_range_rounded, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text('Add Academic Term', style: TextStyle(fontFamily: 'serif', fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Term Name')),
              const SizedBox(height: 10),
              TextField(controller: displayCtrl, decoration: const InputDecoration(labelText: 'Display Label')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: termType,
                decoration: const InputDecoration(labelText: 'Term Type'),
                items: const [
                  DropdownMenuItem(value: 'SEMESTER_1', child: Text('Semester 1 (Ganjil)')),
                  DropdownMenuItem(value: 'SEMESTER_2', child: Text('Semester 2 (Genap)')),
                  DropdownMenuItem(value: 'TRIMESTER_1', child: Text('Trimester 1')),
                  DropdownMenuItem(value: 'QUARTER_1', child: Text('Quarter 1')),
                ],
                onChanged: (v) => setDlgState(() => termType = v ?? termType),
              ),
              const SizedBox(height: 10),
              TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start Date')),
              const SizedBox(height: 10),
              TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'End Date')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: Colors.white),
              onPressed: () async {
                await academicYearService.addTerm(yearId, AddAcademicTermRequest(
                  name: nameCtrl.text.trim(),
                  displayName: displayCtrl.text.trim(),
                  type: termType,
                  startDate: startCtrl.text.trim(),
                  endDate: endCtrl.text.trim(),
                ));
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) await _loadAcademicYears();
              },
              child: const Text('Add Term'),
            ),
          ],
        ),
      ),
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
            const Icon(LucideIcons.circleAlert, size: 48, color: AppColors.earthyTerra),
            const SizedBox(height: 12),
            Text(_error!, style: t.p),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadAcademicYears, child: const Text('Retry')),
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
                    style: t.h2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                icon: Icon(canWrite ? LucideIcons.plus : LucideIcons.lock, size: 16),
                label: const Text('New Academic Year'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  disabledBackgroundColor: c.muted,
                  disabledForegroundColor: c.mutedForeground,
                  shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allMd),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Active Year Card
          if (_activeYear != null) ...[
            KiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: c.accent,
                              borderRadius: KiteRadius.allMd,
                            ),
                            child: Icon(LucideIcons.star, color: c.primary, size: 20),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const KiteBadge(
                                    'CURRENTLY ACTIVE',
                                    tone: KiteTone.success,
                                  ),
                                  Text(
                                    '${_activeYear!.startDate} to ${_activeYear!.endDate}',
                                    style: t.small.copyWith(color: c.mutedForeground),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _activeYear!.name,
                                style: t.large.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: canWrite ? () => _showAddTermDialog(_activeYear!.id) : null,
                        icon: Icon(canWrite ? LucideIcons.plus : LucideIcons.lock, size: 14),
                        label: const Text('Add Term'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.foreground,
                          side: BorderSide(color: c.border),
                          shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allMd),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24, color: c.border),
                  Text(
                    'Terms & Semesters Breakdown',
                    style: t.small.copyWith(fontWeight: FontWeight.bold, color: c.foreground),
                  ),
                  const SizedBox(height: 12),
                  if (_activeYear!.terms.isEmpty)
                    Text('No terms configured yet.', style: t.small.copyWith(color: c.mutedForeground))
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _activeYear!.terms.map((term) {
                        final isTermActive = term.status == 'ACTIVE';
                        return Container(
                          width: 240,
                          constraints: const BoxConstraints(minHeight: 112),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isTermActive ? c.accent : c.card,
                            borderRadius: KiteRadius.allMd,
                            border: Border.all(
                              color: isTermActive ? c.primary : c.border,
                              width: isTermActive ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          term.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: t.small.copyWith(fontWeight: FontWeight.bold, color: c.foreground),
                                        ),
                                      ),
                                      KiteBadge(
                                        term.status,
                                        tone: isTermActive ? KiteTone.success : KiteTone.neutral,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${term.startDate} → ${term.endDate}',
                                    style: t.small.copyWith(fontSize: 10, color: c.mutedForeground),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 28,
                                child: isTermActive
                                    ? Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.forestSage.withOpacity(0.12),
                                          borderRadius: KiteRadius.allSm,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(LucideIcons.check, size: 12, color: AppColors.forestSage),
                                            SizedBox(width: 4),
                                            Text(
                                              'Active Term',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.forestSage,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : (term.status == 'CONCLUDED'
                                        ? Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: c.muted.withOpacity(0.35),
                                              borderRadius: KiteRadius.allSm,
                                            ),
                                            child: Text(
                                              'Term Concluded',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: c.mutedForeground,
                                              ),
                                            ),
                                          )
                                        : OutlinedButton(
                                            onPressed: canWrite ? () => _handleActivateTerm(_activeYear!.id, term.id) : null,
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              foregroundColor: c.primary,
                                              side: BorderSide(color: c.border),
                                              shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allSm),
                                            ),
                                            child: const Text('Activate Term', style: TextStyle(fontSize: 10)),
                                          )),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Catalog
          KiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.calendarDays, color: c.foreground, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All Institutional Calendars',
                        style: t.large.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, color: c.border),
                ..._academicYears.map((ay) {
                  final isActive = ay.status == 'ACTIVE';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isActive ? c.accent.withOpacity(0.4) : c.card,
                      borderRadius: KiteRadius.allMd,
                      border: Border.all(color: isActive ? c.primary : c.border),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  ay.name,
                                  style: t.small.copyWith(fontSize: 13, fontWeight: FontWeight.bold, color: c.foreground),
                                ),
                                KiteBadge(
                                  ay.status,
                                  tone: isActive ? KiteTone.success : KiteTone.neutral,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Duration: ${ay.startDate} to ${ay.endDate} • ${ay.terms.length} Terms',
                              style: t.small.copyWith(fontSize: 11, color: c.mutedForeground),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: canWrite ? () => _showAddTermDialog(ay.id) : null,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                foregroundColor: c.foreground,
                                side: BorderSide(color: c.border),
                                shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allSm),
                              ),
                              child: const Text('+ Add Term', style: TextStyle(fontSize: 11)),
                            ),
                            if (!isActive)
                              ElevatedButton(
                                onPressed: canWrite ? () => _handleActivateYear(ay.id) : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: c.primary,
                                  foregroundColor: c.primaryForeground,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allSm),
                                ),
                                child: const Text('Activate', style: TextStyle(fontSize: 11)),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.forestSage.withOpacity(0.12),
                                  borderRadius: KiteRadius.allSm,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.check, size: 12, color: AppColors.forestSage),
                                    SizedBox(width: 4),
                                    Text(
                                      'Active',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.forestSage,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
