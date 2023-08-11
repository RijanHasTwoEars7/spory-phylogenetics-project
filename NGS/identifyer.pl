#!/usr/bin/perl

use strict;
use warnings;

my $dir = ".";

opendir(my $dh, $dir) || die "can't opendir $dir: $!";

# Loop over all files in directory
while (my $file = readdir($dh)) {
  next if ($file =~ m/^\./); # Ignore hidden files
  
  my $filepath = "$dir/$file";
  my $substr = "NOT FOUND";
  
  # Open file and read first five lines
  open(my $fh, "<", $filepath) || die "can't open $filepath: $!";
  my @lines;
  for (1..5) {
    my $line = readline($fh);
    last unless defined $line;
    push @lines, $line;
  }
  close($fh);
  
  # Search for pattern in each line
  foreach my $line (@lines) {
    if ($line =~ m/-([A-Z]{4})-/) {
      $substr = $1;
      last;
    }
  }
  
  # Print file name and substring (or "NOT FOUND")
  print "$file\t$substr\n";
}

closedir($dh);

