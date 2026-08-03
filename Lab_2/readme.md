````markdown
# 🧬 Bacterial Genome Assembly Using SPAdes

This project demonstrates a complete **de novo bacterial genome assembly pipeline** using Illumina paired-end sequencing data. The workflow includes raw read quality assessment, read trimming, genome assembly using SPAdes, assembly evaluation with QUAST, and comparison of different assembly strategies.

---

## 📂 Project Structure

```
1_Bacterial_genome_assembly/
│
├── 1_Raw_data/
│   ├── SRR8389900_1.fastq.gz
│   └── SRR8389900_2.fastq.gz
│
├── 2_Fastqc/
│   └── Raw read FastQC reports
│
├── 3_Trim/
│   ├── SRR8389900_1_val_1.fq.gz
│   ├── SRR8389900_2_val_2.fq.gz
│   └── Q_28/
│
├── 4_Assembly/
│   ├── contigs.fasta
│   ├── scaffolds.fasta
│   ├── final_contigs.fasta
│   ├── final_scaffolds.fasta
│   └── K_55_New/
│
└── 5_Quality_stats/
    ├── Contigs/
    ├── Scaffolds/
    └── Final_Comparison/
```

---

# 📋 Workflow

## Step 1: Create Project Directory

```bash
mkdir 1_Bacterial_genome_assembly
cd 1_Bacterial_genome_assembly
```

---

## Step 2: Download Raw Sequencing Reads

Generate and execute the download script from the SRA file report.

```bash
cut -f 7 filereport_read_run_SRR8389900.tsv > raw_data.sh
chmod +x raw_data.sh
bash raw_data.sh
```

---

## Step 3: Create Project Folders

```bash
mkdir \
1_Raw_data \
2_Fastqc \
3_Trim \
4_Assembly \
5_Quality_stats
```

---

## Step 4: Organize Raw Reads

```bash
mv *.gz 1_Raw_data/
```

---

## Step 5: Assess Raw Read Quality

Run FastQC on the raw sequencing reads.

```bash
fastqc 1_Raw_data/*.gz -o 2_Fastqc/
```

---

## Step 6: Install Trim Galore

```bash
conda install -c bioconda trim-galore -y
```

---

## Step 7: Trim Reads (Quality Score = 20)

```bash
trim_galore \
-q 20 \
--gzip \
--paired \
1_Raw_data/*.gz \
-o 3_Trim/
```

---

## Step 8: Trim Reads (Quality Score = 28)

```bash
mkdir -p 3_Trim/Q_28

trim_galore \
-q 28 \
--gzip \
--paired \
1_Raw_data/*.gz \
-o 3_Trim/Q_28/
```

---

## Step 9: Evaluate Trimmed Reads

### Q20

```bash
fastqc \
3_Trim/SRR8389900_1_val_1.fq.gz \
3_Trim/SRR8389900_2_val_2.fq.gz
```

### Q28

```bash
fastqc \
3_Trim/Q_28/SRR8389900_1_val_1.fq.gz \
3_Trim/Q_28/SRR8389900_2_val_2.fq.gz
```

---

## Step 10: Genome Assembly (Default SPAdes)

```bash
spades \
-1 3_Trim/SRR8389900_1_val_1.fq.gz \
-2 3_Trim/SRR8389900_2_val_2.fq.gz \
--cov-cutoff auto \
-o 4_Assembly/
```

---

## Step 11: Genome Assembly (k-mer = 55)

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

## Step 12: Count Contigs and Scaffolds

### Default Assembly

```bash
grep -c ">" 4_Assembly/contigs.fasta
grep -c ">" 4_Assembly/scaffolds.fasta
grep -c ">" 4_Assembly/final_contigs.fasta
grep -c ">" 4_Assembly/final_scaffolds.fasta
```

### k = 55 Assembly

```bash
grep -c ">" 4_Assembly/K_55_New/k_55_contigs.fasta
grep -c ">" 4_Assembly/K_55_New/k_55_scaffolds.fasta

grep -c ">" 4_Assembly/K_55_New/K55/final_contigs.fasta
grep -c ">" 4_Assembly/K_55_New/K55/scaffolds.fasta
```

---

## Step 13: Install QUAST

```bash
conda install -c bioconda quast -y
```

---

## Step 14: Create QUAST Output Directories

```bash
mkdir -p \
5_Quality_stats/Contigs/Default_Q20 \
5_Quality_stats/Contigs/K_55_New \
5_Quality_stats/Scaffolds/Default_Q20 \
5_Quality_stats/Scaffolds/K_New_55 \
5_Quality_stats/Final_Comparison
```

---

## Step 15: Evaluate Assemblies Using QUAST

### Default Contigs

```bash
quast \
4_Assembly/contigs.fasta \
-o 5_Quality_stats/Contigs/Default_Q20
```

### Default Scaffolds

```bash
quast \
4_Assembly/scaffolds.fasta \
-o 5_Quality_stats/Scaffolds/Default_Q20
```

### k = 55 Contigs

```bash
quast \
4_Assembly/K_55_New/k_55_contigs.fasta \
-o 5_Quality_stats/Contigs/K_55_New
```

### k = 55 Scaffolds

```bash
quast \
4_Assembly/K_55_New/k_55_scaffolds.fasta \
-o 5_Quality_stats/Scaffolds/K_New_55
```

---

## Step 16: Final Assembly Comparison

Compare all generated assemblies in a single QUAST report.

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
| FastQC | Quality assessment of sequencing reads |
| Trim Galore | Adapter removal and quality trimming |
| SPAdes | De novo genome assembly |
| QUAST | Assembly quality evaluation |

---

# 📈 Quality Metrics Evaluated

The assemblies were compared using the following metrics:

- Number of Contigs
- Number of Scaffolds
- Total Assembly Length
- Largest Contig
- Largest Scaffold
- N50
- L50
- GC Content
- Number of Ns per 100 kbp

---

# 📝 Results

The QUAST reports generated in the `5_Quality_stats` directory can be used to compare:

- Default SPAdes assembly
- SPAdes assembly with **k = 55**
- Final contigs
- Final scaffolds

The best assembly is selected based on improved assembly continuity (higher N50), fewer contigs/scaffolds, and overall genome completeness.

---

# 🧑‍💻 Author

**Keshav Pande**

- M.Sc. Big Data Biology
- Institute of Bioinformatics and Applied Biotechnology (IBAB)

---
````
