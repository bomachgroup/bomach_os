#!/usr/bin/env perl
# Second-pass migration for Icons.* → Iconsax.* — covers the remaining
# Material icons discovered after the first sweep.
#
# Same rules as migrate_icons.pl: word-boundary match, conservative mapping,
# leave Icons.* alone if no close iconsax equivalent. Adds the iconsax import
# if missing.

use strict;
use warnings;
use File::Find;

my $root = shift @ARGV or die "usage: $0 <lib-dir>\n";

my %map = (
    # Status dots / circles
    circle                         => 'record_circle',
    circle_outlined                => 'record',

    # Time / timers
    hourglass_top_rounded          => 'timer',
    hourglass_top                  => 'timer',
    hourglass_bottom               => 'timer',
    timelapse_rounded              => 'timer_1',
    access_time_rounded            => 'clock',
    access_time_filled             => 'clock',
    pending_actions                => 'timer_1',

    # Images / media
    broken_image                   => 'gallery_slash',
    photo_camera_outlined          => 'camera',
    camera_alt_rounded             => 'camera',
    videocam_outlined              => 'video',
    local_activity_outlined        => 'ticket',

    # Location
    add_location_alt_rounded       => 'location_add',
    location_off_rounded           => 'location_slash',
    location_city_outlined         => 'building_4',
    my_location_rounded            => 'location',
    location_searching_rounded     => 'location',

    # Measurement
    square_foot                    => 'ruler',

    # Receipts / money
    receipt_long                   => 'receipt_2',
    receipt                        => 'receipt',
    money_off_csred_outlined       => 'empty_wallet',
    money_outlined                 => 'money_recive',
    account_balance                => 'bank',
    account_balance_outlined       => 'bank',
    payment                        => 'card',
    price_check_outlined           => 'money_tick',

    # Duplication / sharing
    control_point_duplicate_sharp  => 'copy',
    copy                           => 'copy',
    share                          => 'share',
    share_outlined                 => 'share',
    ios_share                      => 'share',
    send                           => 'send_2',
    forum_outlined                 => 'messages',

    # Deletion / delete variants
    delete_outline_rounded         => 'trash',
    delete_outlined                => 'trash',

    # People
    person_add_alt_1_rounded       => 'user_add',
    person_add                     => 'user_add',
    person_remove                  => 'user_remove',
    people_rounded                 => 'people',
    groups_2_outlined              => 'people',
    handshake_outlined             => 'people',
    assignment_ind                 => 'profile_tick',

    # Work / business
    business                       => 'building_4',
    domain                         => 'building_4',
    domain_disabled                => 'building_4',
    domain_disabled_outlined       => 'building_4',
    work                           => 'briefcase',
    work_outline                   => 'briefcase',

    # Education
    school                         => 'teacher',
    school_outlined                => 'teacher',

    # Confirmation variants
    done_all                       => 'tick_circle',
    check_circle_outline_rounded   => 'tick_circle',
    task_alt                       => 'task_square',
    check_box                      => 'tick_square',
    check_box_outlined             => 'tick_square',
    check_box_outline_blank        => 'square',
    checklist_rtl_outlined         => 'task_square',
    fact_check_outlined            => 'task_square',

    # Keys / security
    key                            => 'key',
    vpn_key_outlined               => 'key',
    lock_reset                     => 'lock_1',
    admin_panel_settings_outlined  => 'shield_tick',
    gpp_bad_outlined               => 'shield_cross',
    fingerprint                    => 'finger_scan',

    # Charts
    pie_chart                      => 'chart_21',
    pie_chart_outline_outlined     => 'chart_21',
    show_chart_rounded             => 'chart',
    bar_chart_outlined             => 'chart_2',
    bar_chart_rounded              => 'chart_2',
    table_chart                    => 'chart',
    insights_outlined              => 'chart_2',
    leaderboard                    => 'chart_1',
    assessment                     => 'chart_21',
    assessment_outlined            => 'chart_21',
    trending_up_rounded            => 'trend_up',

    # Lists / tasks
    list_alt_rounded               => 'task_square',
    inventory_2_outlined           => 'box_1',
    archive_outlined               => 'archive_1',

    # Favorites / stars
    star_rounded                   => 'star1',
    star_outline_rounded           => 'star',

    # Misc
    download_outlined              => 'document_download',
    upload_file                    => 'document_upload',
    calendar_month_outlined        => 'calendar_1',
    event_outlined                 => 'calendar_1',
    event_note_outlined            => 'calendar_1',
    event_busy_rounded             => 'calendar_remove',
    event_busy_outlined            => 'calendar_remove',
    today                          => 'calendar_1',
    edit_note_rounded              => 'edit_2',
    fiber_new                      => 'flash',
    tag_faces                      => 'emoji_happy',
    tag                            => 'tag',
    flag                           => 'flag',
    print                          => 'printer',
    history                        => 'clock',
    history_rounded                => 'clock',
    lightbulb_rounded              => 'lamp',
    lightbulb                      => 'lamp',
    push_pin                       => 'location',
    comment_outlined               => 'message',
    campaign                       => 'notification_bing',
    campaign_outlined              => 'notification_bing',
    local_hospital_rounded         => 'hospital',
    beach_access_rounded           => 'sun',
    wb_sunny_outlined              => 'sun',
    child_friendly_rounded         => 'milk',
    sentiment_satisfied_rounded    => 'emoji_happy',
    face_rounded                   => 'emoji_happy',
    face_retouching_off            => 'emoji_normal',
    emoji_events                   => 'cup',
    speed                          => 'speedometer',

    # Navigation / misc arrows
    arrow_drop_down_circle_outlined => 'arrow_circle_down',
    arrow_drop_down_rounded        => 'arrow_down_1',
    arrow_drop_down_sharp          => 'arrow_down_1',
    arrow_forward_sharp            => 'arrow_right_3',
    arrow_forward_ios_outlined     => 'arrow_right_3',
    chevron_right_rounded          => 'arrow_right_3',
    more_horiz_rounded             => 'more',
    swap_horiz                     => 'arrow_swap_horizontal',
    compare_arrows                 => 'arrow_swap_horizontal',
    repeat                         => 'refresh_2',
    alt_route                      => 'routing_2',
    track_changes                  => 'radar',
    open_in_new                    => 'export',

    # Selection
    select_all                     => 'tick_square',
    deselect                       => 'square',
    grid_on                        => 'element_4',
    grid_off                       => 'element_4',

    # Warnings / info variants
    warning_amber_rounded          => 'warning_2',
    info_outline_rounded           => 'info_circle',

    # Visibility
    visibility_rounded             => 'eye',

    # Logs / send-outs
    close_outlined                 => 'close_circle',
    login_rounded                  => 'login_1',

    # Documents
    folder_shared_outlined         => 'folder_2',
    approval_outlined              => 'tick_square',
    assignment_outlined            => 'task_square',
    inbox_rounded                  => 'archive_1',
    link_outlined                  => 'link_1',

    # Finance / transactions
    calculate_outlined             => 'calculator',

    # Nature / land
    landscape_outlined             => 'tree',

    # Parking
    local_parking                  => 'car',

    # Settings variants
    align_horizontal_left_sharp    => 'textalign_left',
);

my @files;
find(sub { push @files, $File::Find::name if /\.dart$/ }, $root);

my ($files_touched, $replacements) = (0, 0);

for my $path (@files) {
    open my $fh, '<', $path or next;
    local $/; my $src = <$fh>; close $fh;

    my $count = 0;
    $src =~ s{
        \b Icons \. (\w+) \b
    }{
        my $name = $1;
        if (exists $map{$name}) {
            $count++;
            "Iconsax.$map{$name}";
        } else {
            $&;
        }
    }gex;

    if ($count > 0) {
        # Ensure iconsax import is present (CRLF-aware).
        unless ($src =~ m{package:iconsax/iconsax\.dart}) {
            if ($src =~ m{^(import\s+[^\r\n]+;)(\r?\n)}m) {
                $src =~ s{^(import\s+[^\r\n]+;)(\r?\n)}
                         {$1$2import 'package:iconsax/iconsax.dart';$2}m;
            }
        }
        open my $out, '>', $path or next;
        print $out $src;
        close $out;
        $files_touched++;
        $replacements += $count;
        print "  $path: $count replacement(s)\n";
    }
}

print "\nDone. $replacements replacement(s) across $files_touched file(s).\n";
