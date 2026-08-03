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
