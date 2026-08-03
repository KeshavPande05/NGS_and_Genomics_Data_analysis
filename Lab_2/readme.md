# 🧬 Bacterial Genome Assembly Using SPAdes

![Platform](https://img.shields.io/badge/Platform-Linux-blue)
![Language](https://img.shields.io/badge/Shell-Bash-green)
![Assembler](https://img.shields.io/badge/SPAdes-v3.15+-orange)
![Quality](https://img.shields.io/badge/QUAST-Assembly_Evaluation-red)

A complete **de novo bacterial genome assembly pipeline** using Illumina paired-end sequencing data. The workflow performs quality assessment, read trimming, genome assembly, assembly evaluation, and comparison of different assembly strategies.

---

## 📖 Overview

This project demonstrates a typical bacterial genome assembly workflow using:

- **FastQC** for quality assessment
- **Trim Galore** for adapter and quality trimming
- **SPAdes** for genome assembly
- **QUAST** for assembly quality evaluation

The pipeline compares:

- Default SPAdes assembly
- SPAdes assembly using **k = 55**
- Contigs vs Scaffolds
- Final assembly quality

---

## 📂 Project Structure

```text
1_Bacterial_genome_assembly/
│
├── 1_Raw_data/
├── 2_Fastqc/
├── 3_Trim/
│   └── Q_28/
├── 4_Assembly/
│   └── K_55_New/
└── 5_Quality_stats/
    ├── Contigs/
    ├── Scaffolds/
    └── Final_Comparison/
```

---

# 🧰 Prerequisites

Install the required software before running the pipeline.

| Software | Version |
|----------|---------|
| Conda | Latest |
| FastQC | Latest |
| Trim Galore | Latest |
| SPAdes | 3.15+ |
| QUAST | Latest |

Install using Bioconda:

```bash
conda install -c bioconda fastqc trim-galore spades quast -y
```

---

# 📥 Dataset

- **NCBI SRA Run:** `SRR8389900`
- Sequencing Platform: **Illumina Paired-End**

The download script is automatically generated from the SRA metadata file.

---

# 🔬 Workflow

```text
Raw Reads
     │
     ▼
 FastQC
     │
     ▼
 Trim Galore
     │
     ▼
 FastQC
     │
     ▼
 SPAdes Assembly
     │
     ├──────────────┐
     ▼              ▼
 Default        K=55 Assembly
     │              │
     └──────┬───────┘
            ▼
         QUAST
            ▼
     Assembly Comparison
```

---

# 🚀 Pipeline

## 1. Create Project Directory

```bash
mkdir 1_Bacterial_genome_assembly
cd 1_Bacterial_genome_assembly
```

---

## 2. Download Raw Reads

```bash
cut -f 7 filereport_read_run_SRR8389900.tsv > raw_data.sh
chmod +x raw_data.sh
bash raw_data.sh
```

---

## 3. Create Project Structure

```bash
mkdir \
1_Raw_data \
2_Fastqc \
3_Trim \
4_Assembly \
5_Quality_stats
```

---

## 4. Organize Raw Reads

```bash
mv *.gz 1_Raw_data/
```

---

## 5. Quality Check

```bash
fastqc 1_Raw_data/*.gz -o 2_Fastqc/
```

---

## 6. Trim Reads (Q20)

```bash
trim_galore \
-q 20 \
--paired \
--gzip \
1_Raw_data/*.gz \
-o 3_Trim/
```

---

## 7. Trim Reads (Q28)

```bash
mkdir -p 3_Trim/Q_28

trim_galore \
-q 28 \
--paired \
--gzip \
1_Raw_data/*.gz \
-o 3_Trim/Q_28/
```

---

## 8. FastQC After Trimming

```bash
fastqc 3_Trim/*.fq.gz
fastqc 3_Trim/Q_28/*.fq.gz
```

---

## 9. Genome Assembly (Default)

```bash
spades \
-1 3_Trim/SRR8389900_1_val_1.fq.gz \
-2 3_Trim/SRR8389900_2_val_2.fq.gz \
--cov-cutoff auto \
-o 4_Assembly
```

---

## 10. Genome Assembly (k = 55)

```bash
spades.py \
-k 55 \
-t 10 \
-m 28 \
--cov-cutoff auto \
-1 3_Trim/SRR8389900_1_val_1.fq.gz \
-2 3_Trim/SRR8389900_2_val_2.fq.gz \
-o 4_Assembly/K_55_New
```

---

## 11. Count Contigs & Scaffolds

```bash
grep -c ">" 4_Assembly/*.fasta
grep -c ">" 4_Assembly/K_55_New/*.fasta
```

---

## 12. Assembly Quality Assessment

```bash
quast 4_Assembly/contigs.fasta -o 5_Quality_stats/Contigs/Default_Q20

quast 4_Assembly/scaffolds.fasta -o 5_Quality_stats/Scaffolds/Default_Q20

quast 4_Assembly/K_55_New/k_55_contigs.fasta \
-o 5_Quality_stats/Contigs/K_55_New

quast 4_Assembly/K_55_New/k_55_scaffolds.fasta \
-o 5_Quality_stats/Scaffolds/K_New_55
```

---

## 13. Final Assembly Comparison

```bash
quast \
4_Assembly/K_55_New/k_55_contigs.fasta \
4_Assembly/K_55_New/k_55_scaffolds.fasta \
4_Assembly/K_55_New/K55/final_contigs.fasta \
4_Assembly/K_55_New/K55/scaffolds.fasta \
-l "K55_Contigs,K55_Scaffolds,Final_Contigs,Final_Scaffolds" \
-o 5_Quality_stats/Final_Comparison
```

---

# 📊 Tools Used

| Tool | Purpose |
|------|---------|
| FastQC | Read quality assessment |
| Trim Galore | Adapter removal and trimming |
| SPAdes | De novo genome assembly |
| QUAST | Assembly quality evaluation |

---

# 📈 Assembly Metrics

The assemblies are evaluated using:

- Total Assembly Length
- Number of Contigs
- Number of Scaffolds
- Largest Contig
- Largest Scaffold
- N50
- L50
- GC Content
- Ns per 100 kbp

---

# 📁 Output

```
5_Quality_stats/
│
├── Contigs/
├── Scaffolds/
└── Final_Comparison/
```

The `Final_Comparison` directory contains a comprehensive QUAST report comparing all generated assemblies.

---

# 📊 Interpretation of QUAST Metrics

QUAST (Quality Assessment Tool for Genome Assemblies) provides several statistics to evaluate the quality of genome assemblies. The following guide explains the meaning of each metric and how to interpret it.

| Metric | Description | Interpretation |
|--------|-------------|----------------|
| **# contigs (>= 0 bp)** | Total number of contigs produced by the assembler. | Lower values generally indicate a more contiguous and less fragmented assembly. |
| **# contigs (>= 1000 bp)** | Number of contigs that are at least 1 kb long. | A higher number indicates more long contigs, but fewer total contigs is generally preferred. |
| **# contigs (>= 5000 bp)** | Number of contigs longer than 5 kb. | Larger values indicate that more of the genome has been assembled into long continuous sequences. |
| **# contigs (>= 10000 bp)** | Number of contigs longer than 10 kb. | More large contigs generally reflect better assembly continuity. |
| **# contigs (>= 25000 bp)** | Number of contigs longer than 25 kb. | Indicates the presence of very large assembled genomic regions. |
| **# contigs (>= 50000 bp)** | Number of contigs longer than 50 kb. | A larger number suggests higher assembly quality with long uninterrupted sequences. |
| **Total length (>= 0 bp)** | Combined length of all contigs. | Should be close to the expected genome size. Large deviations may indicate missing or duplicated regions. |
| **Total length (>= 1000 bp)** | Total length considering only contigs ≥1 kb. | Useful for excluding very small contigs that may represent assembly artifacts. |
| **Total length (>= 5000 bp)** | Total assembly length using contigs ≥5 kb. | Higher values indicate that most of the genome is represented by long contigs. |
| **Total length (>= 10000 bp)** | Total length using contigs ≥10 kb. | Indicates the contribution of long contigs to the genome assembly. |
| **Total length (>= 25000 bp)** | Total length using contigs ≥25 kb. | Reflects the proportion of the genome assembled into very large fragments. |
| **Total length (>= 50000 bp)** | Total length using contigs ≥50 kb. | Larger values indicate highly contiguous assemblies. |
| **# contigs** | Number of contigs after QUAST filtering (typically ≥500 bp). | Lower values indicate less fragmented assemblies. |
| **Largest contig** | Length of the longest contig in the assembly. | Larger values are desirable because they indicate long continuous assembled regions. |
| **Total length** | Total size of the assembled genome after filtering. | Should closely match the expected genome size of the organism. |
| **GC (%)** | Percentage of guanine (G) and cytosine (C) bases in the assembly. | Should be consistent with the known GC content of the organism. Significant deviations may indicate contamination or assembly errors. |
| **N50** | The contig length such that 50% of the total assembly length is contained in contigs of this size or larger. | Higher N50 values indicate better assembly continuity and are one of the most widely used assembly quality metrics. |
| **N90** | Similar to N50, but covers 90% of the assembly. | Higher N90 values indicate that even smaller contigs remain relatively long, reflecting improved continuity. |
| **auN** | Area under the Nx curve, summarizing assembly continuity across all Nx values. | Larger auN values indicate better overall assembly quality and continuity. It is considered more informative than N50 alone. |
| **L50** | Minimum number of largest contigs required to cover 50% of the assembly. | Lower L50 values are better because fewer contigs are needed to represent half of the genome. |
| **L90** | Minimum number of largest contigs required to cover 90% of the assembly. | Lower values indicate greater assembly continuity. |
| **# N's per 100 kbp** | Number of ambiguous bases ('N') per 100,000 bp. Ns represent gaps introduced during scaffolding. | Lower values indicate fewer gaps. Contig assemblies usually have 0 Ns, while scaffold assemblies may contain some Ns. Excessive Ns may indicate poor scaffolding. |

---

## 📌 General Guidelines for Assessing Assembly Quality

A high-quality genome assembly typically has the following characteristics:

- ✅ **Fewer contigs** (less fragmentation)
- ✅ **Larger longest contig**
- ✅ **Higher N50 and N90 values**
- ✅ **Higher auN value**
- ✅ **Lower L50 and L90 values**
- ✅ **Total assembly length close to the expected genome size**
- ✅ **GC content matching the organism's known GC percentage**
- ✅ **Fewer ambiguous bases (Ns), especially in scaffold assemblies**

No single metric determines assembly quality. Instead, multiple metrics should be evaluated together to obtain a comprehensive assessment of the genome assembly.

# 🎯 Learning Objectives

- Perform quality assessment of Illumina sequencing reads.
- Trim adapters and low-quality bases.
- Assemble bacterial genomes using SPAdes.
- Compare different assembly strategies.
- Evaluate assembly quality using QUAST.
- Interpret assembly metrics such as N50, L50, and genome completeness.

---

# 👨‍💻 Author

**Keshav Pande**

**M.Sc. Big Data Biology**  
Institute of Bioinformatics and Applied Biotechnology (IBAB)

---

## ⭐ If you found this repository useful, consider giving it a star!
