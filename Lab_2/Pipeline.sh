#!/bin/bash

###############################################################################
# Project : Bacterial Genome Assembly Pipeline
# Author  : Keshav Pande
# Purpose : Complete de novo bacterial genome assembly using
#           FastQC, Trim Galore, SPAdes, and QUAST.
#
# Dataset : SRR8389900 (Illumina Paired-End)
#
# Workflow
# --------
# 1. Create project directory
# 2. Download raw sequencing reads
# 3. Organize project folders
# 4. Perform quality check (FastQC)
# 5. Trim reads (Q20 & Q28)
# 6. Perform FastQC after trimming
# 7. Assemble genome using SPAdes
# 8. Assemble genome using SPAdes (k=55)
# 9. Count contigs and scaffolds
# 10. Evaluate assemblies using QUAST
# 11. Compare all assemblies
###############################################################################

set -e

echo "======================================================"
echo "      Bacterial Genome Assembly Pipeline Started"
echo "======================================================"

###############################################################################
# Step 1 : Create Project Directory
###############################################################################

echo "Creating project directory..."

mkdir -p 1_Bacterial_genome_assembly
cd 1_Bacterial_genome_assembly

###############################################################################
# Step 2 : Download Raw Sequencing Reads
#
# Download links are obtained from the NCBI SRA metadata file.
###############################################################################

echo "Downloading sequencing reads..."

cut -f 7 ../filereport_read_run_SRR8389900.tsv > raw_data.sh

chmod +x raw_data.sh

bash raw_data.sh

###############################################################################
# Step 3 : Create Project Structure
###############################################################################

echo "Creating project folders..."

mkdir -p \
1_Raw_data \
2_Fastqc \
3_Trim \
4_Assembly \
5_Quality_stats

###############################################################################
# Step 4 : Organize Raw Reads
###############################################################################

echo "Moving raw FASTQ files..."

mv *.gz 1_Raw_data/

###############################################################################
# Step 5 : Raw Read Quality Assessment
###############################################################################

echo "Running FastQC on raw reads..."

