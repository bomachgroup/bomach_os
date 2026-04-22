#!/usr/bin/env perl
# Follow-up helper: for every .dart file under <lib-dir> that references
# `Iconsax.` but doesn't import `package:iconsax/iconsax.dart`, insert the
# import immediately after the first existing `import ...;` line.
#
# CRLF-aware — the main migration script's regex was not, so this cleans up
# the stragglers.

use strict;
use warnings;
use File::Find;

my $root = shift @ARGV or die "usage: $0 <lib-dir>\n";

my @files;
find(sub { push @files, $File::Find::name if /\.dart$/ }, $root);

my $fixed = 0;

for my $path (@files) {
    open my $fh, '<', $path or next;
    local $/; my $src = <$fh>; close $fh;

    next unless $src =~ /\bIconsax\./;
    next if $src =~ m{package:iconsax/iconsax\.dart};

    my $inserted = $src =~
        s{^(import\s+[^\r\n]+;)(\r?\n)}
         {$1$2import 'package:iconsax/iconsax.dart';$2}m;

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

print "\nDone. Added iconsax import to $fixed file(s).\n";
