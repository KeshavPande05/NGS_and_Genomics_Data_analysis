# 🧬 Hybrid Genome Assembly Using Unicycler

A step-by-step workflow for **de novo bacterial genome assembly** using **Illumina short reads** and **Oxford Nanopore long reads**. The pipeline includes quality assessment, read trimming, genome assembly using multiple strategies, and assembly evaluation with QUAST.

---

## 📖 Overview

This project demonstrates a complete hybrid genome assembly workflow:

- Quality assessment of Illumina and Nanopore reads
- Adapter and quality trimming of Illumina reads
- Short-read genome assembly
- Long-read genome assembly
- Hybrid genome assembly
- Conservative and Bold hybrid assemblies
- Assembly comparison using QUAST

---

## 🚀 Workflow

| Step | Tool | Purpose |
|------|------|---------|
| **1. Project Setup** | Linux | Create a structured directory to organize inputs, outputs, and intermediate files. |
| **2. Raw Read QC** | FastQC | Assess the quality of Illumina reads and detect low-quality bases, GC bias, and adapter contamination. |
| **3. Long Read QC** | NanoPlot | Evaluate Nanopore read quality, read length distribution, and sequencing yield. |
| **4. Read Trimming** | Trim Galore | Remove adapters and low-quality bases to improve assembly accuracy. |
| **5. QC After Trimming** | FastQC | Verify that trimming successfully improved read quality. |
| **6. Short-Read Assembly** | Unicycler | Assemble the genome using only Illumina reads, producing highly accurate but potentially fragmented assemblies. |
| **7. Long-Read Assembly** | Unicycler | Assemble the genome using only Nanopore reads to improve genome continuity across repetitive regions. |
| **8. Hybrid Assembly** | Unicycler | Combine Illumina accuracy with Nanopore long reads to generate a high-quality genome assembly. |
| **9. Assembly Evaluation** | QUAST | Evaluate assembly quality using metrics such as N50, contig count, genome length, and GC content. |
| **10. Conservative Assembly** | Unicycler | Perform hybrid assembly in **conservative mode** to minimize potential misassemblies. |
| **11. Bold Assembly** | Unicycler | Perform hybrid assembly in **bold mode** to maximize assembly contiguity. |
| **12. Final Comparison** | QUAST | Compare all assemblies to identify the best-performing assembly based on standard quality metrics. |

---

## 🛠️ Tools Used

| Tool | Purpose |
|------|----------|
| FastQC | Quality assessment of Illumina reads |
| NanoPlot | Quality assessment of Nanopore reads |
| Trim Galore | Adapter removal and quality trimming |
| Unicycler | Genome assembly |
| QUAST | Assembly quality evaluation |
| Conda | Environment and package management |

---

## 📂 Project Structure

```text
Hybrid_Assembly/
│
├── 1_raw_fastqc/
│   ├── Raw FastQC
│   ├── NanoPlot Report
│   ├── Trim Galore Output
│   └── FastQC After Trimming
│
├── 2_unicycler_shortonly/
├── 3_unicycler_longonly/
├── 4_unicycler_hybrid/
├── 5_unicycler_hybrid_conservative/
├── 6_unicycler_hybrid_bold/
└── Quast_report_after_all_assembly_to_compare/
```

---

## 🔄 Pipeline Summary

```text
Raw Illumina Reads         Nanopore Reads
        │                       │
        ▼                       ▼
      FastQC               NanoPlot
        │                       │
        └──────────┬────────────┘
                   ▼
             Trim Galore
                   ▼
        FastQC (After Trim)
                   ▼
      ┌────────────┼─────────────┐
      ▼            ▼             ▼
 Short Read    Long Read      Hybrid
  Assembly      Assembly      Assembly
      │            │             │
      └────────────┼─────────────┘
                   ▼
     Conservative & Bold Modes
                   ▼
          QUAST Comparison
                   ▼
      Best Genome Assembly
```

---

## 📊 Expected Output

- FastQC reports
- NanoPlot report
- Trimmed Illumina reads
- Genome assemblies (FASTA)
- QUAST reports
- Final comparative assembly report

---

## 💻 Requirements

- Ubuntu/Linux
- Conda
- FastQC
- NanoPlot
- Trim Galore
- Unicycler
- QUAST

---

## 👨‍💻 Author

**Keshav Pande**

M.Sc. Big Data Biology  
Institute of Bioinformatics and Applied Biotechnology (IBAB)

---

## 📜 License

This project is intended for educational and research purposes.
