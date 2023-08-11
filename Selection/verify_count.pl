#!/usr/bin/perl

use strict;
use warnings;

sub count_sites {
    my ($filename) = @_;
    my $header = "";
    my $site_count = 0;
    my %counts;

    open(my $fh, "<", $filename) or die "Failed to open file: $filename $!";

    while (my $line = <$fh>) {
        chomp($line);
        if ($line =~ /^>/) {
            if ($header ne "") {
                $counts{$header} = $site_count;
            }
            $header = substr($line, 1);
            $site_count = 0;
        } else {
            $site_count += length($line);
        }
    }

    # Account for the last header
    if ($header ne "") {
        $counts{$header} = $site_count;
    }

    close($fh);

    return \%counts;
}

# Get the filename from the command line argument
my $filename = shift @ARGV;

# Check if the filename is provided
unless (defined $filename) {
    die "Usage: perl script.pl <filename>";
}

# Call the count_sites subroutine
my $result = count_sites($filename);

# Print the counts
foreach my $header (keys %$result) {
    my $count = $result->{$header};
    print "$header\t$count\n";
}