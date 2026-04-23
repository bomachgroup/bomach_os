#!/usr/bin/env perl
# Second-pass SnackBar → AppToast migration using a simpler regex that
# tolerates dynamic Text() arguments.
#
# Pattern handled:
#   ScaffoldMessenger.of(<ctx>).showSnackBar(
#     [const] SnackBar(
#       content: [const] Text(<EXPR_NO_COMMA_NO_PAREN>),
#       [backgroundColor: <SIMPLE_COLOR>,]
#       [duration: ...,]
#       [behavior: ...,]
#       [shape: ..., margin: ..., elevation: ...]
#     ),
#   );
#
# Where <EXPR_NO_COMMA_NO_PAREN> is any run of characters that doesn't
# contain parentheses or top-level commas. That's conservative but catches
# `message`, `e.toString()` → no (has parens), `"..."`, `"a $b c"`, etc.
# Falls back to `.info()` if no backgroundColor or color is unrecognised.

use strict;
use warnings;
use File::Find;

my $root = shift @ARGV or die "usage: $0 <lib-dir>\n";

my @files;
find(sub { push @files, $File::Find::name if /\.dart$/ }, $root);

my ($files_touched, $replacements) = (0, 0);

for my $path (@files) {
    next if $path =~ m{app_toast\.dart$};

    open my $fh, '<', $path or next;
    local $/; my $src = <$fh>; close $fh;

    my $count = 0;

    # Accept Text() containing any chars except ')' — i.e. no nested calls or tuples.
    # Accept trailing kwargs on the SnackBar that don't contain ')' or ';'.
    $src =~ s{
        ScaffoldMessenger\.of\(\s*(\w+)\s*\)
        \s* \.showSnackBar\(
        \s* (?:const\s+)? SnackBar\(
            \s* content: \s* (?:const\s+)? Text\(
                \s* ([^()]*?) \s*
            \)
            \s* ,?
            ( (?: \s* \w+ \s* : \s* [^();]*? \s* ,? )* )
            \s*
        \)
        \s* ,?
        \s* \)
        \s* ;
    }{
        my $ctx_name = $1;
        my $expr     = $2;
        my $args_raw = $3 || '';

        # Find backgroundColor: <expr> in the args (up to a comma or end).
        my $tier = 'info';
        if ($args_raw =~ /backgroundColor\s*:\s*([^,;]+?)\s*(?:,|$)/) {
            my $c = $1;
            $c =~ s/^\s+|\s+$//g;
            if    ($c =~ /^Colors\.(green|greenAccent|lightGreen)\b/)      { $tier = 'success' }
            elsif ($c =~ /^AppColors\.success\b/)                          { $tier = 'success' }
            elsif ($c =~ /^Colors\.(red|redAccent|deepOrange\[900\])\b/)   { $tier = 'error'   }
            elsif ($c =~ /^AppColors\.(danger|red)\b/)                     { $tier = 'error'   }
            elsif ($c =~ /^Colors\.(orange|amber|yellow|deepOrange)\b/)    { $tier = 'warning' }
            elsif ($c =~ /^AppColors\.(warning|orange)\b/)                 { $tier = 'warning' }
            elsif ($c =~ /^Colors\.(blue|lightBlue|cyan)\b/)               { $tier = 'info'    }
            elsif ($c =~ /^AppColors\.(info|primary)\b/)                   { $tier = 'info'    }
            # Ternary: leave tier as info; callers can refine manually.
        }

        $count++;
        "AppToast.$tier($ctx_name, $expr);";
    }egsx;

    if ($count > 0) {
        unless ($src =~ m{components/feedback/app_toast\.dart}) {
            if ($src =~ m{^(import\s+[^\r\n]+;)(\r?\n)}m) {
                $src =~ s{^(import\s+[^\r\n]+;)(\r?\n)}
                         {$1$2import 'package:bms_front_end/components/feedback/app_toast.dart';$2}m;
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
