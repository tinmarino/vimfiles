#!/usr/bin/env perl
use v5.24; use strict;
use File::Slurp qw/read_file/;

sub main {
  my $file=shift || return 1;
  my $placeholder = shift // '^placeholder-include (.*)';
  my $callback = shift // 'cat';

  my $content = read_file $file;
  $content =~ s/\nplaceholder-include (.*?)\n/main($1, $placeholder, $callback)/ge;
  return $content;
}


# TODO check args
# TODO check if perl
# TODO get a callback
print main $ARGV[0], $ARGV[1], $ARGV[2];
