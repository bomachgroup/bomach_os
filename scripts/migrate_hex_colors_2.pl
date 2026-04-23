#!/usr/bin/env perl
# Second-pass hex → token migration. Covers off-palette brand/tailwind/Material
# hues picked up after the first sweep. Conservative: only hexes that clearly
# belong to an existing semantic tier get mapped. Distinct accent colors
# (purples, pinks, teals) that the design system doesn't have tokens for are
# left alone.

use strict;
use warnings;
use File::Find;

my $root = shift @ARGV or die "usage: $0 <lib-dir>\n";

my %map = (
    # Blues → primary family
    '0055FF' => 'primary',
    '007AFF' => 'primary',
    '005CE8' => 'primary',
    '0044CC' => 'primaryPressed',
    '1976D2' => 'primary',
    '1E88E5' => 'primary',
    '3B82F6' => 'primary',
    '2962FF' => 'primary',
    '448AFF' => 'primary',
    '1565C0' => 'primaryPressed',
    '1E40AF' => 'primaryPressed',

    # Info / sky blues
    '0EA5E9' => 'info',
    'E3F2FD' => 'infoSubtle',
    'E0F7FA' => 'infoSubtle',
    'EFF6FF' => 'primarySubtle',
    'F8FBFF' => 'primarySubtle',

    # Greens → success family
    '10B981' => 'success',
    '22C55E' => 'success',
    '00C853' => 'success',
    '27AE60' => 'success',
    '00B062' => 'success',
    '15803D' => 'success',
    '059669' => 'success',
    '16A34A' => 'success',
    'F0FDF4' => 'successSubtle',
    'E8F5E9' => 'successSubtle',
    'E6FFF2' => 'successSubtle',

    # Ambers / yellows → warning
    'F59E0B' => 'warning',
    'C27803' => 'warning',
    'F97316' => 'warning',
    'EA580C' => 'warning',
    'FF9800' => 'warning',
    'B45309' => 'warning',
    'FFFBEB' => 'warningSubtle',
    'FFFBE8' => 'warningSubtle',

    # Reds → danger
    'EF4444' => 'danger',
    'E11D48' => 'danger',
    'E74C3C' => 'danger',
    'EB5757' => 'danger',
    'C62828' => 'danger',
    'FEF2F2' => 'dangerSubtle',
    'FFF1F2' => 'dangerSubtle',
    'FBE9E7' => 'dangerSubtle',
    'FFEFEB' => 'dangerSubtle',

    # Neutrals (tailwind gray + Material grey + slate)
    'F9FAFB' => 'neutral50',
    'FAFAFA' => 'neutral50',
    'F8F9FA' => 'neutral50',
    'F8F9FB' => 'neutral50',
    'FAFBFC' => 'neutral50',
    'F7F7F7' => 'neutral100',
    'F7F8FA' => 'neutral100',
    'F0F0F0' => 'neutral100',
    'F3F4F6' => 'neutral100',
    'EEEEEE' => 'neutral100',
    'E5E5E5' => 'neutral200',
    'E5E7EB' => 'neutral200',
    'E0E0E0' => 'neutral200',
    'E8EAF6' => 'neutral200',
    'E8ECF0' => 'neutral200',
    'D5D5D5' => 'neutral300',
    '9CA3AF' => 'neutral400',
    '6B7280' => 'neutral500',
    '4B5563' => 'neutral600',
    '374151' => 'neutral700',
    '1F2937' => 'neutral800',
    '313131' => 'neutral800',
    '1A202C' => 'neutral900',
    '141522' => 'neutral900',
    '111827' => 'neutral900',
);

my @files;
find(sub { push @files, $File::Find::name if /\.dart$/ }, $root);

my ($files_touched, $replacements) = (0, 0);

for my $path (@files) {
    next if $path =~ m{constants[\\/]colors\.dart$};

    open my $fh, '<', $path or next;
    local $/; my $src = <$fh>; close $fh;

    my $count = 0;
    $src =~ s{
        Color \( \s* 0x [fF]{2} ([0-9a-fA-F]{6}) \s* \)
    }{
        my $hex = uc $1;
        if (exists $map{$hex}) {
            $count++;
            "AppColors." . $map{$hex};
        } else {
            $&;
        }
    }gex;

    # Strip any newly-introduced redundant `const ` before AppColors.*
    $count += ($src =~ s{\bconst\s+(AppColors\.\w+)}{$1}g);

    if ($count > 0) {
        unless ($src =~ m{src/constants/colors\.dart}) {
            if ($src =~ m{^(import\s+[^\r\n]+;)(\r?\n)}m) {
                $src =~ s{^(import\s+[^\r\n]+;)(\r?\n)}
                         {$1$2import 'package:bms_front_end/src/constants/colors.dart';$2}m;
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
