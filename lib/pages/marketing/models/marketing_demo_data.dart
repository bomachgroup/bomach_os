import 'package:flutter/material.dart';
import 'marketing_lead.dart';
import 'marketing_campaign.dart';
import 'marketing_content.dart';
import 'marketing_team.dart';
import 'marketing_okr.dart';
import 'marketing_misc.dart';

class MarketingDemoData {
  MarketingDemoData._();

  // ─── LEADS ─────────────────────────────────────────────────────

  static final List<MarketingLead> leads = [
    MarketingLead(
      id: 'L-2247',
      name: 'Adaeze Chukwu',
      phone: '08031234567',
      division: MarketingDivision.re,
      source: 'Facebook Ad',
      campaign: 'Bethel City Estate Launch',
      budget: '₦3M – ₦8M',
      stage: LeadStage.proposal,
      assignedTo: 'Emeka Obi',
      value: '₦4.5M',
      activities: const [
        LeadActivity(
          title: 'Proposal sent via WhatsApp',
          meta: 'Jul 13, 2:15PM · Emeka Obi · Bethel City plot — ₦4.5M, 30% down',
        ),
        LeadActivity(
          title: 'Qualification call completed',
          meta: 'Jul 12, 11:30AM · Emeka Obi · Budget confirmed ₦3-8M, decision-maker, ready Q3',
        ),
        LeadActivity(
          title: 'Follow-up WhatsApp sent',
          meta: 'Jul 11, 9:00AM · Emeka Obi · Sent estate brochure and video',
        ),
        LeadActivity(
          title: 'Lead registered',
          meta: 'Jul 10, 3:45PM · Facebook Ad · Bethel City Estate Launch campaign',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2248',
      name: 'Emmanuel Okonkwo',
      phone: '07041234567',
      division: MarketingDivision.eng,
      source: 'Referral',
      budget: '₦25M – ₦35M',
      stage: LeadStage.negotiation,
      assignedTo: 'Peace C.',
      value: '₦28M',
      activities: const [
        LeadActivity(
          title: 'Negotiation call — pricing discussion',
          meta: 'Jul 13, 4:00PM · Peace C. · Discussing phased payment structure',
        ),
        LeadActivity(
          title: 'Site assessment completed',
          meta: 'Jul 11, 10:00AM · Head of Operations · 5-bed duplex, foundation confirmed viable',
        ),
        LeadActivity(
          title: 'Lead registered',
          meta: 'Jul 5, 1:20PM · Referral from existing client',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2249',
      name: 'Ngozi Kamalu',
      phone: '08112345678',
      division: MarketingDivision.ben,
      source: 'Field outreach',
      campaign: 'ESUT Campus Activation',
      stage: LeadStage.won,
      assignedTo: 'Emeka Obi',
      value: '₦3.5M',
      activities: const [
        LeadActivity(
          title: 'Deal won — vendor account activated',
          meta: 'Jul 12, 3:00PM · Emeka Obi · Vendor onboarded successfully',
        ),
        LeadActivity(
          title: 'Lead registered',
          meta: 'Jul 8, 9:00AM · Field outreach at ESUT campus',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2250',
      name: 'Festus Ikenna',
      phone: '09012345678',
      division: MarketingDivision.sur,
      source: 'WhatsApp',
      budget: '₦350K',
      stage: LeadStage.contacted,
      assignedTo: 'Chioma S.',
      value: '₦350K',
      activities: const [
        LeadActivity(
          title: 'Follow-up call scheduled',
          meta: 'Jul 14, 9:00AM · Chioma S. · Discussed title documentation requirements',
        ),
        LeadActivity(
          title: 'Lead registered',
          meta: 'Jul 12, 6:15PM · WhatsApp enquiry',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2251',
      name: 'Bello Kabiru',
      phone: '08031239876',
      division: MarketingDivision.re,
      source: 'Facebook Ad',
      campaign: 'Bethel City Estate Launch',
      budget: '₦5M',
      stage: LeadStage.newLead,
      assignedTo: 'Emeka Obi',
      value: '₦5M',
      isOverdue: true,
      activities: const [
        LeadActivity(
          title: 'Lead registered — no contact yet',
          meta: 'Jul 10, 2:00PM · Facebook Ad · Awaiting first contact',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2252',
      name: 'Chioma Uche',
      phone: '07031234567',
      division: MarketingDivision.ben,
      source: 'Instagram',
      campaign: 'ESUT Campus Activation',
      stage: LeadStage.newLead,
      assignedTo: 'Chioma S.',
      activities: const [
        LeadActivity(
          title: 'Lead registered',
          meta: 'Jul 13, 8:00AM · Instagram DM enquiry',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2253',
      name: 'Obinna Obi',
      phone: '08021234567',
      division: MarketingDivision.re,
      source: 'Referral',
      budget: '₦5M – ₦7M',
      stage: LeadStage.qualified,
      assignedTo: 'Emeka Obi',
      value: '₦6M',
      activities: const [
        LeadActivity(
          title: 'Qualification completed — budget confirmed',
          meta: 'Jul 9, 3:00PM · Emeka Obi · Ready to proceed within 30 days',
        ),
        LeadActivity(
          title: 'Lead registered',
          meta: 'Jul 8, 11:00AM · Referral from Chukwudi Habitat Agency',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2254',
      name: 'Ifeoma Nze',
      phone: '07031239876',
      division: MarketingDivision.agr,
      source: 'WhatsApp',
      budget: 'Bulk supply',
      stage: LeadStage.proposal,
      assignedTo: 'Peace C.',
      value: '₦2.1M',
      activities: const [
        LeadActivity(
          title: 'Supply proposal sent',
          meta: 'Jul 11, 1:00PM · Peace C. · Monthly cassava & garri supply contract',
        ),
        LeadActivity(
          title: 'Lead registered',
          meta: 'Jul 9, 4:30PM · WhatsApp enquiry from restaurant chain',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2255',
      name: 'Peter Ani',
      phone: '08031239900',
      division: MarketingDivision.ict,
      source: 'LinkedIn',
      budget: '₦800K',
      stage: LeadStage.contacted,
      assignedTo: 'Chioma S.',
      value: '₦800K',
      isOverdue: true,
      activities: const [
        LeadActivity(
          title: 'First contact made',
          meta: 'Jul 12, 10:00AM · Chioma S. · Discussed website development needs',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2256',
      name: 'Chika Mbah',
      phone: '07041239876',
      division: MarketingDivision.eng,
      source: 'Referral',
      budget: '₦12M',
      stage: LeadStage.qualified,
      assignedTo: 'Peace C.',
      value: '₦12M',
      activities: const [
        LeadActivity(
          title: 'Site visit booked',
          meta: 'Jul 8, 2:00PM · Peace C. · Scheduled for Jul 20',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2257',
      name: 'Kalu Bright',
      phone: '08021239876',
      division: MarketingDivision.re,
      source: 'Facebook Ad',
      campaign: 'Bethel City Estate Launch',
      budget: '₦3M',
      stage: LeadStage.lost,
      assignedTo: 'Emeka Obi',
      activities: const [
        LeadActivity(
          title: 'Marked as lost — budget mismatch',
          meta: 'Jun 30, 5:00PM · Emeka Obi · Client\'s available budget below minimum plot price',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2258',
      name: 'Ada Nwoji',
      phone: '07031230000',
      division: MarketingDivision.re,
      source: 'Instagram',
      campaign: 'Bethel City Estate Launch',
      budget: '₦4M',
      stage: LeadStage.contacted,
      assignedTo: 'Emeka Obi',
      value: '₦4M',
      activities: const [
        LeadActivity(
          title: 'First WhatsApp contact',
          meta: 'Jul 13, 1:00PM · Emeka Obi · Interested in 2-plot combo',
        ),
      ],
    ),
    MarketingLead(
      id: 'L-2259',
      name: 'Blessing Agu',
      phone: '08031231234',
      division: MarketingDivision.re,
      source: 'WhatsApp',
      budget: '₦6.5M',
      stage: LeadStage.negotiation,
      assignedTo: 'Peace C.',
      value: '₦6.5M',
      activities: const [
        LeadActivity(
          title: 'Negotiating payment terms',
          meta: 'Jul 12, 4:30PM · Peace C. · Discussing 40% down vs 30% down options',
        ),
      ],
    ),
  ];

  // ─── CAMPAIGNS ─────────────────────────────────────────────────

  static final List<MarketingCampaignV2> campaigns = [
    const MarketingCampaignV2(
      name: 'Bethel City Estate Launch',
      division: MarketingDivision.re,
      status: CampaignStatus.active,
      budget: 1000000,
      spent: 680000,
      leads: 68,
      costPerLead: '₦6.2K',
      conversionRate: '19.2%',
      daysActive: 12,
      channels: 'Facebook + Instagram',
    ),
    const MarketingCampaignV2(
      name: 'ESUT Campus Activation',
      division: MarketingDivision.ben,
      status: CampaignStatus.active,
      budget: 1100000,
      spent: 385000,
      leads: 142,
      costPerLead: '₦2.8K',
      conversionRate: '—',
      daysActive: 19,
      channels: 'TikTok + Field + Stickers',
    ),
    const MarketingCampaignV2(
      name: 'Engineering Excellence Series',
      division: MarketingDivision.eng,
      status: CampaignStatus.draft,
      budget: 350000,
      channels: 'LinkedIn + WhatsApp',
    ),
    const MarketingCampaignV2(
      name: 'Know Your Land Campaign',
      division: MarketingDivision.sur,
      status: CampaignStatus.active,
      budget: 200000,
      spent: 140000,
      leads: 28,
      costPerLead: '₦5K',
      conversionRate: '28%',
      daysActive: 5,
      channels: 'Facebook + WhatsApp',
    ),
  ];

  // ─── CONTENT ───────────────────────────────────────────────────

  static final List<ContentCalendarItem> contentItems = [
    const ContentCalendarItem(
      title: 'Bethel City estate walkthrough',
      format: 'Video',
      platform: 'Instagram',
      division: MarketingDivision.re,
      owner: 'Williams F.',
      status: ContentStatus.published,
      dueDate: 'Jul 14',
    ),
    const ContentCalendarItem(
      title: '"Survey before you build"',
      format: 'Carousel',
      platform: 'Facebook',
      division: MarketingDivision.sur,
      owner: 'Creator',
      status: ContentStatus.published,
      dueDate: 'Jul 14',
    ),
    const ContentCalendarItem(
      title: 'Benji delivery speed demo',
      format: 'TikTok',
      platform: 'TikTok',
      division: MarketingDivision.ben,
      owner: 'Williams F.',
      status: ContentStatus.inReview,
      dueDate: 'Jul 15',
    ),
    const ContentCalendarItem(
      title: 'Client testimonial — Adaeze',
      format: 'Graphic',
      platform: 'Instagram',
      division: MarketingDivision.re,
      owner: 'Designer',
      status: ContentStatus.briefed,
      dueDate: 'Jul 16',
    ),
    const ContentCalendarItem(
      title: 'Weekly property WA broadcast',
      format: 'Text+Image',
      platform: 'WhatsApp',
      division: MarketingDivision.re,
      owner: 'Sales Rep',
      status: ContentStatus.overdue,
      dueDate: 'Jul 13',
    ),
    const ContentCalendarItem(
      title: 'Bomach OS feature spotlight',
      format: 'Carousel',
      platform: 'LinkedIn',
      division: MarketingDivision.ict,
      owner: 'Creator',
      status: ContentStatus.inProgress,
      dueDate: 'Jul 17',
    ),
    const ContentCalendarItem(
      title: 'Benji vendor onboarding explainer',
      format: 'Video',
      platform: 'TikTok',
      division: MarketingDivision.ben,
      owner: 'Williams F.',
      status: ContentStatus.inProgress,
      dueDate: 'Jul 15',
    ),
    const ContentCalendarItem(
      title: 'Engineering project showcase',
      format: 'Carousel',
      platform: 'Instagram',
      division: MarketingDivision.eng,
      owner: 'Designer',
      status: ContentStatus.inReview,
      dueDate: 'Jul 16',
    ),
  ];

  // ─── TEAM ──────────────────────────────────────────────────────

  static final List<MarketingTeamMember> team = [
    const MarketingTeamMember(
      name: 'Engr. Tochukwu David',
      role: 'CEO & Founder',
      initials: 'TD',
      backgroundColor: Color(0xFFCC0000),
      status: 'online',
      phone: '09018000118',
      stat: 'Oversees all divisions',
      kpiPercentage: 0,
    ),
    const MarketingTeamMember(
      name: 'Peace Chukwuwike',
      role: 'Acting Marketing Coordinator',
      initials: 'PC',
      backgroundColor: Color(0xFF1F3D7A),
      status: 'online',
      phone: '08031112222',
      stat: '88% KPI compliance',
      kpiPercentage: 88,
      kpiColor: Color(0xFF059669),
      kpiStatus: 'On target',
    ),
    const MarketingTeamMember(
      name: 'Emeka Obi',
      role: 'Sales Representative',
      initials: 'EO',
      backgroundColor: Color(0xFF0A6B3E),
      status: 'online',
      phone: '08033334444',
      stat: '92% — top performer',
      kpiPercentage: 92,
      kpiColor: Color(0xFF059669),
      kpiStatus: 'On target',
    ),
    const MarketingTeamMember(
      name: 'Chioma Sale',
      role: 'Sales Representative',
      initials: 'CS',
      backgroundColor: Color(0xFF0A6B3E),
      status: 'away',
      phone: '08035556666',
      stat: '72% — on track',
      kpiPercentage: 72,
      kpiColor: Color(0xFFD97706),
      kpiStatus: 'Close',
    ),
    const MarketingTeamMember(
      name: 'Williams Favor',
      role: 'Videographer / Content Director',
      initials: 'WF',
      backgroundColor: Color(0xFFCC0000),
      status: 'online',
      phone: '08037778888',
      stat: '78% — close to target',
      kpiPercentage: 78,
      kpiColor: Color(0xFFD97706),
      kpiStatus: 'Close',
    ),
    const MarketingTeamMember(
      name: 'Content Creator',
      role: 'Content Creator',
      initials: 'CC',
      backgroundColor: Color(0xFF7C3AED),
      status: 'online',
      phone: '08039990000',
      stat: '5 items delivered this week',
      kpiPercentage: 70,
      kpiColor: Color(0xFFD97706),
      kpiStatus: 'Close',
    ),
    const MarketingTeamMember(
      name: 'Digital Marketer',
      role: 'Digital Marketing Specialist',
      initials: 'DM',
      backgroundColor: Color(0xFFB87D00),
      status: 'online',
      phone: '08031234000',
      stat: '85% — ad performance strong',
      kpiPercentage: 85,
      kpiColor: Color(0xFF059669),
      kpiStatus: 'On target',
    ),
    const MarketingTeamMember(
      name: 'Graphic Designer',
      role: 'Creative / Graphic Designer',
      initials: 'GD',
      backgroundColor: Color(0xFF7C3AED),
      status: 'offline',
      phone: '08035671234',
      stat: '65% — needs attention',
      kpiPercentage: 65,
      kpiColor: Color(0xFFDC2626),
      kpiStatus: 'Below target',
    ),
    const MarketingTeamMember(
      name: 'Customer Care Officer',
      role: 'Customer Support',
      initials: 'CO',
      backgroundColor: Color(0xFF0A6B3E),
      status: 'online',
      phone: '08039871234',
      stat: '95% response rate',
      kpiPercentage: 95,
      kpiColor: Color(0xFF059669),
      kpiStatus: 'On target',
    ),
    const MarketingTeamMember(
      name: 'Business Developer',
      role: 'Business Development',
      initials: 'BD',
      backgroundColor: Color(0xFF1F3D7A),
      status: 'away',
      phone: '08032221111',
      stat: '70% — partner outreach',
      kpiPercentage: 70,
      kpiColor: Color(0xFFD97706),
      kpiStatus: 'Close',
    ),
    const MarketingTeamMember(
      name: 'Partner Manager',
      role: 'Partnerships & Media',
      initials: 'PM',
      backgroundColor: Color(0xFFB87D00),
      status: 'online',
      phone: '08034445555',
      stat: '7 active realtor partners',
      kpiPercentage: 80,
      kpiColor: Color(0xFF059669),
      kpiStatus: 'On target',
    ),
    const MarketingTeamMember(
      name: 'Analytics Officer',
      role: 'Analytics & Insights',
      initials: 'AN',
      backgroundColor: Color(0xFF6B7280),
      status: 'offline',
      phone: '08036667777',
      stat: 'Weekly reports on schedule',
      kpiPercentage: 82,
      kpiColor: Color(0xFF059669),
      kpiStatus: 'On target',
    ),
  ];

  // ─── OKRs ──────────────────────────────────────────────────────

  static final List<MarketingOKR> okrs = [
    MarketingOKR(
      objective: 'O1 — Generate ₦85M monthly revenue across all divisions',
      keyResults: const [
        KeyResult(label: 'Real Estate closes ₦30M/month', percentage: 93, color: Color(0xFF059669)),
        KeyResult(label: 'Benji generates ₦15M/month', percentage: 47, color: Color(0xFFDC2626)),
        KeyResult(label: 'Engineering closes ₦20M/month', percentage: 60, color: Color(0xFFD97706)),
        KeyResult(label: 'Surveying closes ₦5M/month', percentage: 84, color: Color(0xFF059669)),
      ],
    ),
    MarketingOKR(
      objective: 'O2 — Consistently generate 100+ qualified leads per week',
      keyResults: const [
        KeyResult(label: '100+ leads/week for 8 consecutive weeks', percentage: 82, color: Color(0xFFD97706)),
        KeyResult(label: '100% of leads contacted within 2 hours', percentage: 91, color: Color(0xFF059669)),
        KeyResult(label: 'Conversion rate reaches 25%', percentage: 73, color: Color(0xFFD97706)),
      ],
    ),
    MarketingOKR(
      objective: 'O3 — Build a world-class content machine',
      keyResults: const [
        KeyResult(label: '20 content pieces published every week', percentage: 68, color: Color(0xFFD97706)),
        KeyResult(label: 'Average reach of 5,000+ per piece', percentage: 55, color: Color(0xFFDC2626)),
        KeyResult(label: '50+ WhatsApp broadcast responses/week', percentage: 76, color: Color(0xFFD97706)),
      ],
    ),
    MarketingOKR(
      objective: 'O4 — Activate and grow partner and media network',
      keyResults: const [
        KeyResult(label: '10 active realtor partners generating leads', percentage: 30, color: Color(0xFFDC2626)),
        KeyResult(label: '5 active influencer partnerships', percentage: 40, color: Color(0xFFDC2626)),
        KeyResult(label: '3 active radio/TV placements', percentage: 67, color: Color(0xFFD97706)),
      ],
    ),
  ];

  // ─── TARGETS ───────────────────────────────────────────────────

  static final List<TargetRow> targets = [
    const TargetRow(label: 'Leads generated', target: '100', actual: '127', percentage: 127, color: Color(0xFF059669)),
    const TargetRow(label: 'Leads contacted within 2h', target: '100%', actual: '91%', percentage: 91, color: Color(0xFFD97706)),
    const TargetRow(label: 'Content pieces published', target: '20', actual: '17', percentage: 85, color: Color(0xFFD97706)),
    const TargetRow(label: 'Deals closed', target: '5', actual: '4', percentage: 80, color: Color(0xFFD97706)),
    const TargetRow(label: 'Revenue closed', target: '₦21.25M', actual: '₦14.2M', percentage: 67, color: Color(0xFFDC2626)),
    const TargetRow(label: 'New Benji vendors onboarded', target: '10', actual: '6', percentage: 60, color: Color(0xFFDC2626)),
    const TargetRow(label: 'Follow-up cadence compliance', target: '100%', actual: '84%', percentage: 84, color: Color(0xFFD97706)),
  ];

  // ─── NOTIFICATIONS ─────────────────────────────────────────────

  static final List<MarketingNotification> notifications = [
    MarketingNotification(
      icon: 'ti-alert-triangle',
      iconBg: const Color(0xFFFEE2E2),
      iconColor: const Color(0xFFDC2626),
      text: '5 leads overdue for follow-up — oldest is 3 days',
      time: '5 min ago',
    ),
    MarketingNotification(
      icon: 'ti-photo',
      iconBg: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFD97706),
      text: 'Content 3 pieces behind weekly target',
      time: '1 hour ago',
    ),
    MarketingNotification(
      icon: 'ti-check',
      iconBg: const Color(0xFFD1FAE5),
      iconColor: const Color(0xFF059669),
      text: 'Deal won — Ngozi Kamalu closed ₦3.5M',
      time: '2 hours ago',
    ),
    MarketingNotification(
      icon: 'ti-users',
      iconBg: const Color(0xFFDBEAFE),
      iconColor: const Color(0xFF1E40AF),
      text: '3 influencer proposals pending your approval',
      time: '3 hours ago',
    ),
    MarketingNotification(
      icon: 'ti-headset',
      iconBg: const Color(0xFFFCE7F3),
      iconColor: const Color(0xFF9D174D),
      text: 'Urgent support ticket opened — Benji vendor issue',
      time: 'Yesterday',
      isRead: true,
    ),
  ];

  // ─── WHATSAPP ──────────────────────────────────────────────────

  static final List<WhatsAppConversation> whatsappConversations = [
    const WhatsAppConversation(
      id: 'wa1',
      initials: 'AC',
      bgColor: Color(0xFFDBEAFE),
      textColor: Color(0xFF1E40AF),
      name: 'Adaeze Chukwu',
      time: '2m ago',
      isUnread: true,
      thread: [
        WhatsAppMessage(
          isOutgoing: false,
          text: 'Good morning, please I want to know more about the payment plan for Bethel City',
          time: '9:02 AM',
        ),
      ],
    ),
    const WhatsAppConversation(
      id: 'wa2',
      initials: 'EO',
      bgColor: Color(0xFFFEF3C7),
      textColor: Color(0xFF92400E),
      name: 'Emmanuel Okonkwo',
      time: '15m ago',
      isUnread: true,
      thread: [
        WhatsAppMessage(
          isOutgoing: false,
          text: 'Can we schedule the site visit for Saturday morning?',
          time: '8:48 AM',
        ),
      ],
    ),
    const WhatsAppConversation(
      id: 'wa3',
      initials: 'NK',
      bgColor: Color(0xFFEDE9FE),
      textColor: Color(0xFF5B21B6),
      name: 'Ngozi Kamalu',
      time: '1h ago',
      thread: [
        WhatsAppMessage(
          isOutgoing: false,
          text: 'Thank you so much! When will my vendor account be activated?',
          time: '8:00 AM',
        ),
        WhatsAppMessage(
          isOutgoing: true,
          text: 'Hi Ngozi! Your vendor account is now active. You can start listing products right away 🎉',
          time: '8:05 AM',
        ),
      ],
    ),
    const WhatsAppConversation(
      id: 'wa4',
      initials: 'FI',
      bgColor: Color(0xFFD1FAE5),
      textColor: Color(0xFF065F46),
      name: 'Festus Ikenna',
      time: '2h ago',
      thread: [
        WhatsAppMessage(
          isOutgoing: false,
          text: 'What documents do I need to bring for the survey?',
          time: '7:15 AM',
        ),
      ],
    ),
    const WhatsAppConversation(
      id: 'wa5',
      initials: 'BO',
      bgColor: Color(0xFFFEE2E2),
      textColor: Color(0xFF991B1B),
      name: 'Bello Kabiru',
      time: '3h ago',
      isUnread: true,
      thread: [
        WhatsAppMessage(
          isOutgoing: false,
          text: 'Is there any discount if I pay in full?',
          time: '6:30 AM',
        ),
      ],
    ),
  ];

  // ─── DESIGN TASKS ──────────────────────────────────────────────

  static final List<DesignTask> designTasks = [
    const DesignTask(
      id: 'dt1',
      thumbLabel: 'IMG',
      thumbBg: Color(0xFFDBEAFE),
      thumbTextColor: Color(0xFF1E40AF),
      title: 'Bethel City — Square post graphic',
      brief: 'Content Director',
      platform: 'Instagram',
      dueDate: 'Jul 16',
      status: 'todo',
    ),
    const DesignTask(
      id: 'dt2',
      thumbLabel: 'VID',
      thumbBg: Color(0xFFEDE9FE),
      thumbTextColor: Color(0xFF5B21B6),
      title: 'Benji vendor onboarding explainer',
      brief: 'Content Director',
      platform: 'TikTok',
      dueDate: 'Jul 15',
      status: 'todo',
    ),
    const DesignTask(
      id: 'dt3',
      thumbLabel: 'GFX',
      thumbBg: Color(0xFFD1FAE5),
      thumbTextColor: Color(0xFF065F46),
      title: 'Survey services flyer — WhatsApp',
      brief: 'Content Director',
      platform: 'WhatsApp',
      dueDate: 'Jul 17',
      status: 'todo',
    ),
    const DesignTask(
      id: 'dt4',
      thumbLabel: 'OVR',
      thumbBg: Color(0xFFFEE2E2),
      thumbTextColor: Color(0xFF991B1B),
      title: 'Weekly property drop graphic',
      brief: 'Content Director',
      platform: 'All platforms',
      dueDate: 'Jul 13',
      status: 'todo',
      isOverdue: true,
    ),
    const DesignTask(
      id: 'dt5',
      thumbLabel: 'REV',
      thumbBg: Color(0xFFFEF3C7),
      thumbTextColor: Color(0xFF92400E),
      title: 'Engineering project showcase carousel',
      brief: 'Graphic Designer',
      platform: 'Instagram',
      dueDate: 'Jul 15',
      status: 'review',
    ),
    const DesignTask(
      id: 'dt6',
      thumbLabel: '✓',
      thumbBg: Color(0xFFD1FAE5),
      thumbTextColor: Color(0xFF065F46),
      title: 'Bethel City estate walkthrough video',
      brief: 'Published Jul 14 · Reach: 4,200 · 87 saves',
      platform: 'Instagram',
      dueDate: 'Jul 14',
      status: 'done',
    ),
    const DesignTask(
      id: 'dt7',
      thumbLabel: '✓',
      thumbBg: Color(0xFFD1FAE5),
      thumbTextColor: Color(0xFF065F46),
      title: '"Survey before you build" carousel',
      brief: 'Published Jul 14 · Reach: 2,100 · 43 shares',
      platform: 'Facebook',
      dueDate: 'Jul 14',
      status: 'done',
    ),
    const DesignTask(
      id: 'dt8',
      thumbLabel: '✓',
      thumbBg: Color(0xFFD1FAE5),
      thumbTextColor: Color(0xFF065F46),
      title: 'Benji vendor spotlight — Mama Oby\'s Kitchen',
      brief: 'Published Jul 13 · Reach: 3,800',
      platform: 'Instagram + TikTok',
      dueDate: 'Jul 13',
      status: 'done',
    ),
  ];

  // ─── MEDIA ASSETS ──────────────────────────────────────────────

  static final List<MediaAsset> mediaAssets = [
    MediaAsset(title: 'Bethel City Drone Footage', type: 'video', bgColor: const Color(0xFF1F3D7A), icon: 'ti-video', division: MarketingDivision.re, size: '240 MB'),
    MediaAsset(title: 'Estate Logo Pack', type: 'image', bgColor: const Color(0xFF0A6B3E), icon: 'ti-photo', division: MarketingDivision.re, size: '12 MB'),
    MediaAsset(title: 'Benji App Screenshots', type: 'image', bgColor: const Color(0xFF7C3AED), icon: 'ti-device-mobile', division: MarketingDivision.ben, size: '8 MB'),
    MediaAsset(title: 'Engineering Showcase Reel', type: 'video', bgColor: const Color(0xFFCC0000), icon: 'ti-video', division: MarketingDivision.eng, size: '180 MB'),
    MediaAsset(title: 'Brand Guideline PDF', type: 'doc', bgColor: const Color(0xFFB87D00), icon: 'ti-file-text', division: MarketingDivision.re, size: '4 MB'),
    MediaAsset(title: 'Survey Site Photos', type: 'image', bgColor: const Color(0xFF059669), icon: 'ti-photo', division: MarketingDivision.sur, size: '56 MB'),
    MediaAsset(title: 'Vendor Testimonial Clips', type: 'video', bgColor: const Color(0xFF7C3AED), icon: 'ti-video', division: MarketingDivision.ben, size: '310 MB'),
    MediaAsset(title: 'Farm Produce Photos', type: 'image', bgColor: const Color(0xFFDC2626), icon: 'ti-photo', division: MarketingDivision.agr, size: '22 MB'),
  ];

  // ─── BROADCASTS ────────────────────────────────────────────────

  static final List<BroadcastRecord> broadcasts = [
    const BroadcastRecord(date: 'Jul 10', audience: 'All RE leads', sent: 310, delivered: 298, responses: 47, generated: 12),
    const BroadcastRecord(date: 'Jul 7', audience: 'Benji vendors', sent: 124, delivered: 119, responses: 31, generated: 8),
    const BroadcastRecord(date: 'Jul 3', audience: 'Dormant leads', sent: 89, delivered: 84, responses: 12, generated: 3),
    const BroadcastRecord(date: 'Jun 28', audience: 'All RE leads', sent: 275, delivered: 261, responses: 39, generated: 9),
  ];

  // ─── SUPPORT TICKETS ───────────────────────────────────────────

  static final List<SupportTicket> tickets = [
    const SupportTicket(id: 'TK-041', customerName: 'Ngozi Kamalu', issue: 'Benji app not activating vendor account', division: MarketingDivision.ben, priority: 'urgent', time: '2h ago', assignedTo: 'Customer Care'),
    const SupportTicket(id: 'TK-040', customerName: 'Adaeze Chukwu', issue: 'Payment plan clarification request', division: MarketingDivision.re, priority: 'high', time: '4h ago', assignedTo: 'Customer Care'),
    const SupportTicket(id: 'TK-039', customerName: 'Emeka Eze', issue: 'Site visit rescheduling request', division: MarketingDivision.eng, priority: 'medium', time: 'Yesterday', assignedTo: 'Customer Care'),
    const SupportTicket(id: 'TK-038', customerName: 'Peter Ani', issue: 'Technical issue with Bomach OS login', division: MarketingDivision.ict, priority: 'high', time: 'Yesterday', assignedTo: 'Tech Dept'),
    const SupportTicket(id: 'TK-037', customerName: 'Ifeoma Nze', issue: 'Agriculture supply contract query', division: MarketingDivision.agr, priority: 'medium', time: '2 days ago', assignedTo: 'Business Dev'),
  ];

  // ─── REALTORS ──────────────────────────────────────────────────

  static final List<RealtorPartner> realtors = [
    const RealtorPartner(initials: 'CH', bgColor: Color(0xFFDBEAFE), textColor: Color(0xFF1E40AF), name: 'Chukwudi Habitat Agency', since: 'Jan 2025', commission: '3%', phone: '08031234567', referrals: '₦14.2M', status: 'active'),
    const RealtorPartner(initials: 'NE', bgColor: Color(0xFFD1FAE5), textColor: Color(0xFF065F46), name: 'Nwachukwu Estates Ltd', since: 'Mar 2025', commission: '2.5%', phone: '07041234567', referrals: '₦8.7M', status: 'active'),
    const RealtorPartner(initials: 'PP', bgColor: Color(0xFFFEF3C7), textColor: Color(0xFF92400E), name: 'Prime Properties Enugu', since: '—', commission: '3%', phone: '—', referrals: '—', status: 'pending'),
    const RealtorPartner(initials: 'GH', bgColor: Color(0xFFEDE9FE), textColor: Color(0xFF5B21B6), name: 'Greater Horizons Realty', since: 'Jun 2025', commission: '2%', phone: '08021234567', referrals: '₦3.1M', status: 'active'),
  ];

  // ─── INFLUENCERS ───────────────────────────────────────────────

  static final List<InfluencerPartner> influencers = [
    const InfluencerPartner(initials: 'AO', bgColor: Color(0xFF7C3AED), name: 'Adaora Okafor', handle: '@adaora_enugu', platform: 'Instagram + TikTok', followers: '48K', engagement: '6.2%', niche: 'Real Estate', rate: '₦180K/post', status: 'active'),
    const InfluencerPartner(initials: 'KN', bgColor: Color(0xFF059669), name: 'Kelechi Nwosu', handle: '@kelechi_foodie', platform: 'TikTok + Instagram', followers: '112K', engagement: '8.9%', niche: 'Food / Benji', rate: '₦350K/post', status: 'negotiation'),
    const InfluencerPartner(initials: 'CI', bgColor: Color(0xFFCC0000), name: 'Chisom Igwe', handle: '@chisom_builds', platform: 'YouTube + Instagram', followers: '29K', engagement: '4.1%', niche: 'Engineering', rate: '₦120K/post', status: 'pending'),
    const InfluencerPartner(initials: 'TM', bgColor: Color(0xFFD97706), name: 'Tochi Mbah', handle: '@tochi_enugu', platform: 'Instagram', followers: '67K', engagement: '5.8%', niche: 'Lifestyle', rate: '₦220K/post', status: 'active'),
  ];

  // ─── KPI PERIODS ───────────────────────────────────────────────

  static const Map<String, Map<String, String>> periodData = {
    'today': {'leads': '23', 'conv': '21.4%', 'pipe': '₦12M', 'content': '4', 'allLeads': '83', 'allRevenue': '₦8.2M'},
    'week': {'leads': '127', 'conv': '18.2%', 'pipe': '₦84M', 'content': '17', 'allLeads': '483', 'allRevenue': '₦47.3M'},
    'month': {'leads': '483', 'conv': '15.8%', 'pipe': '₦210M', 'content': '68', 'allLeads': '1,420', 'allRevenue': '₦142M'},
    'quarter': {'leads': '1,420', 'conv': '14.2%', 'pipe': '₦580M', 'content': '186', 'allLeads': '4,100', 'allRevenue': '₦389M'},
  };

  // ─── CAMPAIGN TEMPLATES ────────────────────────────────────────

  static const List<CampaignTemplate> campaignTemplates = [
    CampaignTemplate(name: 'Estate Launch', icon: 'ti-home', description: 'Full campaign for new estate development — social, field, WhatsApp and print'),
    CampaignTemplate(name: 'Campus Activation', icon: 'ti-school', description: 'Student and youth-focused outreach campaign for Benji vendor recruitment'),
    CampaignTemplate(name: 'Content Series', icon: 'ti-photo-video', description: 'Multi-week content series — video, graphics, carousels and stories'),
    CampaignTemplate(name: 'Product Spotlight', icon: 'ti-star', description: 'Focused campaign highlighting a single product or service line'),
    CampaignTemplate(name: 'Seasonal Promo', icon: 'ti-gift', description: 'Time-limited promotional campaign with urgency and special offers'),
    CampaignTemplate(name: 'Partner Co-Brand', icon: 'ti-handshake', description: 'Joint campaign with realtor or influencer partner'),
  ];
}
