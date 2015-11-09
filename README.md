#  Workflows for MiSeq amplicon processing 
      
      Questions : ramiro.logares at gmail.com      
      Distributed without warranty
      Runs as a Linux bashscript
      (The workflows have been used in an IBM iDataPlex cluster using SGE with CentOS Linux)

# How-To:

### 1) Needed software/scripts: 

      The following software needs to be in your user search path or in the SGE jobscript.  

      Usearch* : http://www.drive5.com/usearch/
      Vsearch : https://github.com/torognes/vsearch
      BayesHammer: http://bioinf.spbau.ru/spades
      Pear: http://sco.h-its.org/exelixis/web/software/pear/doc.html
      Augustus scripts : http://bioinf.uni-greifswald.de/augustus/
      miTag extraction protocol : https://github.com/ramalok/mitags_extraction_protocol/blob/master/miTAGs_extraction_protocol.zip  (doi: 10.1111/1462-2920.12250)
      blastn
      python
      perl

* If Usearch 64bits is not available, Vsearch and Usearch 32bits (free) are combined (need to use correct bashscript)

### 2) SSU Databases:
      Typically used databases (for classification and chimera-check):      
      SILVA 11x :http://www.arb-silva.de/download/archive/
      PR2 : http://ssu-rrna.org/
      Databases need to be formatted in order to be searchable by blastn
      
      These databases are given pre-formatted:
      SILVA_119.1_SSURef_Nr99_tax_silva.534968seqs_no_spacenames.fasta : SILVA 119.1, 99% clustering (16S & 18S)
      gb203_pr2_all_10_28_99p.min1000bp_max2000bp_45572seqs.fasta : PR2 gb203, 99% clustering (18S)
      MAS_V4_9059_names.fasta : MAS DB (in-house V4-18S DB) 

      https://www.dropbox.com/s/b3mimstj62bzssj/SSU_dbs.zip?dl=0

### 3) Input files and sample names:

      The input files are demultiplexed fastq files. There should be two compressed fastq files per sample R1 & R2.
      Files should be named e.g. 
      
      SAMPLE1_L001_R1.fastq.gz
      SAMPLE1_L001_R2.fastq.gz
      SAMPLE2_L001_R1.fastq.gz
      SAMPLE2_L001_R2.fastq.gz
      SAMPLEn_L001_R1.fastq.gz
      SAMPLEn_L001_R2.fastq.gz
   
      Files should include sample names and a number of characters that can be used as separators. In the example  
      above, L001 is used to extract the sample names from the file names (sample names are to the left of L001).
      One folder will be automatically generated for each sample, and corresponding files will me moved inside.

### 4) Run workflow scripts:
     
      Workflows are given as different bashscripts. Scripts filenames intend to be self-explanatory.
      Select the script you need:
      
      1) 97% clustering , no singletons
      qsub UPARSE_workflow_97clust_v1.5_usearch_64bits_no_singletons_pear_BayesHammer.sh
      
      More workflows will be added in the future
      
      NB: to select the options for your run, edit the bashscripts. You may need to adapt it for your hardware and queue system.
      
### 5) Output files:
      otu_table97.txt : otu table tab-separated
      otus97_repset_clean.fa : representative sequence set
      blastn_vs_SILVA_v11x_evalue10min4 : blast classification
      chimeric_OTUs.fa : chimeric otus
      uparse.out : results from Uparse clustering
      NB: other less important output files will be documented in the future
  
### 6) Other notes:

      Quality check: you may want to run a quality check of the sequences before running the workflow (e.g. this can be done with fastx : http://hannonlab.cshl.edu/fastx_toolkit/
      
      Primers: by default they are retained. You can remove them if needed.
      
      
