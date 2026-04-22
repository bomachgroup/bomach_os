#!/usr/bin/env perl
# One-shot migration: Material `Icons.<name>` → `Iconsax.<name>` for a curated
# set of common icons that have clean iconsax equivalents.
#
# Only touches word-boundary-matched `Icons.<name>`. Unmapped Material icons
# are left alone (flutter analyze will still build them as Icons.*).
#
# After substitution, inserts `import 'package:iconsax/iconsax.dart';` if any
# substitution happened and the import is missing.
#
# Does NOT remove the Material icons import — other (unmapped) Icons.* may
# still be referenced in the same file.

use strict;
use warnings;
use File::Find;

my $root = shift @ARGV or die "usage: $0 <lib-dir>\n";

# Material icon name → Iconsax equivalent.
# Keep this list to visually-close, semantically-equivalent icons. When in
# doubt, leave the Material icon alone.
my %map = (
    # Close / cancel / clear
    close                      => 'close_circle',
    clear                      => 'close_circle',
    cancel                     => 'close_circle',
    cancel_rounded             => 'close_circle',
    cancel_outlined            => 'close_circle',

    # Check / tick
    check                      => 'tick_circle',
    check_rounded              => 'tick_circle',
    check_circle               => 'tick_circle',
    check_circle_rounded       => 'tick_circle',
    check_circle_outline       => 'tick_circle',
    check_circle_outlined      => 'tick_circle',
    verified                   => 'verify',
    verified_user              => 'shield_tick',
    verified_user_outlined     => 'shield_tick',

    # Add
    add                        => 'add',
    add_rounded                => 'add',
    add_circle                 => 'add_circle',
    add_circle_outline         => 'add_circle',
    add_circle_outlined        => 'add_circle',
    add_circle_outline_rounded => 'add_circle',
    add_circle_rounded         => 'add_circle',

    # Edit
    edit                       => 'edit',
    edit_outlined              => 'edit',
    edit_rounded               => 'edit',
    edit_note                  => 'edit_2',
    edit_note_outlined         => 'edit_2',

    # Delete
    delete                     => 'trash',
    delete_outline             => 'trash',
    delete_outlined            => 'trash',
    delete_rounded             => 'trash',
    delete_forever             => 'trash',

    # More / menu
    more_vert                  => 'more',
    more_horiz                 => 'more',
    menu                       => 'menu',

    # Refresh
    refresh                    => 'refresh',
    refresh_rounded            => 'refresh',

    # Search
    search                     => 'search_normal',
    search_outlined            => 'search_normal',
    search_rounded             => 'search_normal',

    # Navigation arrows
    arrow_back                 => 'arrow_left_2',
    arrow_back_ios             => 'arrow_left_2',
    arrow_back_ios_new         => 'arrow_left_2',
    arrow_back_rounded         => 'arrow_left_2',
    arrow_forward              => 'arrow_right_3',
    arrow_forward_ios          => 'arrow_right_3',
    arrow_forward_rounded      => 'arrow_right_3',
    arrow_upward               => 'arrow_up_3',
    arrow_upward_rounded       => 'arrow_up_3',
    arrow_downward             => 'arrow_down_1',
    arrow_downward_rounded     => 'arrow_down_1',
    arrow_drop_down            => 'arrow_down_1',
    arrow_drop_up              => 'arrow_up_3',
    chevron_right              => 'arrow_right_3',
    chevron_left               => 'arrow_left_2',
    keyboard_arrow_down        => 'arrow_down_1',
    keyboard_arrow_down_rounded => 'arrow_down_1',
    keyboard_arrow_up          => 'arrow_up_3',
    keyboard_arrow_up_rounded  => 'arrow_up_3',
    keyboard_arrow_left        => 'arrow_left_2',
    keyboard_arrow_right       => 'arrow_right_3',
    expand_more                => 'arrow_down_1',
    expand_less                => 'arrow_up_3',

    # People / profile
    person                     => 'profile_circle',
    person_outline             => 'profile_circle',
    person_outlined            => 'profile_circle',
    account_circle             => 'profile_circle',
    account_circle_outlined    => 'profile_circle',
    people                     => 'people',
    people_outline             => 'people',
    people_outlined            => 'people',
    people_alt                 => 'people',
    people_alt_outlined        => 'people',
    group                      => 'people',
    group_outlined             => 'people',
    groups                     => 'people',
    groups_outlined            => 'people',

    # Places
    home                       => 'home',
    home_outlined              => 'home',
    home_work                  => 'home',
    business                   => 'building_4',
    business_outlined          => 'building_4',

    # Time
    calendar_today             => 'calendar_1',
    calendar_today_outlined    => 'calendar_1',
    calendar_today_rounded     => 'calendar_1',
    calendar_month             => 'calendar_1',
    event                      => 'calendar_1',
    event_note                 => 'calendar_1',
    event_note_rounded         => 'calendar_1',
    access_time                => 'clock',
    access_time_outlined       => 'clock',
    schedule                   => 'clock',
    schedule_rounded           => 'clock',

    # Contact
    phone                      => 'call',
    phone_outlined             => 'call',
    call                       => 'call',
    email                      => 'sms',
    email_outlined             => 'sms',
    mail                       => 'sms',
    mail_outline               => 'sms',
    sms                        => 'sms',
    chat_bubble_outline        => 'message_text',
    chat                       => 'message_text',
    chat_outlined              => 'message_text',
    message                    => 'message_text',
    message_outlined           => 'message_text',

    # Location
    location_on                => 'location',
    location_on_outlined       => 'location',
    location_on_rounded        => 'location',
    location_city              => 'location',
    place                      => 'location',

    # Security
    lock                       => 'lock',
    lock_outline               => 'lock',
    lock_outlined              => 'lock',
    security                   => 'shield',

    # Visibility
    visibility                 => 'eye',
    visibility_outlined        => 'eye',
    remove_red_eye             => 'eye',
    remove_red_eye_outlined    => 'eye',
    visibility_off             => 'eye_slash',
    visibility_off_outlined    => 'eye_slash',

    # Status / alerts
    notifications              => 'notification',
    notifications_outlined     => 'notification',
    notifications_none         => 'notification',
    warning                    => 'warning_2',
    warning_amber              => 'warning_2',
    warning_amber_outlined     => 'warning_2',
    warning_outlined           => 'warning_2',
    error                      => 'danger',
    error_outline              => 'danger',
    error_outlined             => 'danger',
    info                       => 'info_circle',
    info_outline               => 'info_circle',
    info_outlined              => 'info_circle',
    help                       => 'info_circle',
    help_outline               => 'info_circle',
    help_outline_rounded       => 'info_circle',

    # I/O
    download                   => 'document_download',
    file_download              => 'document_download',
    file_download_outlined     => 'document_download',
    cloud_download             => 'document_download',
    cloud_download_outlined    => 'document_download',
    upload                     => 'document_upload',
    file_upload                => 'document_upload',
    file_upload_outlined       => 'document_upload',
    cloud_upload               => 'document_upload',
    cloud_upload_outlined      => 'document_upload',
    save                       => 'save_2',
    save_outlined              => 'save_2',

    # Docs / files
    description                => 'document_text',
    description_outlined       => 'document_text',
    description_rounded        => 'document_text',
    article                    => 'document_text',
    article_outlined           => 'document_text',
    picture_as_pdf             => 'document_text',
    insert_drive_file          => 'document',
    insert_drive_file_outlined => 'document',
    file_open_outlined         => 'document',
    folder                     => 'folder_2',
    folder_outlined            => 'folder_2',
    folder_open                => 'folder_2',
    folder_open_outlined       => 'folder_2',

    # Ratings / favorites
    star                       => 'star1',
    star_outline               => 'star',
    star_outlined              => 'star',
    star_border                => 'star',
    favorite                   => 'heart',
    favorite_border            => 'heart',

    # Money
    attach_money               => 'money_recive',
    payments                   => 'money_recive',
    payments_outlined          => 'money_recive',
    account_balance_wallet     => 'wallet',
    account_balance_wallet_outlined => 'wallet',

    # Attachments
    attach_file                => 'attach_circle',
    attachment                 => 'attach_circle',

    # Settings / filters
    settings                   => 'setting_2',
    settings_outlined          => 'setting_2',
    filter_list                => 'filter_search',
    tune                       => 'setting_4',
    sort                       => 'sort',

    # Misc
    category                   => 'category_2',
    category_outlined          => 'category_2',
    dashboard                  => 'element_4',
    dashboard_outlined         => 'element_4',
    logout                     => 'logout_1',
    log_out                    => 'logout_1',
    login                      => 'login_1',
    exit_to_app                => 'logout_1',

    # Charts / trends
    trending_up                => 'trend_up',
    trending_down              => 'trend_down',
    show_chart                 => 'chart_2',
    bar_chart                  => 'chart_2',

    # Work / legal
    gavel                      => 'judge',
    gavel_outlined             => 'judge',
);

my @files;
find(sub { push @files, $File::Find::name if /\.dart$/ }, $root);

my ($files_touched, $replacements) = (0, 0);

for my $path (@files) {
    open my $fh, '<', $path or next;
    local $/; my $src = <$fh>; close $fh;

    my $count = 0;
    # Match Icons.<name> with a word boundary before Icons and after the name.
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
        # Ensure iconsax import is present.
        unless ($src =~ m{package:iconsax/iconsax\.dart}) {
            if ($src =~ m{^(import\s+[^\n]+;)\n}m) {
                $src =~ s{^(import\s+[^\n]+;)\n}
                         {$1\nimport 'package:iconsax/iconsax.dart';\n}m;
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
