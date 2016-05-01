#!/bin/bash

## This is a bash script to process amplicon sequences sequenced with MiSeq 

### 

clear

echo "-------------------------------------------------------------------"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "               UPARSE workflow v2.0 | Apr. 2016                     "
echo " "
echo " by Ramiro Logares,  October  2014                                  "
echo " Includes Pear & BayesHammer"
echo " Works with Usearch v8x | 64bits [Another version for vsearch v1.5x] "
echo " "
echo " "
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "--------------------------------------------------------------------"

date

## Include below the information for your queue system

#######################
#######SGE BLOCK ######
#######################
#$ -cwd  
#$ -j y  
#$ -pe your_pe 24 # modify in all programs that need parallel environment
#$ -o ../
#$ -V
#$ -S /bin/bash
#$ -q all.q
#$ -N uparse_pipeline
#######################

##$ -M john.doe@icm.csic.es   # email job status, uncomment to activate
##$ -m abe


### DEFINE PATH ###

usearch=/home/rlogares/SOFTWARE/USEARCH/64bit_version/usearch8.1.1756_i86linux64
echo "usearch path:" $usearch



###################

## Move jobscript

mv UPARSE_workflow_97clust_v1.5_vsearch_based_no_singletons_pear_BayesHammer.sh  ../

echo " "
echo "Beginning renaming and file preparation"
echo " "

## NOTE: all fastq files must be compressed with gzip

#For fastq named as:

#P10B_S65_L001_R1_001.fastq.gz
#P10B_S65_L001_R2_001.fastq.gz

# Follwing oneliner puts R1 and R2 files within the same folder. 
# IMPORTANT: select characters that define sample name.
# In the case above this is "L001" (Anything can be used)
# OBS: if there is no expression, one needs to be added to the files.
# OBS2: check that all samples names are different after sample-name extraction

for i in $(awk -F"L001" '{print $1}' <(ls *.fastq.gz) | sort | uniq); do mkdir $i; mkdir $i/Raw; mv $i*.fastq.gz $i/Raw/.; done

# For each sample, there is now a folder containing both R1 & R2


echo "###################################"
echo "ERROR CORRECTION WITH BAYES HAMMER "
echo "###################################"

date

## Note: spades should be in your search path

