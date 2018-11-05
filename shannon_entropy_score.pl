#!/usr/bin/perl -w
use List::Util qw[min max];

if($#ARGV<0){die "shannon_entropy_score.pl <file to score (this format: chrom\tstart\tstop\tq-normed_sig1\tq_normed_sig2\tq_normed_sig3...\n>"};

    my $qnormed_file=$ARGV[0];
   
   
open(QNORMED, "<$qnormed_file") || die "Can't open file $!\n";
    
    while (my $line=<QNORMED>){
	chomp $line;
	my @liner=split(/\t|\s+/, $line);
	
	if($liner[3]=~m/^\d+.*\d*$/){
	
	my $sum=0;
	my @s_arr=();
	
	my @data_only=@liner;
	splice(@data_only, 0, 3);
	
	foreach(@data_only){$sum+=$_;}
	
	@s_arr=map{$_/$sum} @data_only;
	@H_enh_MCF_arr=map{-$_*log2($_)} @s_arr;
	
	my $H_enh_MCF=0;
	foreach(@H_enh_MCF_arr){$H_enh_MCF+=$_;}
	
	my @q_scores=map{$H_enh_MCF-log2($_)} @s_arr;
	my $last_q_sc=pop @q_scores;
	print  map { $_."\t" } @liner;
	print  map{$_."\t"} @q_scores;
	print $last_q_sc;
	print  "\n";
	}
	else{
	    
	    print $line."\t".join("\t", @liner[3..$#liner])."\n";
	}
	
    }

    
sub log2 {
	my $n = shift;
	$n=max($n,0.0000000001);
	return (log($n)/ log(2));
	
}