#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;
use File::Spec::Functions qw(catfile);
use File::Copy;
use List::Util qw(sum);
use POSIX qw(strftime);
use File::Path qw(make_path);

my $location   = '';
my $extension  = '';

GetOptions(
    "location=s"  => \$location,
    "extension=s" => \$extension,
);

sub judge_equality {
    my ($current_file_counts) = @_;
    my %current_file_counts = %$current_file_counts;
    my $count = scalar keys %current_file_counts;
    my ($first_item) = (values %current_file_counts)[0];

    if ($count == 0){
        return "The file is empty";
    }

    my ($sum) = sum(values %current_file_counts);
    my ($average) = $sum / $count;

    if ($average == $first_item) {
        return "Uniform";
    }
    else {
        return "Not uniform";
    }
}

sub CountSequences {
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
        }
        else {
            $site_count += length($line);
        }
    }
    if ($header ne "") {
        $counts{$header} = $site_count;
    }
    close($fh);

    my $uniformity = judge_equality(\%counts);

    return ($uniformity, \%counts);
}

make_path("site_count_data");
make_path("site_count_data/uniform_files");
make_path("site_count_data/uniform_counts");
make_path("site_count_data/non_uniform_files");
make_path("site_count_data/non_uniform_counts");
make_path("site_count_data/empty_files");

opendir(my $dh, $location) or die "Cannot open directory $location: $!";
my @files = readdir($dh);
closedir($dh);

foreach my $file (@files) {
    next if $file =~ /^\.+$/;
    if (-f catfile($location, $file) && $file =~ m/\.$extension$/) {
        my ($uniformity, $counts) = CountSequences(catfile($location, $file));

        if ($uniformity eq 'Uniform') {
            my $new_location = catfile("site_count_data/uniform_files", $file);
            copy(catfile($location, $file), $new_location) or die "Copy failed: $!";

            my $uniform_count_file = catfile("site_count_data/uniform_counts", $file);
            open(my $fh, '>', $uniform_count_file) or die "Could not open file '$uniform_count_file' $!";
            foreach my $header (keys %$counts) {
                my $count = $counts->{$header};
                print $fh "$header\t$count\n";
            }
            close $fh;
        } elsif ($uniformity eq "The file is empty"){
                my $new_location = catfile("site_count_data/empty_files",$file);
                copy(catfile($location,$file),$new_location) or die "Copy failed: $!";                
}
        else {
            my $new_location = catfile("site_count_data/non_uniform_files", $file);
            copy(catfile($location, $file), $new_location) or die "Copy failed: $!";

            my $non_uniform_count_file = catfile("site_count_data/non_uniform_counts", $file);
            open(my $fh, '>', $non_uniform_count_file) or die "Could not open file '$non_uniform_count_file' $!";
            foreach my $header (keys %$counts) {
                my $count = $counts->{$header};
                print $fh "$header\t$count\n";
            }
            close $fh;
        }
    }
}
