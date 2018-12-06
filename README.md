# biotools
a collection of random bioinformatics scripts

look_for_special_homopolymers_across_fasta.pl- Look for TGT+ or ACA+ homopolymers in FASTA files and report their locations

floor_data_matrix.pl- floor data table to specific value, allowing the user to skip columns

retrieve_select_fields_from_VCF.pl- parse a VCF file (tested on version 4.2) and retrieve user-specified fields (for example: AF, AD, etc.) and output them in a user-friendly tab delimited format with one alternate allele per line

shannon_entropy_score.pl- compute Shannon entropy scores of a  data matrix. This will assume the data matrix is in the following tab-delimited format:

    chr start stop value1 value2 value3...


