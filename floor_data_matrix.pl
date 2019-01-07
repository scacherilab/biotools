#!/usr/bin/perl -w
use strict;

if ($#ARGV<2){die "Usage: floor_expression_data.pl <input_file> <column_to_start_with (i.e. 6)> <min_val (i.e. 30)>\n"; }
my ($input_file, $start_num_column, $min_val_to_round_to)=@ARGV;
open IN, "<", $input_file || die "Can't open $input_file\n";
while(my $line=<IN>){
    chomp $line;
    if ($line=~m/start/){print $line."\t"."\n";}
    else{
    my @liner=split(/\t|\s+/, $line);
    my @non_expr_cols=splice(@liner,0, $start_num_column-1);
    print join ("\t", @non_expr_cols)."\t";
    print $_<$min_val_to_round_to ? "$min_val_to_round_to\t" : "$_\t" foreach(@liner);
    print "\n";
    }
}





