#!/usr/bin/perl -w
use strict;
 BEGIN {$^W=0};
 
my $cur_coord=0;
my $cur_chrom="";
my $candidate_string="";

while(my $line =<STDIN>){
    chomp $line;
    
    if($line!~/>/){
        ##sequence
        my @seq_arr=split(//, $line);
        foreach(@seq_arr){
            my $base=$_;
          

    
    if ($base eq "T"){
        if ($candidate_string=~m/^A{5,}CA$/){ ###matches 
            
            print $cur_chrom."\t".($cur_coord-length($candidate_string)+1)."\t".$candidate_string."\n";
            $candidate_string="T";
            
        }
        elsif ($candidate_string eq "" or $candidate_string=~m/^TG$/ or $candidate_string=~m/^TGT+$/){ ##safe to append T to candidate string
            
            $candidate_string=$candidate_string."T";
            
            
        }else{
            
            $candidate_string="T";
            
            
        }
         
    } ##end case T
    elsif ($base eq "A"){
         if ($candidate_string=~m/^TGT{5,}$/){ ###matches 
            
            print $cur_chrom."\t".($cur_coord-length($candidate_string)+1)."\t".$candidate_string."\n";
            $candidate_string="A";
            
        } elsif($candidate_string=~m/^A{5,}CA$/){
        print $cur_chrom."\t".($cur_coord-length($candidate_string)+1)."\t".$candidate_string."\n";

            $candidate_string="AA";
            
        }
        elsif ($candidate_string eq "" or $candidate_string=~m/^A+$/ or $candidate_string=~m/^A{5,}C$/){ ##safe to append A to candidate string
            
            $candidate_string=$candidate_string."A";
            
            
        }else{
            
            $candidate_string="A";
            
            
        }
         
        
    } ##end case A
    elsif ($base eq "C"){
        
       if ($candidate_string=~m/^TGT{5,}$/ or $candidate_string=~m/^A{5,}CA$/){ ###matches 
            
            print $cur_chrom."\t".($cur_coord-length($candidate_string)+1)."\t".$candidate_string."\n";
            $candidate_string="";
       }elsif($candidate_string=~m/^A{5,}$/){ ##append C to  candidate string
        $candidate_string=$candidate_string."C";
        
       } else {
        
        $candidate_string="";
       }
        
    } ##end case C
    elsif ($base eq "G"){
        
        if ($candidate_string=~m/^TGT{5,}$/ ){ ###matches 
            
            print $cur_chrom."\t".($cur_coord-length($candidate_string)+1)."\t".$candidate_string."\n";
                         $candidate_string="TG";
        }elsif( $candidate_string=~m/^A{5,}CA$/){
 print $cur_chrom."\t".($cur_coord-length($candidate_string)+1)."\t".$candidate_string."\n";
           $candidate_string="";            
       }elsif($candidate_string eq "T"){ ##append G
        $candidate_string="TG";
        
       } else {
        
        $candidate_string="";
       }
        
    
  } ##end base G
    elsif( $base=~m/[agct]/){ ##repeat masked regions
        $candidate_string="";
        
        
    }
    
  $cur_coord++;
  }
    }else{
        
         $cur_chrom=$1  if ($line=~m/>(.+)/);
        
    }
}
    
###end of file
       if ($candidate_string=~m/^TGT{5,}$/ or $candidate_string=~m/^A{5,}CA$/){ ###matches 
            
            print $cur_chrom."\t".($cur_coord-length($candidate_string)+1)."\t".$candidate_string."\n";
                        #$candidate_string="";
        }   
        

    
    
    
    
    
    

    