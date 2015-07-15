#!/usr/bin/perl -w
#
########################################################################################################
# matchext.pl: Matches file 1 and file 2 on a specific key and then outputs a list of values from
#              file 1 to file 2
#
# Options:
#
#         -f Name of file one
#         -g Name of file two
#         -h help
#         -k position of key in file one
#         -l position of key in file two
#         -v position of values in file one to be appended to file two
#         -m missing value character for values in file 2 that are not found in 1
#         -o output file name
#
# Example: matchext.pl -f file1 -g filetwo -k 1 -l 2 -v 3 4 7 -m . -o out
#
# Copyright: Beate Glaser & Dave Evans, University of Bristol, October 2010
########################################################################################################
# Perl trim function to remove whitespace from the start and end of the string

use Getopt::Long;
use strict;
use warnings;
my $opt_h;
my $opt_f;
my $opt_g;
my $opt_k;
my $opt_l;
my $opt_m;
my $opt_o;
my @fields;

GetOptions(
			"f=s"  => \$opt_f,
			"g=s"  => \$opt_g,
			"h"  => \$opt_h,
                        "k=i"  => \$opt_k,
                        "l=i"  => \$opt_l,
                        "v=i"  => \@fields,
                        "m=s"  => \$opt_m,
                        "o=s"  => \$opt_o
);

if ($opt_h) {
  print " matchext.pl -- Matches file 1 and file 2 on a specific key\n";
  print " and then outputs a list of values from file 1 to file 2\n\n";
  print " Options:\n\n";
  print "         -f Name of file 1\n";
  print "         -g Name of file 2\n";
  print "         -h help\n";
  print "         -k position of key in file 1\n";
  print "         -l position of key in file 2\n";
  print "         -v position of values in file 1 to be appended to file 2\n";
  print "         -m missing value character for values in file 2 that are not found in 1 \n";
  print "         -o output file name \n\n";
print " Example: perl matchext.pl -f file1 -g file2 -k 1 -l 2 -v 2 -v 3 -m . -o file.out \n\n";
  exit;
  $opt_h = 0;
}

if ($opt_f eq "") {
  die "Must specify file one using -f switch\n";
}

if ($opt_g eq "") {
  die "Must specify file one using -g switch\n";
}

open(FILE1, "$opt_f")|| die "Can't find file one $opt_f...exiting now...\n";
open(FILE2, "$opt_g")|| die "Can't find file two $opt_g...exiting now...\n";
open(OUT, ">$opt_o")|| die "Can't find output file $opt_o...exiting now...\n";

if ($opt_k==0) {
  die "Must specify position of key in file one using -k switch\n";
}

if ($opt_l==0) {
  die "Must specify position of key in file two using -l switch\n";
}

if ($opt_m eq "") {
  die "Must specify a missing value character -m switch\n";
}

if (!exists($fields[0])) {
  die "Must specify position of values in file one to be appended using -v switch\n";
}


print "Adding column @fields from file $opt_f to file $opt_g ...\n";

my $col = $opt_l-1;
my $ncol = @fields;

my @temp;
my @values;
my %key;

#Read in file 1
while(<FILE1>) {
  chomp;
  @temp = split;
  @values = ();
  foreach my $i (@fields) {
    push @values, $temp[$i-1];
  }
  $key{$temp[$opt_k-1]} = [@values];  #set key for values based on position
}
close FILE1;

#Read in file 2
# define missing value indicator
my $count=0;
while(<FILE2>) {
  chomp;
  print OUT $_,"\t";
  @temp = split;
  for(my $i=0;$i < $ncol;$i++) {
    if(!defined($key{$temp[$col]}[$i])) {
      print OUT "$opt_m \t";              #replace nonexisting values
      $count++;
    } else {
      print OUT "$key{$temp[$col]}[$i] \t";
    }
  }
  print OUT "\n";
}

close FILE2;
$count = $count/$ncol;
print "$count lines of file $opt_g were not found in $opt_f \n";

close OUT;

