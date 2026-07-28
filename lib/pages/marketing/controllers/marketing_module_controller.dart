import 'package:get/get.dart';
import '../models/marketing_lead.dart';
import '../models/marketing_campaign.dart';
import '../models/marketing_content.dart';
import '../models/marketing_team.dart';
import '../models/marketing_okr.dart';
import '../models/marketing_misc.dart';
import '../models/marketing_demo_data.dart';

class MarketingModuleController extends GetxController {
  // ─── DATA ──────────────────────────────────────────────────────
  var leads = <MarketingLead>[].obs;
  var campaigns = <MarketingCampaignV2>[].obs;
  var contentItems = <ContentCalendarItem>[].obs;
  var team = <MarketingTeamMember>[].obs;
  var okrs = <MarketingOKR>[].obs;
  var targets = <TargetRow>[].obs;
  var notifications = <MarketingNotification>[].obs;
  var whatsappConversations = <WhatsAppConversation>[].obs;
  var designTasks = <DesignTask>[].obs;
  var mediaAssets = <MediaAsset>[].obs;
  var broadcasts = <BroadcastRecord>[].obs;
  var tickets = <SupportTicket>[].obs;
  var realtors = <RealtorPartner>[].obs;
  var influencers = <InfluencerPartner>[].obs;
  var campaignTemplates = <CampaignTemplate>[].obs;

  // ─── PERSONA & ROUTING STATE ────────────────────────────────────
  var selectedPersona = 'all'.obs; // 'all', 'telemarketer', 'branch_manager', 'cmo'
  var selectedBranch = 'All Branches'.obs;
  var selectedPeriod = 'week'.obs;
  var isLoading = false.obs;

  void setPersona(String persona) => selectedPersona.value = persona;
  void setBranch(String branch) => selectedBranch.value = branch;

  // ─── DASHBOARD COMPUTED ────────────────────────────────────────
  List<MarketingLead> get filteredLeads {
    var result = leads.toList();
    if (selectedBranch.value != 'All Branches') {
      result = result.where((l) => l.campaign.contains(selectedBranch.value) || l.assignedTo.contains(selectedBranch.value)).toList();
    }
    if (selectedPersona.value == 'telemarketer') {
      // Telemarketers focus on new and contacted stage leads assigned to them or unassigned
      result = result.where((l) => l.stage == LeadStage.newLead || l.stage == LeadStage.contacted).toList();
    } else if (selectedPersona.value == 'branch_manager') {
      // Branch Managers focus on active proposal, qualified, and negotiation leads
      result = result.where((l) => l.stage == LeadStage.qualified || l.stage == LeadStage.proposal || l.stage == LeadStage.negotiation).toList();
    } else if (selectedPersona.value == 'cmo') {
      // CMO looks at overall high-value or won/qualified pipeline
      result = result.toList();
    }
    return result;
  }

  // Auto-distribute unassigned/new leads across branches
  void autoDistributeLeads() {
    final branches = ['Enugu', 'Abuja', 'Lagos', 'Port Harcourt'];
    for (int i = 0; i < leads.length; i++) {
      if (leads[i].stage == LeadStage.newLead) {
        final assignedBranch = branches[i % branches.length];
        leads[i] = MarketingLead(
          id: leads[i].id,
          name: leads[i].name,
          phone: leads[i].phone,
          division: leads[i].division,
          source: leads[i].source,
          campaign: '${leads[i].campaign} ($assignedBranch)',
          budget: leads[i].budget,
          stage: leads[i].stage,
          assignedTo: '${leads[i].assignedTo} - $assignedBranch Rep',
          value: leads[i].value,
          isOverdue: leads[i].isOverdue,
          activities: leads[i].activities,
        );
      }
    }
    leads.refresh();
  }

  int get totalLeads => filteredLeads.length;
  int get activeLeads =>
      filteredLeads.where((l) => l.stage != LeadStage.lost && l.stage != LeadStage.won).length;
  int get wonLeads => filteredLeads.where((l) => l.stage == LeadStage.won).length;
  int get overdueLeads => filteredLeads.where((l) => l.isOverdue).length;
  int get activeCampaigns =>
      campaigns.where((c) => c.status == CampaignStatus.active).length;
  int get pendingContent =>
      contentItems.where((c) => c.status != ContentStatus.published).length;
  int get unreadNotifications =>
      notifications.where((n) => !n.isRead).length;
  int get unreadWhatsApp =>
      whatsappConversations.where((w) => w.isUnread).length;

  Map<String, String> get currentPeriodData =>
      MarketingDemoData.periodData[selectedPeriod.value] ?? {};

  // Pipeline counts by stage
  Map<LeadStage, int> get pipelineCounts {
    final counts = <LeadStage, int>{};
    for (final stage in LeadStage.values) {
      counts[stage] = leads.where((l) => l.stage == stage).length;
    }
    return counts;
  }

  // Division breakdown
  Map<MarketingDivision, int> get divisionLeadCounts {
    final counts = <MarketingDivision, int>{};
    for (final div in MarketingDivision.values) {
      counts[div] = leads.where((l) => l.division == div).length;
    }
    return counts;
  }

  @override
  void onInit() {
    super.onInit();
    _loadDemoData();
  }

  void _loadDemoData() {
    isLoading.value = true;
    leads.assignAll(MarketingDemoData.leads);
    campaigns.assignAll(MarketingDemoData.campaigns);
    contentItems.assignAll(MarketingDemoData.contentItems);
    team.assignAll(MarketingDemoData.team);
    okrs.assignAll(MarketingDemoData.okrs);
    targets.assignAll(MarketingDemoData.targets);
    notifications.assignAll(MarketingDemoData.notifications);
    whatsappConversations.assignAll(MarketingDemoData.whatsappConversations);
    designTasks.assignAll(MarketingDemoData.designTasks);
    mediaAssets.assignAll(MarketingDemoData.mediaAssets);
    broadcasts.assignAll(MarketingDemoData.broadcasts);
    tickets.assignAll(MarketingDemoData.tickets);
    realtors.assignAll(MarketingDemoData.realtors);
    influencers.assignAll(MarketingDemoData.influencers);
    campaignTemplates.assignAll(MarketingDemoData.campaignTemplates);
    isLoading.value = false;
  }

  void setPeriod(String period) => selectedPeriod.value = period;

  void markNotificationRead(int index) {
    if (index < notifications.length) {
      notifications[index] = MarketingNotification(
        icon: notifications[index].icon,
        iconBg: notifications[index].iconBg,
        iconColor: notifications[index].iconColor,
        text: notifications[index].text,
        time: notifications[index].time,
        isRead: true,
      );
    }
  }
}
