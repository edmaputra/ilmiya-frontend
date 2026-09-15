import 'package:flutter/material.dart';
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
              if (mounted) {
                Navigator.of(ctx).pop();
                _loadAcademicYears();
              }
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
                if (mounted) {
                  Navigator.of(ctx).pop();
                  _loadAcademicYears();
                }
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
    _loadAcademicYears();
  }

  Future<void> _handleActivateTerm(String yearId, String termId) async {
    await academicYearService.activateTerm(yearId, termId);
    _loadAcademicYears();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final canWrite = auth.hasPermission('academic:year:write');

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.forestSage));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.earthyTerra),
            const SizedBox(height: 12),
            Text(_error!),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Academic Years & Terms',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Configure institutional academic calendar periods and term boundaries.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: canWrite ? _showCreateYearDialog : null,
                icon: Icon(canWrite ? Icons.add_rounded : Icons.lock_outline, size: 16),
                label: const Text('New Academic Year'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Active Year Card
          if (_activeYear != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.forestSage.withOpacity(0.4), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.warmSand,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.star_rounded, color: AppColors.forestSage, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDEF7EC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'CURRENTLY ACTIVE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF03543F),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_activeYear!.startDate} to ${_activeYear!.endDate}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _activeYear!.name,
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: canWrite ? () => _showAddTermDialog(_activeYear!.id) : null,
                        icon: Icon(canWrite ? Icons.add : Icons.lock_outline, size: 14),
                        label: const Text('Add Term'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.forestSage,
                          side: const BorderSide(color: AppColors.borderMedium),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Terms & Semesters Breakdown',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  if (_activeYear!.terms.isEmpty)
                    const Text('No terms configured yet.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _activeYear!.terms.map((term) {
                        final isTermActive = term.status == 'ACTIVE';
                        return Container(
                          width: 240,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isTermActive ? AppColors.warmSand : AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isTermActive ? AppColors.forestSage : AppColors.borderLight,
                              width: isTermActive ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      term.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isTermActive ? AppColors.forestSage : AppColors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      term.status,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isTermActive ? Colors.white : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${term.startDate} → ${term.endDate}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                              if (!isTermActive && term.status != 'CONCLUDED') ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 26,
                                  child: OutlinedButton(
                                    onPressed: canWrite ? () => _handleActivateTerm(_activeYear!.id, term.id) : null,
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      foregroundColor: AppColors.forestSage,
                                    ),
                                    child: const Text('Activate Term', style: TextStyle(fontSize: 10)),
                                  ),
                                ),
                              ],
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.format_list_bulleted_rounded, color: AppColors.forestSage, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'All Institutional Calendars',
                      style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ..._academicYears.map((ay) {
                  final isActive = ay.status == 'ACTIVE';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.warmSand.withOpacity(0.3) : AppColors.naturalParchment,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isActive ? AppColors.forestSage : AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  ay.name,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive ? const Color(0xFFDEF7EC) : AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ay.status,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isActive ? const Color(0xFF03543F) : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Duration: ${ay.startDate} to ${ay.endDate} • ${ay.terms.length} Terms',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: canWrite ? () => _showAddTermDialog(ay.id) : null,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                foregroundColor: AppColors.textPrimary,
                              ),
                              child: const Text('+ Add Term', style: TextStyle(fontSize: 11)),
                            ),
                            if (!isActive) ...[
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: canWrite ? () => _handleActivateYear(ay.id) : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.forestSage,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                child: const Text('Activate', style: TextStyle(fontSize: 11)),
                              ),
                            ],
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
