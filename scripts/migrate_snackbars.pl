#!/usr/bin/env perl
# One-shot migration: simple ScaffoldMessenger.showSnackBar → AppToast.X.
#
# Only touches the "simple" pattern:
#   ScaffoldMessenger.of(context).showSnackBar(
#     [const] SnackBar(
#       content: Text('...'),
#       [backgroundColor: Colors.<name>,]
#       [duration: Duration(...),]
#     ),
#   );
#
# Anything with a richer `content:` (Row/Column/Icon) or a dynamic message
# string is left alone.

use strict;
use warnings;
use File::Find;

my $root = shift @ARGV or die "usage: $0 <lib-dir>\n";
my @files;
find(sub { push @files, $File::Find::name if /\.dart$/ }, $root);

my ($files_touched, $replacements) = (0, 0);

for my $path (@files) {
    # Skip AppToast itself.
    next if $path =~ m{app_toast\.dart$};

    open my $fh, '<', $path or next;
    local $/; my $src = <$fh>; close $fh;
    my $orig = $src;

    my $count = 0;
    $src =~ s{
        ScaffoldMessenger\.of\(\s*context\s*\)
        \.showSnackBar\(
            \s* (?:const\s+)? SnackBar\(
                \s* content: \s* (?:const\s+)? Text\(
                    \s* (['"]) ((?:[^'"\\]|\\.)*?) \1
                    (?:\s*,[^)]*)?         # optional named args on Text
                \s* \)
                \s* ,?
                (?:\s* backgroundColor:\s*Colors\.(\w+)\s*,?)?
                (?:\s* duration:\s*Duration\([^)]*\)\s*,?)?
                (?:\s* behavior:\s*SnackBarBehavior\.\w+\s*,?)?
                \s*
            \)
            \s* ,?
        \s* \)
        \s* ;
    }{
        my $msg = $2;
        my $color = defined $3 ? lc $3 : '';
        my $tier  = $color eq 'green'  || $color eq 'lightgreen'  ? 'success'
                  : $color eq 'red'    || $color eq 'redaccent'   ? 'error'
                  : $color eq 'orange' || $color eq 'amber' || $color eq 'yellow' ? 'warning'
                  : 'info';
        $count++;
        "AppToast.$tier(context, '$msg');";
    }egsx;

    if ($count > 0) {
        # Ensure the AppToast import is present.
        unless ($src =~ m{components/feedback/app_toast\.dart}) {
            if ($src =~ m{^(import\s+'package:[^\n]+';)\n}m) {
                $src =~ s{^(import\s+'package:[^\n]+';)\n}
                         {$1\nimport 'package:bms_front_end/components/feedback/app_toast.dart';\n}m;
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
