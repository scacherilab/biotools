#!/usr/bin/perl -w
use strict;
no warnings;
my ($file_name, $start_col, $step_size, $skip_header)=@ARGV;

if ($#ARGV<2) {
    die ("Usage: paste_verify.pl file_name start_col_to_verify step_size (skip_header) \n");
}


open(INPUT, "<$file_name") || die ("Can't open $file_name\n");
my $line_counter=0;

while (my $line=<INPUT>) {
    chomp $line;
    $line_counter++;
    if ($skip_header eq "skip_header" and $line_counter==1){
        
    }else {
    
    
    my @liner=split(/\t|\s+/, $line);
  my  $cur_col1_to_check=$start_col-1;
  my $cur_col2_to_check=$start_col-1+$step_size;
    
    for my $i ($start_col-1..$#liner){
        if ($cur_col2_to_check >$#liner) {
           
        }elsif ($liner[$cur_col1_to_check] eq $liner[$cur_col2_to_check]) {
            $cur_col1_to_check=$cur_col2_to_check;
            $cur_col2_to_check=$cur_col1_to_check+$step_size;
        
        }else {
            
            die "Improperly pasted file at line $line_counter! Columns ".($cur_col1_to_check+1)." (".$liner[$cur_col1_to_check].") and ".($cur_col2_to_check+1)." (".$liner[$cur_col2_to_check].")  don't match. \n";
        }
        
       
    }
    }
    
}

print "Processed $line_counter lines. No issues.\n";


