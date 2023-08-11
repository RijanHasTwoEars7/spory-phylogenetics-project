#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;

# Get the directory with the .fa files
my $dir = '.';

# Get all the .fa files in the directory
opendir(my $dh, $dir) or die "Can't open directory $dir: $!";
my @files = grep { /\.fa$/ && -f "$dir/$_" } readdir($dh);
closedir($dh);

# Process each .fa file
foreach my $file (@files) {
    # Open the input file for reading
    open my $in_fh, '<', "$dir/$file" or die "Cannot open '$file' for reading: $!";

    # Construct the output filename
    my $basename = fileparse($file, qr/\.[^.]*/);
    my $out_file = "$dir/$basename.headers";

    # Open the output file for writing
    open my $out_fh, '>', $out_file or die "Cannot open '$out_file' for writing: $!";

    # Loop through each line in the input file
    while (my $line = <$in_fh>) {
        # If the line starts with '>', write it to the output file
        if ($line =~ /^>/) {
            print $out_fh $line;
        }
    }

    # Close the input and output files
    close $in_fh;
    close $out_fh;
}

print "All done!\n";

