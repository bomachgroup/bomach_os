import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PerformanceEnginePage extends StatelessWidget {
  const PerformanceEnginePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      header: const PageHeader(
        title: 'Performance Engine',
        subtitle:
            'Enterprise role, target, KPI and appraisal system — HR-owned, company-wide.',
      ),
      children: [
        // ── Unavailability banner ─────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE1A0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Iconsax.info_circle,
                  color: Color(0xFF8A5B00), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backend API not yet available',
                      style: AppTextStyles.bodySm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8A5B00),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The Performance Engine UI is ready and waiting. '
                      'The backend team needs to implement the performance API endpoints '
                      '(roles, scorecards, actuals, assignments) before live data can flow. '
                      'All modules below are previewed exactly as they will work.',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF8A5B00),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Module grid ───────────────────────────────────────────────────
        const _EngineModuleCard(
          icon: Iconsax.element_4,
          color: AppColors.primary,
          title: 'Performance Control Tower',
          endpoint: 'GET /api/v1/performance/employees',
          description:
              'Company-wide performance overview. Average scores, '
              'achievement rates, employees needing attention, and the 5P '
              'balanced lens (Productivity, Quality, Punctuality, Profit & Impact, Professionalism).',
          features: [
            'Average score across all employees',
            'Employees at risk vs. achieved',
            'Per-department performance bars',
            'Intelligent intervention feed',
          ],
        ),

        const _EngineModuleCard(
          icon: Iconsax.diagram,
          color: Color(0xFF6D55C7),
          title: 'Target Cascade',
          endpoint: 'GET /api/v1/performance/roles/{id}',
          description:
              'Company strategy → division → department → role → employee → '
              'daily work. Every employee can see how today\'s activity '
              'contributes to the annual target.',
          features: [
            'Company → role target inheritance',
            'Proration for leave & site duty',
            'Dependency visibility per KPI',
            'Cascade rules and override controls',
          ],
        ),

        const _EngineModuleCard(
          icon: Iconsax.people,
          color: Color(0xFF0F9D72),
          title: 'Role Library',
          endpoint: 'GET /api/v1/performance/roles',
          description:
              'The role outlives the employee. 15+ role templates '
              '(Marketing, Engineering, Finance, HR, Legal, Tech, Branch, etc.) '
              'with mission, routine, SOPs, targets and handover rules built in.',
          features: [
            'Role templates per department',
            'KPI target packs per role',
            'Source module per KPI',
            'Dependency and quality thresholds',
          ],
        ),

        const _EngineModuleCard(
          icon: Iconsax.chart_2,
          color: Color(0xFF246DDE),
          title: 'Target & KPI Designer',
          endpoint: 'POST /api/v1/performance/roles/{id}/targets',
          description:
              'Daily, weekly, monthly, quarterly and annual targets. '
              'Every KPI carries weight, source module, quality threshold, '
              'dependency, proration rule, and consequence/reward logic.',
          features: [
            'Frequency: daily / weekly / monthly / quarterly / yearly',
            'Weight per KPI (must total 100%)',
            'Quality gate to prevent quantity gaming',
            'Prorate for site duty, leave, late start',
          ],
        ),

        const _EngineModuleCard(
          icon: Iconsax.add_circle,
          color: Color(0xFFD58A00),
          title: 'Secondary Assignments',
          endpoint: 'POST /api/v1/performance/assignments',
          description:
              'Individual, project, team or acting responsibilities '
              'that layer on top of the primary role without changing it permanently. '
              'Includes expiry, weight, and a "promote to role template" option.',
          features: [
            'Individual / project / team assignment types',
            'Expiry date and weight',
            'Promote to permanent role template',
            'Does not modify primary role',
          ],
        ),

        const _EngineModuleCard(
          icon: Iconsax.refresh,
          color: Color(0xFF0F9D72),
          title: 'Role Continuity Packs',
          endpoint: 'GET /api/v1/performance/roles/{id}/continuity',
          description:
              'A replacement should be able to operate from the system '
              'without depending on the former employee. Each role carries '
              'a complete playbook: mission, routine, SOPs, tools, approvals, '
              'handover, and a first-10-days onboarding timeline.',
          features: [
            'Role mission and operating routine',
            'Core SOPs and tools',
            'Approval chains and escalation paths',
            'First 10 working days onboarding plan',
          ],
        ),

        const _EngineModuleCard(
          icon: Iconsax.clipboard_text,
          color: AppColors.primary,
          title: 'Employee Scorecards',
          endpoint: 'GET /api/v1/performance/employees/{id}/scorecard',
          description:
              'Live balanced scorecards assembled from role targets + '
              'secondary assignments + actual module data + approved exceptions. '
              'Score = Targets (50%) + Quality (15%) + Timeliness (10%) + '
              'Impact (15%) + Professionalism (10%) + Points.',
          features: [
            'Real-time score with target achievement breakdown',
            'Site-duty and leave proration applied',
            'Performance band (Exceptional → Off Target)',
            'Trend visible per period',
          ],
        ),

        const _EngineModuleCard(
          icon: Iconsax.award,
          color: Color(0xFFD64545),
          title: 'Appraisal & Rewards',
          endpoint: 'GET /api/v1/performance/appraisals',
          description:
              'Fair appraisal across all employees. Achievement bands, '
              'recognition points, accountability points, and consequence '
              'recommendations — all requiring HR/Finance policy approval '
              'before any payroll action.',
          features: [
            'Achievement bands: Exceptional / Exceeds / Achieved / Needs / Off',
            'Positive and accountability performance points',
            'Fairness controls (forced distribution cap)',
            'No automatic payroll deduction — approval required',
          ],
        ),

        const _EngineModuleCard(
          icon: Iconsax.flash,
          color: Color(0xFF6D55C7),
          title: 'Intelligent Next Actions',
          endpoint: 'GET /api/v1/performance/employees/{id}/actions',
          description:
              'The system intervenes before period-end failure. It checks '
              'off-track metrics, verifies dependencies, and generates specific '
              'guidance for the employee and escalation items for their manager.',
          features: [
            'Early warning before month-end failure',
            'Dependency-aware (flags upstream blockers)',
            'Employee guidance cards',
            'Manager intervention recommendations',
          ],
        ),

        const _EngineModuleCard(
          icon: Iconsax.hierarchy,
          color: Color(0xFF0F9D72),
          title: 'Module Data Bridge',
          endpoint: 'POST /api/v1/performance/actuals',
          description:
              'HR defines targets. Marketing, Finance, Operations, Service, '
              'Engineering, Survey, Legal and Tech are the source of truth '
              'for actual work. Each module posts actuals via the bridge; '
              'the engine recomputes scores automatically.',
          features: [
            'Source modules: Marketing, Finance, Operations, Engineering…',
            'Event-driven: lead.qualified, payment.confirmed, drawing.approved…',
            'Evidence reference attached to each actual',
            'Triggers target.at_risk and appraisal recompute',
          ],
        ),
      ],
    );
  }
}

// ── Internal widget ──────────────────────────────────────────────────────────

class _EngineModuleCard extends StatelessWidget {
  const _EngineModuleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.endpoint,
    required this.description,
    required this.features,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String endpoint;
  final String description;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: AppCardElevation.sm,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.bodyMd
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      endpoint,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Unavailable chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFE08A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD58A00),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Not available yet',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF8A5B00),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 14),

          // Description
          Text(
            description,
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.textSecondary, height: 1.55),
          ),

          const SizedBox(height: 14),

          // Feature bullets
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: features
                .map(
                  (f) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.tick_circle,
                            size: 12,
                            color: color.withValues(alpha: 0.8)),
                        const SizedBox(width: 5),
                        Text(f,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
