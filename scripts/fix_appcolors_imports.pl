#!/usr/bin/env perl
# Follow-up helper: for every .dart file under <lib-dir> that references
# `AppColors.` but doesn't import the colors constants file, insert the
# import immediately after the first existing `import ...;` line.
#
# CRLF-aware. Skips the colors definition file itself.

use strict;
use warnings;
use File::Find;

my $root = shift @ARGV or die "usage: $0 <lib-dir>\n";

my @files;
find(sub { push @files, $File::Find::name if /\.dart$/ }, $root);

my $fixed = 0;

for my $path (@files) {
    next if $path =~ m{constants[\\/]colors\.dart$};

    open my $fh, '<', $path or next;
    local $/; my $src = <$fh>; close $fh;

    next unless $src =~ /\bAppColors\./;
    next if $src =~ m{src/constants/colors\.dart};

    my $inserted = $src =~
        s{^(import\s+[^\r\n]+;)(\r?\n)}
         {$1$2import 'package:bomach_os/src/constants/colors.dart';$2}m;

    if ($inserted) {
        open my $out, '>', $path or next;
        print $out $src;
        close $out;
        $fixed++;
        print "  + $path\n";
    } else {
        print "  ! could not insert: $path\n";
    }
}

print "\nDone. Added AppColors import to $fixed file(s).\n";
