#!/usr/bin/env python

import  sys,os, numpy;


def median(my_list):
    return numpy.median([float(i) for i in my_list])

def mean(my_list):
    return numpy.mean([float(i) for i in my_list])




##first reset PYTHONPATH
old_python_path=os.environ["PYTHONPATH"]
os.environ["PYTHONPATH"] = ""



##check number of arguments
if (len(sys.argv)<4):
    print "Usage: "+sys.argv[0]+" path/to/dir/with/cov/files step_size output_prefix"
    exit()
dir_with_cov_files=sys.argv[1]
step_size=int(sys.argv[2])
output_prefix=sys.argv[3]



##open output file handles
MEAN_FILE= open(output_prefix+'_means.wig', 'w')
MEDIAN_FILE= open(output_prefix+'_medians.wig', 'w')


##wig file headers
MEAN_FILE.write("track type= wiggle_0 name=%s\n"%output_prefix)
MEDIAN_FILE.write("track type= wiggle_0 name=%s\n"%output_prefix)

###temp variables
mean_file_chrom_header_set=0
median_file_chrom_header_set=0
last_chrom="NA"
cur_chrom="NA"


#get current list of files and create file handles for them
files_in_cur_dir = os.listdir( dir_with_cov_files )
#list_of_file_handles=[[] for n in range(0,len(files_in_cur_dir)-1)]
list_of_file_handles=map(lambda x: open(dir_with_cov_files+'/'+x),files_in_cur_dir)



first_file_handle=list_of_file_handles.pop(0) ##removes first file handle

first_file_line=first_file_handle.readline().strip()
cur_line_number=0 ##this will be incremented and checked against modulo step_size

while(first_file_line):
    
    first_file_chr,first_file_pos, first_file_reads=first_file_line.split('\t') ##get positional info and signal of the 1st file
   
    
    if (last_chrom == "NA" or last_chrom!=first_file_chr or  mean_file_chrom_header_set==0 or median_file_chrom_header_set==0): ##if these conditions are met, parsing a new chromosome
        mean_file_chrom_header_set=1
        median_file_chrom_header_set=1
        MEAN_FILE.write('variableStep chrom=%s\n'%first_file_chr)
        MEDIAN_FILE.write('variableStep chrom=%s\n'%first_file_chr)
        last_chrom=first_file_chr
        
    temp_list_for_stats=[]
    temp_list_for_stats.append(first_file_reads)
    
    for other_file_handle in list_of_file_handles: ##loop through the rest of the files, extract positional info and signal
        other_file_handle_line=other_file_handle.readline().strip()
        
        other_file_line_arr=other_file_handle_line.split('\t')
        other_file_reads=other_file_line_arr[2]
        temp_list_for_stats.append(other_file_reads)
    
   
    if (cur_line_number % step_size ==0 ): ##only print median and mean for every <STEP-SIZE> -th line
        cur_median=median(temp_list_for_stats) ##get the median for current chr and position
        MEDIAN_FILE.write('%s\t%0.2f\n' % (first_file_pos,cur_median))
        cur_mean=mean(temp_list_for_stats) ##get the mean for current chr and position
        MEAN_FILE.write('%s\t%0.2f\n' % (first_file_pos,cur_mean))
        
    first_file_line=first_file_handle.readline().strip()
    cur_line_number+=1  
    ##convert wig to bigwig



            

