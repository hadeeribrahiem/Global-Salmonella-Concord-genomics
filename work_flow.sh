# Run trimming:
#!/bin/bash
# Replace "read1.fastq" and "read2.fastq" with the actual file names of your R1 and R2 reads
#note: the name of read1 and read2 varies according to the name of each sample
read1=SRR6329251_Other_Sequencing_of_Salmonella_enterica_1.fastq.gz
read2=SRR6329251_Other_Sequencing_of_Salmonella_enterica_2.fastq.gz
adapter_sequence_read1="AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT"
adapter_sequence_read2="CAAGCAGAAGACGGCATACGAGATCGGTCTCGGCATTCCTGCTGAACCGCTCTTCCGATCT"

# Trimming adapters and perform quality control using Fastp
fastp -i "$read1" -o "S4read1_trimmed.fastq" --adapter_sequence "$adapter_sequence_read1" --qualified_quality_phred 20 --length_required 50 \
          --trim_front1 5 --trim_tail1 5 --thread 4 --html trimmed1.fastp.html --json trimmed1.fastp.json
fastp -i "$read2" -o "S4read2_trimmed.fastq" --adapter_sequence "$adapter_sequence_read2" --qualified_quality_phred 20 --length_required 50 \
          --trim_front2 5 --trim_tail2 5 --thread 4 --html trimmed2.fastp.html --json trimmed2.fastp.json


## Check the reads Quality control:
#!/bin/bash
for ((i=1; i<=110; i++)); do 
	fastqc *trimmed.fastq
done

## Check multiqc: 
mv *fastqc.html QC.fasta/
mv *fastqc.zip QC.fasta/
multiqc
pip3 install multiqc
multiqc QC.fasta/


## Alignment to Genome:
#!/bin/bash
# Full path to the bwa executable
BWA_EXECUTABLE="/home/menna98/miniconda3/envs/stage3/bin/bwa"
# Indexing reference sequence
$BWA_EXECUTABLE index /home/menna98/reference/ref_genomic.fna
# Define array of sample names and corresponding fastq files
read1_files=(*read1_trimmed.fastq)
read2_files=(*read2_trimmed.fastq)
# Loop over each sample
for ((i=0; i<${#read1_files[@]}; i++)); do
    # Extract sample name from file name
    sample=$(basename "${read1_files[i]}" "read1_trimmed.fastq")

    echo $sample
    
    read1="${read1_files[i]}"
    read2="${read2_files[i]}"
    ref="/home/menna98/reference/ref_genomic.fna"
    
    echo $read1
    
    mkdir -p repaired
    repair.sh in1="$read1" in2="$read2" out1="/home/menna98/trimmed/repaired/$read1" out2="/home/menna98/trimmed/repaired/$read2"
    
    # Create directory for BAM files if it doesn't exist
    mkdir -p "BAMS/${sample}"
    
    # Perform alignment using BWA mem
    $BWA_EXECUTABLE mem -t 8 "$ref" "/home/menna98/trimmed/repaired/$read1" "/home/menna98/trimmed/repaired/$read2" | /home/menna98/apps/samtools/bin/samtools view -h -b -o "BAMS/${sample}/${sample}.bam"
    
    echo "done"
done


# Removing duplicates: 
# 1- filtering 
#!/bin/bash
# Loop through 50 samples
for ((i=1; i<=50; i++)); do
    # Generate the sample ID with leading zeros if necessary
    sample_input="/home/menna98/BAM/S${i}.bam"
    sample_output="/home/menna98/BAM/filtered/S${i}_filtered.bam"
    
    # Execute the command for each sample
     samtools view -b -F 0xc "$sample_input" -o "$sample_output"
# Optionally, you can print a message indicating the completion of each sample
    echo "Processed sample $sample_input"
done

# 2- first sorting 
#sorting
#!/bin/bash
# Loop through 50 samples
for ((i=1; i<=50; i++)); do
# Generate the sample ID with leading zeros if necessary
    sample_input="/home/menna98/BAM/filtered/S${i}_filtered.bam"
    sample_output="/home/menna98/BAM/sorted/S${i}_sorted.n.bam" 
    
 # Execute the command for each sample
    samtools sort -@ 8 -n "$sample_input" -o "$sample_output"

# Optionally, you can print a message indicating the completion of each sample
    echo "Processed sample $sample_input"
done


# 3- mates
#!/bin/bash
for ((i=1; i<=50; i++)); do

    # Generate input and output
    sample_output="/home/menna98/BAM/fixmates/S${i}_fixmate.bam"
    sample_input="/home/menna98/BAM/sorted/S${i}_sorted.n.bam" 
    
    #execute the command for each sample
    samtools fixmate -m "$sample_input" "$sample_output"
    
    echo "Processed sample $sample_input"
done

# 4- second sorting 
#!/bin/bash
for ((i=1; i<=50; i++)); do

#Generating input and output
    sample_input="/home/menna98/BAM/fixmates/S${i}_fixmate.bam"
    sample_output="/home/menna98/BAM/second_sorted/S${i}_sorted.p.bam" 

# Execute the command for each sample
    samtools sort -@ 8 "$sample_input" -o "$sample_output"
# Optionally, you can print a message indicating the completion of each sample
    echo "Processed sample $sample_input"
done

#5- duplicate marking
#!/bin/bash
for ((i=1; i<=50; i++)); do
#Generating input and output
sample_input="/home/menna98/BAM/second_sorted/S${i}_sorted.p.bam" 
	sample_output="/home/menna98/BAM/duplicates/S${i}_dedup.bam"

# Execute the command for each sample
samtools markdup -r -@ 8 "$sample_input"  "$sample_output"

# Optionally, you can print a message indicating the completion of each sample
    	echo "Processed sample $sample_input"
done


## Assembling:
#!/bin/bash

for ((i=1; i<=50; i++)); do 
    spades.py --careful -o SPADES_OUT/S${i} -1 S${i}_read1.fastq.gz -2 S${i}_read2.fastq.gz
done

## Annotation 
#!/bin/bash
for ((i=1; i<=50; i++)); do 
    prokka --cpus 4 --prefix S${i}_contigs --kingdom Bacteria --locustag S${i}_contigs /home/menna98/salmonella_annotation/S${i}_contigs.fasta 
done

#AMR finder 
#!/bin/bash
for ((i=1; i<=50; i++)); do 
    staramr search --pointfinder-organism salmonella -o output/S${i} sequence/S${i}_contigs.fasta 
done


