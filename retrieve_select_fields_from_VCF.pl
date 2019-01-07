#!/usr/bin/perl -w

use strict;
use Pod::Usage;
use List::Util qw (max);
use Data::Dumper;
BEGIN {$^W=0};


###input parameters
if ($#ARGV < 1) {die "Usage:./retrieve_select_fields_from_VCF.pl vcf_file comma_delimited_fields_to_search\n";}

my ($file, $fields_to_search_for)=@ARGV;
my %format_hash=();
my %header_hash=();
my @fields_to_search_for="";
my @final_header_column_order=();
my $header_row_column_array_populated=0;
open(INPUT, "<$file") || die ("Can't open $file\n");


##populate fields_to_search for array
if($fields_to_search_for=~m/,/){
     @fields_to_search_for=split(/,/,$fields_to_search_for);
}else{
    @fields_to_search_for=$fields_to_search_for;
    
}
   
  
##start looping through file
while (my $line=<INPUT>){
    chomp $line;
if ($line=~m/##(FORMAT|INFO)=<ID=(.+),Number=(R|A|\d+),.+/){ ##retrieve comment field info
 
    ($format_hash{$2}{'number'},$format_hash{$2}{'type'})= ($3,$1);
    
}elsif($line=~m/#CHROM/){ #header info
        
      my @liner=split(/\t/, $line);
      for my $i (0..$#liner){ $header_hash{$i}=$liner[$i]};

        
}elsif ($line=~m/^chr.+/) { ##process data line
       my ($chr, $pos, $id, $ref,$alt, $qual, $filter,$info, $format, @samples_format_values)=split(/\t/, $line);
       my %temp_hash=();
       my @alt_arr=();
       
       ##store alternate alleles in array even if there is only 1
       if($alt=~m/,/){@alt_arr=split(/,/, $alt);
        }else{push @alt_arr, $alt; }

        ##finish populating column info hash
        for my $i (0..$#fields_to_search_for){
          my $cur_field_to_search=$fields_to_search_for[$i];
          updateFormatHash( $line, $cur_field_to_search);
        }
        
        ###now start populating temp hash with record data
        
        for my $i (0..$#alt_arr){
        push @{$temp_hash{'chr'}},$chr;
        push @{$temp_hash{'pos'}},$pos;
        push @{$temp_hash{'id'}},$id;
        push @{$temp_hash{'ref'}},$ref;
        push @{$temp_hash{'alt'}},$alt_arr[$i];
        push @{$temp_hash{'filter'}},$filter;
        
        push @final_header_column_order, ('chr','pos','id','ref','alt','filter') if $header_row_column_array_populated==0;
        
        
        ##figure out index of field of interest after splitting INFO or FORMAT columns and populate temp hash
        for my $j (0..$#fields_to_search_for){
           my $cur_field_to_search=$fields_to_search_for[$j];
           my ($index, $type, $number)=($format_hash{$cur_field_to_search}{'index'},$format_hash{$cur_field_to_search}{'type'},$format_hash{$cur_field_to_search}{'number'});
            
            if ($type eq 'FORMAT'){
                
                %temp_hash=populateTempHashFromFormatField(\%temp_hash, $cur_field_to_search, $i,  \@samples_format_values);
                
        }elsif ($type eq "INFO"){
                 %temp_hash=populateTempHashFromInfoField(\%temp_hash, $cur_field_to_search,  $info);
    
         }
        }
        print join("\t", @final_header_column_order)."\n" if $header_row_column_array_populated==0;
                    $header_row_column_array_populated=1;

    }
        #print results
        
                  #print Dumper(%temp_hash);

        for my $i (0..scalar @{$temp_hash{'chr'}}-1){
        foreach(@final_header_column_order){
        print $temp_hash{$_}[$i]."\t";
        }
        print "\n";
        }
    }else{
        
        ##do nothing
    }
    
}
 sub updateFormatHash{
    
    # %format_hash=$_[0];
    my $line=$_[0];
    my $cur_field_to_search=$_[1];
     my ($chr, $pos, $id, $ref,$alt, $qual, $filter,$info, $format, @samples_format_values)=split(/\t/, $line);

    if($format_hash{$cur_field_to_search}{'type'} eq "FORMAT"){
    my @format_liner=split(/:/, $format);
    for my $i (0..$#format_liner){         
         if ($format_liner[$i] eq $cur_field_to_search){           
            $format_hash{$cur_field_to_search}{'index'}=$i;
             last;               
            }                      
        }
   }elsif ($format_hash{$cur_field_to_search}{'type'} eq "INFO"){
        
     my @info_liner=split(/;/, $info);
    for my $i (0..$#info_liner){
        if($info_liner[$i]=~m/(.+)=.*/){
         if ($1 eq $cur_field_to_search){           
            $format_hash{$cur_field_to_search}{'index'}=$i;
             last;               
            }
        }
        }    
        
    }else{
        
        
       die "Can't retrieve $cur_field_to_search because it's not a FORMAT or INFO field or its Number value isn't one of the following: <Integer>, R, A, or G. Exiting.\n";
    }
          # return %format_hash;     
            }
            
      
     
 sub populateTempHashFromFormatField{
  
  my %temp_hash=%{$_[0]};
  my $cur_field_to_search=$_[1];
  my $i=$_[2];
  my @samples_format_values=@{$_[3]};
  
     my ($index, $type, $number)=($format_hash{$cur_field_to_search}{'index'},$format_hash{$cur_field_to_search}{'type'},$format_hash{$cur_field_to_search}{'number'});

  
  for my $sample_idx (0..$#samples_format_values){ ##loop through each sample format column
                        my $cur_sample_name=$header_hash{9+$sample_idx};
                        my @format_values_arr=split(/:/,$samples_format_values[$sample_idx]);
                        my @format_values_arr2=split(/,/,$format_values_arr[$index]);
                         $format_values_arr2[$i]="NA" if $format_values_arr2[$i] eq "";
                         $format_values_arr[$index]="NA" if $format_values_arr[$index] eq "";
                         $format_values_arr2[$i+1] ="NA" if $format_values_arr2[$i+1] eq "";

                        if ($number eq 'A'){
                         push @{$temp_hash{$cur_sample_name."_".$cur_field_to_search}},$format_values_arr2[$i];
                         push  @final_header_column_order,$cur_sample_name."_".$cur_field_to_search if $header_row_column_array_populated==0;
                         } elsif ($number eq 'R'){
                         push @{$temp_hash{$cur_sample_name."_".$cur_field_to_search."_ref"}},$format_values_arr2[0];
                           push  @final_header_column_order,$cur_sample_name."_".$cur_field_to_search."_ref" if $header_row_column_array_populated==0;
                         push @{$temp_hash{$cur_sample_name."_".$cur_field_to_search."_alt"}},$format_values_arr2[$i+1];
                          push  @final_header_column_order,$cur_sample_name."_".$cur_field_to_search."_alt" if $header_row_column_array_populated==0;

                         } elsif ($number =~m/\d+/ or $number == "." or $number="G"){
                         push @{$temp_hash{$cur_sample_name."_".$cur_field_to_search}},$format_values_arr[$index];
                         push  @final_header_column_order,$cur_sample_name."_".$cur_field_to_search if $header_row_column_array_populated==0;

                         }else{
                         
                         #do nothing
                         
                        }
            }

  
  
  
  return %temp_hash;
  
  
  
 }
sub populateTempHashFromInfoField{
 
 my %temp_hash=%{$_[0]};
  my $cur_field_to_search=$_[1];
  my $info=$_[2];
  
  my ($index, $type, $number)=($format_hash{$cur_field_to_search}{'index'},$format_hash{$cur_field_to_search}{'type'},$format_hash{$cur_field_to_search}{'number'});

   my @info_column_liner=split(/;/, $info);
   my $tmp= $info_column_liner[$index];
   $tmp=~s/$cur_field_to_search=//g;
    push @{$temp_hash{$cur_field_to_search}},$tmp;
    push  @final_header_column_order,$cur_field_to_search if $header_row_column_array_populated==0;
              
                                #print Dumper(%temp_hash);

 return %temp_hash;
}