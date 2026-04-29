#!/usr/bin/env perl
# One-shot migration: hardcoded Color(0xFF....) → semantic AppColors.* tokens.
#
# Only maps the recurring brand/neutrals/semantic/surface palette. Leaves one-off
# brand-y colors alone. Skips:
#   * lib/src/constants/colors.dart   (token definitions themselves)
#   * the @Deprecated alias literals in colors.dart (protected by skip above)
#
# After substitution, inserts the AppColors import if missing.

use strict;
use warnings;
use File::Find;

my $root = shift @ARGV or die "usage: $0 <lib-dir>\n";

# Map UPPERCASE hex → AppColors.<token>.
# Comparison is case-insensitive below.
my %map = (
    # Brand
    '2563EB' => 'primary',
    '1D4ED8' => 'primaryHover',
    '1E40AF' => 'primaryPressed',
    'EFF4FF' => 'primarySubtle',
    'DBE6FE' => 'primarySoft',

    # Neutrals
    'F8FAFC' => 'neutral50',
    'F1F5F9' => 'neutral100',
    'E2E8F0' => 'neutral200',
    'CBD5E1' => 'neutral300',
    '94A3B8' => 'neutral400',
    '64748B' => 'neutral500',
    '475569' => 'neutral600',
    '334155' => 'neutral700',
    '1E293B' => 'neutral800',
    '0F172A' => 'neutral900',

    # Semantic
    '16A34A' => 'success',
    'DCFCE7' => 'successSubtle',
    'D97706' => 'warning',
    'FEF3C7' => 'warningSubtle',
    'DC2626' => 'danger',
    'FEE2E2' => 'dangerSubtle',
    '0284C7' => 'info',
    'E0F2FE' => 'infoSubtle',
);

my @files;
find(sub { push @files, $File::Find::name if /\.dart$/ }, $root);

my ($files_touched, $replacements) = (0, 0);

for my $path (@files) {
    # Skip the token definitions themselves.
    next if $path =~ m{constants[\\/]colors\.dart$};

    open my $fh, '<', $path or next;
    local $/; my $src = <$fh>; close $fh;
    my $orig = $src;

    my $count = 0;

    # Match Color(0xFFxxxxxx) or Color(0xffXXXXXX), accept optional whitespace,
    # case-insensitive hex. Replace only when the hex is in our map.
    $src =~ s{
        Color \( \s* 0x [fF]{2} ([0-9a-fA-F]{6}) \s* \)
    }{
        my $hex = uc $1;
        if (exists $map{$hex}) {
            $count++;
            "AppColors." . $map{$hex};
        } else {
            $&;   # leave it alone
        }
    }gex;

    if ($count > 0) {
        # Ensure AppColors import is present.
        unless ($src =~ m{src/constants/colors\.dart}) {
            if ($src =~ m{^(import\s+[^\n]+;)\n}m) {
                $src =~ s{^(import\s+[^\n]+;)\n}
                         {$1\nimport 'package:bomach_os/src/constants/colors.dart';\n}m;
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
