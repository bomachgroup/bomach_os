#!/usr/bin/env perl
# Adds `icon: Iconsax.xxx,` to every SubMenuItemData(...) block in side_menu.dart
# based on its `id: SubMenuItem.xxx` value.

use strict;
use warnings;

my %icon_map = (
    # Dashboard
    dashboardHome        => 'Iconsax.home_2',
    myProfile            => 'Iconsax.user',
    myTasks              => 'Iconsax.task_square',
    myReports            => 'Iconsax.document_text',

    # Company
    company              => 'Iconsax.building_4',
    branch               => 'Iconsax.buildings_2',
    board                => 'Iconsax.people',
    broadcast            => 'Iconsax.speaker',
    roles                => 'Iconsax.shield_tick',
    approvalWorkflow     => 'Iconsax.tick_square',
    workspaceApprovals   => 'Iconsax.note_2',
    department           => 'Iconsax.hierarchy',
    assets               => 'Iconsax.box',
    auditLog             => 'Iconsax.clipboard_text',

    # HR
    employees            => 'Iconsax.user_square',
    attendance           => 'Iconsax.calendar_tick',
    jobPost              => 'Iconsax.user_add',
    leaves               => 'Iconsax.calendar_remove',
    leaveRequest         => 'Iconsax.note_remove',
    trainingProgram      => 'Iconsax.teacher',
    loans                => 'Iconsax.money_recive',
    benefits             => 'Iconsax.gift',
    performance          => 'Iconsax.chart',
    workReport           => 'Iconsax.note_2',
    monthlyScorecard     => 'Iconsax.chart_2',
    awardsRecognition    => 'Iconsax.award',
    performanceLeaderboard => 'Iconsax.cup',
    employeeEvaluation   => 'Iconsax.clipboard_text',
    disciplinaryProcess  => 'Iconsax.warning_2',

    # Operations
    operations           => 'Iconsax.briefcase',
    project              => 'Iconsax.folder_connection',
    worksite             => 'Iconsax.location_tick',
    tasks                => 'Iconsax.task_square',
    contracts            => 'Iconsax.document_text',
    meetings             => 'Iconsax.calendar_1',

    # Services
    servicesDashboard    => 'Iconsax.element_4',
    serviceClients       => 'Iconsax.user_octagon',
    propertyManagement   => 'Iconsax.building_4',
    estateManagement     => 'Iconsax.buildings',

    # Marketing & CRM
    marketingCrmDashboard => 'Iconsax.element_4',
    crmClients           => 'Iconsax.user_octagon',
    crmLeads             => 'Iconsax.flash_1',
    crmInteractions      => 'Iconsax.messages_2',
    marketing            => 'Iconsax.lamp_charge',
    crmAnalytics         => 'Iconsax.chart_square',

    # Finance
    financeDashboard     => 'Iconsax.element_4',
    invoice              => 'Iconsax.receipt_2_1',
    payments             => 'Iconsax.money_send',
    expenses             => 'Iconsax.money_remove',
    budget               => 'Iconsax.wallet_2',

    # Analytics
    overview             => 'Iconsax.chart_square',

    # Legal & Compliance
    legalContracts       => 'Iconsax.document_text',
    legalCompliance      => 'Iconsax.verify',
    legalCases           => 'Iconsax.judge',
    legalAudits          => 'Iconsax.clipboard_text',

    # Client Portal
    clientAccess         => 'Iconsax.key',
    documentSharing      => 'Iconsax.document_upload',
    communications       => 'Iconsax.messages_2',
    portalAnalytics      => 'Iconsax.chart_square',
);

my $path = shift @ARGV or die "usage: $0 <file>\n";

open my $fh, '<', $path or die "cannot read $path: $!\n";
local $/; my $src = <$fh>; close $fh;

my $count = 0;

# Match: SubMenuItemData(\n whitespace id: SubMenuItem.NAME, — then insert icon: after it.
# Be careful not to match if `icon:` is already present.
$src =~ s{
    ( SubMenuItemData \( \s* (?: \r?\n \s* )?
      id: \s* SubMenuItem\. (\w+) \s* , \s* (\r?\n) )
    ( \s* )
    (?! \s* icon: )
}{
    my $prefix  = $1;
    my $id      = $2;
    my $nl      = $3;
    my $indent  = $4;
    if (exists $icon_map{$id}) {
        $count++;
        "$prefix$indent" . "icon: $icon_map{$id},$nl$indent";
    } else {
        warn "no icon mapping for SubMenuItem.$id\n";
        $1 . $4;
    }
}gsex;

open my $out, '>', $path or die "cannot write $path: $!\n";
print $out $src;
close $out;

print "Added $count icons to $path\n";