for i in $(ls -d *); do cd $i; spades.py --only-error-correction -1 Raw/*_R1.* -2  Raw/*_R2.* -o $i.corrected ;cd ..; done

echo "########################################"
echo "DONE ERROR CORRECTION WITH BAYES HAMMER "
echo "########################################"
date

echo "#######################"
echo "Merging reads with Pear"
echo "#######################"


#######################
#### RUN PEAR #########
#######################

for i in $(ls -d *); do cd $i; pear -j 24 -n 200  -o $i  -f $i.corrected/corrected/*_R1.* -r $i.corrected/corrected/*_R2.* ;cd ..; done  


echo "################################"
echo "#### DONE PEAR read merging ####"
echo "################################" 

date


echo " #################################################################"
echo " Quality filter, length check (minlength=100bp), convert to FASTA "
echo " #################################################################"

for i in $(ls -d *); do cd $i; $usearch -fastq_filter *assembled.fastq -fastq_maxee 0.5 -fastq_minlen 100 -fastaout $i.longname.fna ;cd ..; done


echo " ######################################################################"
echo " DONE Quality filter, length check (minlength=100bp), convert to FASTA "
echo " ######################################################################"

date

######################################################
################# Simplify sequence names ############
######################################################

# The script : simplifyFastaHeaders.pl  should be in your search path
# export PATH=/path/augustus-3.0.3/scripts/:$PATH
# simplifyFastaHeaders.pl in.fa nameStem out.fa header.map

echo "######################## "
echo "Simplifying fasta headers"
echo "######################## "


for i in $(ls -d *); do cd $i; simplifyFastaHeaders.pl $i.longname.fna $i.seqnum $i.fna $i.map;cd ..; done

echo " "
echo "Putting reads into 5-3 direction, and extracting 16/18S per sample"
echo " "

echo "################################################################################################"
echo "##################### Reads are put into the same direction using HMM ##########################"
echo "################################################################################################"
date

## Below is the miTags extraction protocol from : doi: 10.1111/1462-2920.12250


cdbfasta=/path/cdbfasta  # Warning, 4 Gb limit! run over multiple file may be needed

mitags=/path/miTAGs_extraction_protocol

HMM3=/path/miTAGs_extraction_protocol/HMM3

scripts=/path/UPARSE/scripts # scripts from USEARCH


for i in $(ls -d *); do cd $i; $cdbfasta/cdbfasta $i.fna ;cd ..; done

for i in $(ls -d *); do cd $i; $mitags/rna_hmm3.py -i $i.fna -o $i.rRNA -m ssu,lsu -k bac,arc,euk -p 24   -L $HMM3;cd ..; done  # include -p n for multithreading

for i in $(ls -d *); do cd $i; $mitags/parse_rna_hmm3_output.pl $i.rRNA ;cd ..; done

for i in $(ls -d *); do cd $i; $mitags/extract_rrna_seqs.pl $i.rRNA.parsed 1 100 ;cd ..; done  # 100 min read lenght


echo "###############################"
echo "Reads in the 5-3 direction done"
echo "###############################"
date

echo "#######################################"
echo "Renaming into UPARSE and concatenating"
echo "#######################################"


## Rename into UPARSE format

for i in $(ls -d *); do cd $i; cat *S_rRNA > $i.rRNA.fna ;cd ..; done

for i in $(ls -d *); do cd $i; sed "-es/^>\(.*\)/>\1;barcodelabel=$i;/" < $i.rRNA.fna > $i.rRNA.uparse.fna ;cd ..; done


mkdir ../concatenated_reads_same_direction

for i in $(ls -d *); do cd $i; cp $i.rRNA.uparse.fna ../../concatenated_reads_same_direction ;cd ..; done

cat ../concatenated_reads_same_direction/*rRNA.uparse.fna > ../concatenated_reads_same_direction/all_reads_5_3dir_UPARSEfmt.fna

mv ../concatenated_reads_same_direction/all_reads_5_3dir_UPARSEfmt.fna .

rm -rf ../concatenated_reads_same_direction



echo "###########################################"
echo "Done renaming into UPARSE and concatenating"
echo "###########################################"
date

###########################################################################################################
###########################################################################################################
###############################	Select your reference DB for chimera checking #############################
###########################################################################################################
###########################################################################################################


db=/path/to/SSUdb

##db=/share/data/databases/SILVA/SILVA119/NR95/SILVA_119_SSURef_Nr95_tax_silva_trunc.min500bp_127497seqs_nospacenames.fasta 

echo " "
echo "Reference database in: " $db
echo " "

###########################################################################################################
###########################################################################################################

#### UPARSE START ######

echo "-------------------------------------------------------------------"
echo "Starting Uparse"
echo ""
echo ""
echo "Expected input file: all_reads_5_3dir_UPARSEfmt.fna"
echo ""
echo "Dereplicating"
date
echo "-------------------------------------------------------------------"

echo "1) Dereplication"

$usearch -derep_fulllength all_reads_5_3dir_UPARSEfmt.fna -fastaout all_reads_5_3dir_UPARSEfmt_dereplicated.fna -sizeout

###########
#Variables#
###########

reads_derep=all_reads_5_3dir_UPARSEfmt_dereplicated.fna
reads=all_reads_5_3dir_UPARSEfmt.fna

echo "Reads file:" $reads
echo " "
echo "Dereplicated reads file:" $reads_derep

echo "2) Abundance sort and discard singletons"

$usearch -sortbysize $reads_derep -fastaout sorted_reads.fa -minsize 2


echo "3) OTU clustering with UPARSE"

## $usearch -cluster_otus  sorted_reads.fa -otu_radius_pct 1 -otus otus99_repset.fa # cluster at 99%, remove -otu_radius_pct 1 for default clustering at 97%

$usearch -cluster_otus  sorted_reads.fa  -otus otus97_repset.fa -uparseout uparse.out   # 97 perc clustering default

echo "4) Chimera filtering using reference database"

$usearch -uchime_ref otus97_repset.fa -db $db -strand plus -uchimeout results.uchime -nonchimeras otus97_repset_nochimera.fa -chimeras chimeric_OTUs.fa

echo "5) Labeling OTU repseq"

python $scripts/fasta_number.py otus97_repset_nochimera.fa OTU_ > otus97_repset_clean.fa

echo "6) Map all reads (including singletons) back to OTUs. Using -maxhits 1 -maxaccepts 20 -maxrejects 50000 for higher sensitivity. Adjust -threads to your resources"

$usearch -usearch_global $reads -db otus97_repset_clean.fa -strand plus -id 0.97 -uc map97.uc -maxhits 1 -maxaccepts 20 -maxrejects 50000 -threads 24

echo "7) Generate OTU table"

python $scripts/uc2otutab.py map97.uc > otu_table97.txt

############################################################
############# Taxonomy classification ######################
############################################################

echo "8) Taxonomic classification"

# Select accordingly

#silva=/home/rlogares/databases/SILVA/SILVA119.1/NR99/blastdb/SILVA_119.1_SSURef_Nr99_tax_silva.534968seqs_no_spacenames.fasta # NR99
#MAS=/home/rlogares/databases/PROTIST_MAS_V4_9059/MAS_V4_9059/forBLAST/MAS_V4_9059_names.fasta
#PR2=/share/data/protist/DB/PR2_vgb203/99perc_clustering/blastdb/gb203_pr2_all_10_28_99p.min1000bp_max2000bp_45572seqs # NR99

## Blast instructions
#blastn -db $silva -query otus97_repset_clean.fa  -outfmt '6 std qlen' -perc_identity 75 -max_target_seqs 1 -evalue 0.0001 -out blastn_vs_SILVA_v119.1_evalue10min4  -num_threads 24
#blastn -db $MAS -query otus99_repset_clean.fa  -outfmt '6 std qlen' -perc_identity 75 -max_target_seqs 1 -evalue 0.0001 -out blastn_vs_MAS_V4_v9059_evalue10min4  -num_threads 24
#blastn -db $PR2 -query otus99_repset_clean.fa  -outfmt '6 std qlen' -perc_identity 75 -max_target_seqs 1 -evalue 0.0001 -out blastn_vs_PR2_vgb203_evalue10min4  -num_threads 24












