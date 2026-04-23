#!/usr/bin/env perl
# Conservative migration: simple showDialog + AlertDialog → DialogScaffold.show.
#
# Only touches the straightforward pattern:
#
#   showDialog(
#     context: <ctx>,
#     builder: (<param>) => AlertDialog(
#       title: Text(<TITLE_EXPR>),
#       content: <CONTENT_EXPR>,
#       actions: [<ACTIONS>],
#     ),
#   );
#
# Becomes:
#
#   DialogScaffold.show(
#     <ctx>,
#     title: <TITLE_EXPR>,                         // stripped from Text(...) if wrapped
#     size: DialogSize.sm,
#     body: <CONTENT_EXPR>,
#     actions: [<ACTIONS>],
#   );
#
# After substitution, inserts the DialogScaffold import if missing.

use strict;
use warnings;
use File::Find;

my $root = shift @ARGV or die "usage: $0 <lib-dir>\n";

my @files;
find(sub { push @files, $File::Find::name if /\.dart$/ }, $root);

my ($files_touched, $replacements) = (0, 0);

# Helper: given a string starting with "[", find the index of the matching "]"
# accounting for nested brackets, strings and parens. Returns -1 on failure.
sub match_bracket {
    my ($s, $start, $open, $close) = @_;
    my $depth = 0;
    my $i = $start;
    my $len = length $s;
    my $in_str = '';           # '' | "'" | '"'
    while ($i < $len) {
        my $c = substr($s, $i, 1);
        if ($in_str) {
            if ($c eq '\\') { $i += 2; next }
            if ($c eq $in_str) { $in_str = ''; }
        } else {
            if ($c eq "'" || $c eq '"') { $in_str = $c; }
            elsif ($c eq $open)  { $depth++; }
            elsif ($c eq $close) { $depth--; return $i if $depth == 0; }
        }
        $i++;
    }
    return -1;
}

for my $path (@files) {
    # Skip the scaffold definition itself.
    next if $path =~ m{dialog_scaffold\.dart$};

    open my $fh, '<', $path or next;
    local $/; my $src = <$fh>; close $fh;

    my $count = 0;
    my $out_src = '';
    my $cursor = 0;

    while ($src =~ m{
        (showDialog\s*\(\s*
            context:\s*(\w+)\s*,\s*
            builder:\s*\(\s*(\w+)\s*\)\s*=>\s*
            (?:const\s+)? AlertDialog\s*\(\s*)
        (title:\s*(?:const\s+)?Text\s*\(\s*([^,()]+?)\s*\)\s*,\s*)?
        content:\s*
    }gxs) {
        my $match_start = $-[0];
        my $header_end  = $+[0];
        my $ctx_name    = $2;
        my $builder_arg = $3;   # builder param name; we'll rename refs to match ctx_name
        my $title_expr  = $5;   # may be undef if no title
        my $prefix_before = substr($src, $cursor, $match_start - $cursor);

        # Find the end of the content expression: scan from $header_end until
        # we hit a top-level comma or ')' at depth 0 (balancing parens, braces,
        # brackets, strings).
        my $i = $header_end;
        my $len = length $src;
        my @stack;
        my $in_str = '';
        my $content_start = $i;
        my $content_end = -1;
        while ($i < $len) {
            my $c = substr($src, $i, 1);
            if ($in_str) {
                if ($c eq '\\') { $i += 2; next }
                if ($c eq $in_str) { $in_str = ''; }
            } else {
                if ($c eq "'" || $c eq '"') { $in_str = $c; }
                elsif ($c eq '(' || $c eq '[' || $c eq '{') { push @stack, $c; }
                elsif ($c eq ')' || $c eq ']' || $c eq '}') {
                    last unless @stack;   # top-level close → give up
                    pop @stack;
                }
                elsif ($c eq ',' && !@stack) {
                    $content_end = $i;
                    last;
                }
            }
            $i++;
        }

        if ($content_end < 0) {
            # bail on this match; append the original and advance cursor
            $out_src .= substr($src, $cursor, $header_end - $cursor);
            $cursor = $header_end;
            next;
        }

        my $content_expr = substr($src, $content_start, $content_end - $content_start);
        $content_expr =~ s/^\s+|\s+$//g;

        # Expect: actions: [ ... ] then ) then ) then ;
        my $rest = substr($src, $content_end + 1);
        unless ($rest =~ m{\G\s*actions:\s*\[}gxs) {
            $out_src .= substr($src, $cursor, $header_end - $cursor);
            $cursor = $header_end;
            next;
        }
        my $actions_start_in_rest = pos($rest);      # char index into $rest right after '['
        my $actions_open_abs = $content_end + 1 + $actions_start_in_rest - 1;  # abs index of '['
        my $actions_close_abs = match_bracket($src, $actions_open_abs, '[', ']');
        if ($actions_close_abs < 0) {
            $out_src .= substr($src, $cursor, $header_end - $cursor);
            $cursor = $header_end;
            next;
        }
        my $actions_expr = substr($src, $actions_open_abs + 1,
                                  $actions_close_abs - $actions_open_abs - 1);
        $actions_expr =~ s/^\s+|\s+$//g;

        # After ']' we expect: optional ',' then ')' (AlertDialog close) then optional ',' then ')' (showDialog close) then ';'
        my $tail_start = $actions_close_abs + 1;
        my $tail = substr($src, $tail_start);
        unless ($tail =~ m{\A \s* ,? \s* \) \s* ,? \s* \) \s* ; }x) {
            $out_src .= substr($src, $cursor, $header_end - $cursor);
            $cursor = $header_end;
            next;
        }
        my $tail_match_len = $+[0];
        my $full_end = $tail_start + $tail_match_len;

        # Skip if title is missing — we need a title for DialogScaffold.
        unless (defined $title_expr) {
            $out_src .= substr($src, $cursor, $full_end - $cursor);
            $cursor = $full_end;
            next;
        }

        my $title_out = $title_expr;
        $title_out =~ s/^\s+|\s+$//g;

        # Rename references to the builder's own arg (e.g. `c`, `ctx`, `_`,
        # `dialogContext`) so they point at the outer `context` variable,
        # which is what `DialogScaffold.show` now has access to. Word-boundary
        # match prevents clobbering other identifiers.
        if ($builder_arg ne $ctx_name && $builder_arg ne '_') {
            $content_expr =~ s/\b\Q$builder_arg\E\b/$ctx_name/g;
            $actions_expr =~ s/\b\Q$builder_arg\E\b/$ctx_name/g;
        }

        my $replacement = <<"END";
DialogScaffold.show(
      $ctx_name,
      title: $title_out,
      size: DialogSize.sm,
      body: $content_expr,
      actions: [$actions_expr],
    );
END
        $replacement =~ s/\n\z//;   # drop trailing newline — we'll keep existing trailing

        $out_src .= $prefix_before . $replacement;
        $cursor = $full_end;
        $count++;
    }
    $out_src .= substr($src, $cursor);

    if ($count > 0) {
        # Ensure DialogScaffold import is present.
        unless ($out_src =~ m{components/dialog/dialog_scaffold\.dart}) {
            if ($out_src =~ m{^(import\s+[^\r\n]+;)(\r?\n)}m) {
                $out_src =~ s{^(import\s+[^\r\n]+;)(\r?\n)}
                             {$1$2import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';$2}m;
            }
        }
        open my $out, '>', $path or next;
        print $out $out_src;
        close $out;
        $files_touched++;
        $replacements += $count;
        print "  $path: $count replacement(s)\n";
    }
}

print "\nDone. $replacements replacement(s) across $files_touched file(s).\n";
