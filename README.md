# amplicon_processing #

Bash workflows for MiSeq amplicon processing.



Observations:

1) Scripts are run in a cluster (IBM iDataPlex) using SGE.

2) Needed software/scripts 

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

3) SSU Databases
- SILVA 11x
- PR2
