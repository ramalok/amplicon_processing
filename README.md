# amplicon_processing #

#!  Bash workflows for MiSeq amplicon processing 
                 (given without any warranty)


Observations:

1) Needed software/scripts 

  - Usearch : http://www.drive5.com/usearch/
  - Vsearch : https://github.com/torognes/vsearch
  - BayesHammer: http://bioinf.spbau.ru/spades
  - Pear: http://sco.h-its.org/exelixis/web/software/pear/doc.html
  - Augustus scripts : http://bioinf.uni-greifswald.de/augustus/
  - miTag extraction protocol scripts/programs: doi: 10.1111/1462-2920.12250
  - blastn
  - python
  - perl

NB: If Usearch 64bits is not available, Vsearch and Usearch 32bits (free) are combined.

2) SSU Databases
  - SILVA 11x
  - PR2

3) The workflow has been tested in an IBM iDataPlex cluster using SGE with CentOS.

4) There should be two compressed fastq files per sample R1 & R2. File should be named e.g. 
   SAMPLE1_L001_R1.fastq.gz
   SAMPLE1_L001_R2.fastq.gz
   SAMPLE2_L001_R1.fastq.gz
   SAMPLE2_L001_R2.fastq.gz
   SAMPLEn_L001_R1.fastq.gz
   SAMPLEn_L001_R2.fastq.gz
   
   Files should include sample names and a number of characters that can be used as separators. In the example    
   above, L001 is used to extract the sample names from the file names. One folder will be automatically generated    for each sample, and corresponding files will me moved inside.
   
   
   
   
