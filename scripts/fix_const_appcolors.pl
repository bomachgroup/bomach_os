#!/usr/bin/env perl
# Fix the fallout from migrate_hex_colors.pl:
#
#   const Color(0xFF64748B)  →  const AppColors.neutral500   ← broken (Dart)
#
# A bare `const X.Y` expects a constructor. Since AppColors.X are already
# compile-time constants, we just strip the redundant `const ` keyword
# whenever it directly precedes `AppColors.`.

use strict;
use warnings;
use File::Find;

my $root = shift @ARGV or die "usage: $0 <lib-dir>\n";

my @files;
find(sub { push @files, $File::Find::name if /\.dart$/ }, $root);

my ($files_touched, $replacements) = (0, 0);

for my $path (@files) {
    next if $path =~ m{constants[\\/]colors\.dart$};

    open my $fh, '<', $path or next;
    local $/; my $src = <$fh>; close $fh;

    my $count = 0;
    # Strip `const ` (with trailing whitespace) that directly precedes
    # `AppColors.<name>`. Preserve surrounding formatting.
    $count += ($src =~ s{\bconst\s+(AppColors\.\w+)}{$1}g);

    if ($count > 0) {
        open my $out, '>', $path or next;
        print $out $src;
        close $out;
        $files_touched++;
        $replacements += $count;
        print "  $path: $count fix(es)\n";
    }
}

print "\nDone. $replacements fix(es) across $files_touched file(s).\n";
