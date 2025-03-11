# Global-Salmonella-Concord-genomics

Video: https://drive.google.com/file/d/1fqrTlokfiPsQyLAqZpuiVWtfhb9q_59I/view?usp=drive_link

## Background/Introduction:
Salmonella enterica serovar Concord (S. Concord) is a non-typhoidal Salmonella serovar that often causes life-threatening invasive   infections,   particularly   in   sub-Saharan   Africa.   It   necessitates
antimicrobial treatment however, it is associated with frequent multidrug-resistant strains. Despite
periodic reports, there is still much to learn about the bacteria.

## Significance:
Understanding the genetic diversity, evolution and antimicrobial resistance (AMR) profiles of S.
Concord is crucial for treating infections caused by this pathogen, especially in low- and middle-income
countries, where S. Concord is severely common and treatment options are limited. This study is
essential for the surveillance, prevention and management of Salmonella infections and promote
responsible use of antimicrobials. 

## Aims:
The study seeks to understand and identify the genetic diversity, evolution and antimicrobial resistance
(AMR) profiles of S. Concord. 

## Pipeline:
The study analysed 50 confirmed S. Concord isolates and underwent rigorous quality control measures. The reference genome was obtained through PacBio sequencing. Genomes were assembled and annotated. AMR gene detection was performed to characterize AMR profiles across isolates.

## Tools Used

The following bioinformatics tools are used in this workflow:

- FastQC
- Fastp
- BWA
- SAMtools
- BCFtools
- VCFtools
- MultiQC
- spades.py
- prokka
- staramr
- pip3

## Results

Through our analysis, we came across many interesting findings: 
1) the randomly selected isolates were resistant to different categories of antibiotics, including Aminoglycosides, Beta-lactam antibiotics, Macrolides, Quinolones, Sulphonamides, Tetracyclines, and Trimethoprim. 
2) parC (T57S) gene mutation appeared in almost all isolates. 
3) The first isolate has many AMR genes, which means that it resists a wide range of antibiotics. 