fastqc \
1_Raw_data/*.gz \
-o 2_Fastqc/

###############################################################################
# Step 6 : Install Trim Galore (Skip if already installed)
###############################################################################

echo "Installing Trim Galore..."

conda install -c bioconda trim-galore -y

###############################################################################
# Step 7 : Read Trimming (Quality Score = 20)
###############################################################################

echo "Running Trim Galore (Q20)..."

trim_galore \
-q 20 \
--paired \
--gzip \
1_Raw_data/*.gz \
-o 3_Trim/

###############################################################################
# Step 8 : Read Trimming (Quality Score = 28)
###############################################################################

echo "Running Trim Galore (Q28)..."

mkdir -p 3_Trim/Q_28

trim_galore \
-q 28 \
--paired \
--gzip \
1_Raw_data/*.gz \
-o 3_Trim/Q_28/

###############################################################################
# Step 9 : FastQC After Trimming
###############################################################################

echo "Running FastQC on Q20 trimmed reads..."

fastqc \
3_Trim/SRR8389900_1_val_1.fq.gz \
3_Trim/SRR8389900_2_val_2.fq.gz \
-o 2_Fastqc/

echo "Running FastQC on Q28 trimmed reads..."

fastqc \
3_Trim/Q_28/SRR8389900_1_val_1.fq.gz \
3_Trim/Q_28/SRR8389900_2_val_2.fq.gz \
-o 2_Fastqc/

###############################################################################
# Step 10 : Genome Assembly Using Default SPAdes Parameters
###############################################################################

echo "Running SPAdes (Default)..."

spades \
-1 3_Trim/SRR8389900_1_val_1.fq.gz \
-2 3_Trim/SRR8389900_2_val_2.fq.gz \
--cov-cutoff auto \
-o 4_Assembly

###############################################################################
# Step 11 : Genome Assembly Using Only k-mer = 55
###############################################################################

echo "Running SPAdes (k = 55)..."

spades.py \
-k 55 \
-t 10 \
-m 28 \
--cov-cutoff auto \
-1 3_Trim/SRR8389900_1_val_1.fq.gz \
-2 3_Trim/SRR8389900_2_val_2.fq.gz \
-o 4_Assembly/K_55_New

###############################################################################
# Step 12 : Count Number of Contigs and Scaffolds
###############################################################################

echo "========================================="
echo "Assembly Statistics"
echo "========================================="

echo ""
echo "Default Assembly"

echo -n "Contigs            : "
grep -c ">" 4_Assembly/contigs.fasta

echo -n "Scaffolds          : "
grep -c ">" 4_Assembly/scaffolds.fasta

echo -n "Final Contigs      : "
grep -c ">" 4_Assembly/final_contigs.fasta

echo -n "Final Scaffolds    : "
grep -c ">" 4_Assembly/final_scaffolds.fasta

echo ""

echo "K = 55 Assembly"

echo -n "Contigs            : "
grep -c ">" 4_Assembly/K_55_New/k_55_contigs.fasta

echo -n "Scaffolds          : "
grep -c ">" 4_Assembly/K_55_New/k_55_scaffolds.fasta

echo -n "Final Contigs      : "
grep -c ">" 4_Assembly/K_55_New/K55/final_contigs.fasta

echo -n "Final Scaffolds    : "
grep -c ">" 4_Assembly/K_55_New/K55/scaffolds.fasta

###############################################################################
# Step 13 : Install QUAST
###############################################################################

echo "Installing QUAST..."

conda install -c bioconda quast -y

###############################################################################
# Step 14 : Create QUAST Output Directories
###############################################################################

echo "Creating QUAST directories..."

mkdir -p \
5_Quality_stats/Contigs/Default_Q20 \
5_Quality_stats/Contigs/K_55_New \
5_Quality_stats/Scaffolds/Default_Q20 \
5_Quality_stats/Scaffolds/K_New_55 \
5_Quality_stats/Final_Comparison

###############################################################################
# Step 15 : Evaluate Assemblies Using QUAST
###############################################################################

echo "Running QUAST..."

echo "Evaluating default contigs..."

quast \
4_Assembly/contigs.fasta \
-o 5_Quality_stats/Contigs/Default_Q20

echo "Evaluating default scaffolds..."

quast \
4_Assembly/scaffolds.fasta \
-o 5_Quality_stats/Scaffolds/Default_Q20

echo "Evaluating K55 contigs..."

quast \
4_Assembly/K_55_New/k_55_contigs.fasta \
-o 5_Quality_stats/Contigs/K_55_New

echo "Evaluating K55 scaffolds..."

quast \
4_Assembly/K_55_New/k_55_scaffolds.fasta \
-o 5_Quality_stats/Scaffolds/K_New_55

###############################################################################
# Step 16 : Compare All Assemblies
###############################################################################

echo "Generating final comparison report..."

quast \
4_Assembly/K_55_New/k_55_contigs.fasta \
4_Assembly/K_55_New/k_55_scaffolds.fasta \
4_Assembly/K_55_New/K55/final_contigs.fasta \
4_Assembly/K_55_New/K55/scaffolds.fasta \
-l "K55_Contigs,K55_Scaffolds,Final_Contigs,Final_Scaffolds" \
-o 5_Quality_stats/Final_Comparison

###############################################################################
# Pipeline Completed
###############################################################################

echo ""
echo "======================================================"
echo "        Genome Assembly Pipeline Completed!"
echo "======================================================"

echo ""
echo "Results available in:"
echo "----------------------"

echo "2_Fastqc/"
echo "3_Trim/"
echo "4_Assembly/"
echo "5_Quality_stats/"

echo ""
echo "Final QUAST report:"
echo "5_Quality_stats/Final_Comparison/report.html"

echo ""
echo "Happy Bioinformatics! 🧬"
