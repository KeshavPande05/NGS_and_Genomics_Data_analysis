# Hybrid Genome Assembly — Full Report & Interpretation
**Illumina (paired-end) + Nanopore MinION (2D reads) hybrid bacterial assembly**

---

## 1. Overview of the Workflow

Your `Code_file.sh` script runs a complete short-read + long-read **hybrid genome assembly** pipeline. Here's the pipeline at a glance:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     HYBRID ASSEMBLY PIPELINE                        │
└─────────────────────────────────────────────────────────────────────┘

  RAW READS
  ┌───────────────┐   ┌───────────────┐   ┌────────────────┐
  │ illumina_f.fq  │   │ illumina_r.fq │   │ minion_2d.fq    │
  │ (fwd, 1M reads)│   │(rev, 1M reads)│   │ (long, 12.7k rd)│
  └───────┬────────┘   └───────┬───────┘   └────────┬────────┘
          │                    │                     │
          ▼                    ▼                     ▼
     ┌─────────┐          ┌─────────┐           ┌───────────┐
     │ FastQC  │          │ FastQC  │           │  NanoPlot │
     └────┬────┘          └────┬────┘           └───────────┘
          │                    │
          ▼                    ▼
     ┌───────────────────────────────┐
     │   Trim Galore (Q ≥ 28, PE)    │  → adapter + quality trimming
     └───────────────┬────────────────┘
                      ▼
         ┌─────────────────────────┐
         │  FastQC (post-trim QC)  │
         └────────────┬────────────┘
                       ▼
        ┌──────────────────────────────────────────┐
        │              UNICYCLER                     │
        │  (de Bruijn graph + long-read bridging)    │
        ├──────────────┬──────────────┬─────────────┤
        │ short-only    │ long-only    │  hybrid      │
        │ (Illumina)    │ (MinION)     │ (both)       │
        │               │              │  normal /    │
        │               │              │  conservative│
        │               │              │  / bold      │
        └──────┬────────┴──────┬───────┴──────┬───────┘
               ▼                ▼               ▼
          ┌─────────────────────────────────────────┐
          │            QUAST (assembly QC)            │
          │  contigs · N50/N90 · L50/L90 · GC · auN  │
          └────────────────────┬──────────────────────┘
                                ▼
                     ┌─────────────────────┐
                     │   Best assembly      │
                     │  (hybrid, 2 contigs) │
                     └──────────┬───────────┘
                                ▼
                     ┌─────────────────────┐
                     │   BAKTA annotation    │
                     │  genes, RNAs, CDS...  │
                     └─────────────────────┘
```

**Read the script as five stages:**
1. **Raw QC** — FastQC on all three read files, NanoPlot for the long reads.
2. **Trimming** — Trim Galore removes adapters/low-quality bases from the Illumina pair only (long reads are used as-is; Nanopore reads don't get Illumina-style adapter trimming in this workflow).
3. **Assembly** — Unicycler run five times: short-only, long-only, and hybrid in three bridging modes (normal, conservative, bold).
4. **Assembly QC** — QUAST run on each assembly individually and then combined into one comparison report.
5. **Annotation** — the best assembly (hybrid) is annotated with Bakta.

---

## 2. Tool Guide — What Each Tool Does and Why It's Here

| Tool | Role in this pipeline | Why it's the right choice here |
|---|---|---|
| **FastQC** | Per-read QC report (quality scores, GC%, adapter content, duplication) | Standard first pass for any FASTQ dataset — Illumina and Nanopore both readable |
| **NanoPlot** | Long-read-specific QC (read length vs. quality, N50 of *reads*) | FastQC's per-base plots aren't built for reads that range from 1 kb–27 kb; NanoPlot is purpose-built for Nanopore/PacBio |
| **Trim Galore** | Wraps Cutadapt + FastQC; trims adapters and low-quality bases from paired-end Illumina reads | Illumina short reads benefit from adapter/quality trimming before assembly; long reads generally don't need this style of trimming |
| **Unicycler** | Hybrid bacterial genome assembler — builds a short-read de Bruijn graph (via SPAdes), then uses long reads to resolve repeats and bridge gaps | Purpose-built for exactly this short+long combination in bacterial/small genomes; can run short-only, long-only, or hybrid modes from one tool, which is why it appears three ways in your script |
| **QUAST** | Assembly evaluation — contig counts, N50/N90, L50/L90, GC%, cumulative length plots | The standard reference-free (or reference-based) benchmark for comparing assemblies against each other |
| **Bakta** | Rapid, standardized bacterial genome annotation (genes, RNAs, CDS, CRISPR, origin of replication) | Modern replacement for Prokka; fast, well-maintained annotation databases, produces browsable circular plots |

---

## 3. Read QC Interpretation (FastQC)

### 3.1 Basic statistics

| Metric | illumina_f.fq | illumina_r.fq | minion_2d.fq |
|---|---|---|---|
| Total sequences | 1,000,000 | 1,000,000 | 12,738 |
| Sequence length | 35–251 bp | 35–251 bp | 1,000–27,518 bp |
| %GC | 51% | 51% | 50% |
| Poor-quality reads flagged | 0 | 0 | 0 |

The Illumina pair is a standard high-depth paired-end short-read set (250 bp reads, 1M each — likely simulated/downsampled given the round numbers). The MinION set is a much smaller, much longer-read dataset, as expected for long-read sequencing (reads up to ~27.5 kb).

### 3.2 Per-module pass/warning/fail

| Module | illumina_f.fq | illumina_r.fq | minion_2d.fq |
|---|---|---|---|
| Basic Statistics | PASS | PASS | PASS |
| Per base sequence quality | PASS | PASS | **FAIL** |
| Per tile sequence quality | PASS | PASS | — |
| Per sequence quality scores | PASS | PASS | **FAIL** |
| Per base sequence content | WARNING | WARNING | **FAIL** |
| Per sequence GC content | WARNING | **FAIL** | WARNING |
| Per base N content | PASS | PASS | PASS |
| Sequence Length Distribution | WARNING | WARNING | WARNING |
| Sequence Duplication Levels | PASS | PASS | PASS |
| Overrepresented sequences | PASS | PASS | PASS |
| Adapter Content | PASS | PASS | PASS |

**How to read this:**
- The **Illumina reads are high quality**: no adapter contamination, no over-representation, no poor-quality-read flags. The WARNING/FAIL on "GC content" and "sequence content" are extremely common in bacterial genomic libraries and don't usually block assembly — they trip because FastQC compares against a generic (often human-derived) "normal distribution" model, which real bacterial genomes with skewed GC or fragmentation biases at read starts routinely fail.
- The **MinION reads failing "per base quality" and "per sequence quality scores" is completely expected and not a red flag** — Nanopore raw reads have a fundamentally lower and more variable per-base accuracy than Illumina (historically ~85–97% depending on chemistry/basecaller), so FastQC's Illumina-tuned quality thresholds will almost always fail Nanopore data. This is *why* NanoPlot (not FastQC) is the appropriate QC tool for long reads — it evaluates them on length/N50/read-quality distributions appropriate to the technology, rather than penalizing them for not looking like Illumina reads.
- **Sequence Length Distribution WARNING** across all three is also expected: real sequencing (as opposed to simulated fixed-length reads) naturally produces a distribution of lengths, and FastQC flags any distribution as non-uniform.

**Bottom line on QC:** nothing here should stop you from proceeding to assembly. The Illumina reads are clean; the Nanopore "failures" are a technology characteristic, not a data-quality problem.

### 3.3 Effect of trimming (Trim Galore, Q ≥ 28)

| Metric | Raw (illumina_f.fq) | Trimmed (illumina_f_val_1.fq) | Interpretation |
|---|---|---|---|
| Total sequences | 1,000,000 | 969,077 | ~3.1% of reads removed/discarded |
| Sequence length | 35–251 bp | 20–251 bp | Short adapter/low-quality ends removed |
| GC content | 51% | 51% | No GC bias introduced by trimming |
| Mean quality | ~Q34–38 | ~Q34–39 | Slight improvement, especially at read ends |

Trimming had a light-touch, expected effect: it removed a small fraction of reads/bases without changing the overall base composition. This is the sign of a trimming step that is doing its job cleanly rather than being either too aggressive (losing lots of data) or ineffective (leaving adapters behind).

---

## 4. Assembly Comparison (QUAST)

| Metric | Short-only | Long-only | Hybrid (normal) | Hybrid (conservative) | Hybrid (bold) |
|---|---|---|---|---|---|
| # contigs | 67 | 31 | 2 | 2 | 2 |
| Largest contig (bp) | 434,251 | 428,336 | 4,576,263 | 4,576,263 | 4,576,263 |
| Total length (bp) | 4,482,053 | 4,465,996 | 4,581,649 | 4,581,649 | 4,581,649 |
| GC (%) | 50.85 | 51.04 | 50.93 | 50.93 | 50.93 |
| N50 | 140,793 | 227,592 | 4,576,263 | 4,576,263 | 4,576,263 |
| N90 | 58,815 | 68,504 | 4,576,263 | 4,576,263 | 4,576,263 |
| L50 | 11 | 7 | 1 | 1 | 1 |
| L90 | 27 | 20 | 1 | 1 | 1 |
| N's per 100 kbp | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |

### What these metrics mean
- **# contigs** — how many separate DNA fragments the assembler produced. Fewer = more contiguous, closer to a finished genome.
- **N50 / N90** — the contig length at which 50% (or 90%) of the total assembled genome is contained in contigs of that size or larger. Higher N50 means the genome is captured in fewer, larger pieces.
- **L50 / L90** — the *number* of contigs needed to reach 50%/90% of the genome. Lower is better (fewer pieces needed).
- **auN** — an "area under the Nx curve" summary statistic; like a smoother, more robust version of N50.

### Interpretation
- **Short-read-only assembly** is the most fragmented: 67 contigs, N50 of only ~141 kb, needing 11 contigs to cover half the genome. This is the classic limitation of short-read (Illumina) assembly — repeats longer than the read/insert size can't be resolved, so the assembly graph breaks into many pieces.
- **Long-read-only assembly** does noticeably better (31 contigs, N50 ~228 kb) because long reads can span repeats, but base-level accuracy of raw Nanopore reads limits fine-scale correctness, and 12.7k reads alone is comparatively lower depth than the paired-end set.
- **All three hybrid modes produce virtually the same, near-perfect result**: **2 contigs, total genome length 4,581,649 bp, N50 = N90 = largest contig (4,576,263 bp), L50 = L90 = 1.** This means a single contig covers effectively the entire genome — the hallmark of a complete or near-complete circular bacterial chromosome assembly, with a second, smaller contig (likely a plasmid, ~5.4 kb by subtraction: 4,581,649 − 4,576,263).
- The fact that **normal, conservative, and bold hybrid modes converge on identical statistics** tells you the assembly graph was clean and unambiguous enough that Unicycler's bridging aggressiveness setting didn't matter — a good sign of assembly reliability (it's not an artifact of one particular aggressive setting forcing a result).

**Ranking:** Hybrid (any mode) > Long-read-only > Short-read-only, exactly as expected — combining short-read base accuracy with long-read repeat-spanning gives the best of both technologies.

---

## 5. Genome Annotation (Bakta)

Run on the hybrid assembly (2 contigs, 4,581,649 bp):

| Metric | Value |
|---|---|
| Genome size | 4,581,649 bp (~4.58 Mb) |
| Contigs | 2 |
| N50 / N90 | 4,576,263 bp |
| GC content | 50.9% |
| Coding ratio | 89.4% |
| N-ratio (ambiguous bases) | 0 |

| Feature | Count | What it is |
|---|---|---|
| CDS | 4,207 | Protein-coding genes |
| tRNA | 86 | Transfer RNA genes |
| rRNA | 22 | Ribosomal RNA genes (typically in operons — 22 suggests several rRNA operon copies, common in bacteria) |
| tmRNA | 1 | Transfer-messenger RNA (rescues stalled ribosomes) |
| ncRNA | 215 | Non-coding RNA genes |
| ncRNA regions | 75 | Regulatory non-coding RNA elements |
| sORF | 73 | Small open reading frames |
| CRISPR | 3 | CRISPR arrays (adaptive immune system against phage/plasmids) |
| oriC | 1 | Single chromosomal origin of replication |
| oriV / oriT / gaps | 0 | No plasmid replication/transfer origins detected, no assembly gaps |

**Interpretation:** These numbers (~4.2k CDS, ~90% coding density, single oriC, 0 gaps) are entirely consistent with a **complete, high-quality bacterial chromosome assembly**. An 89.4% coding ratio and >4,000 CDS in a ~4.6 Mb genome is typical of many free-living bacteria (e.g., in the range of organisms like *E. coli*, *Pseudomonas*, or similar-sized genomes). The presence of exactly one oriC and zero gaps strongly supports that the large contig represents a fully circularized, finished chromosome rather than a partial draft.

---

## 6. Overall Conclusion

1. **Read quality was good enough to proceed without concern.** Illumina reads passed nearly all QC modules; MinION long-read "failures" in FastQC reflect the technology's known lower raw per-base accuracy, not a data problem — this is exactly why long reads are QC'd with NanoPlot instead.
2. **Trimming (Trim Galore, Q≥28) had the expected light, positive effect** on the Illumina reads — small reduction in read count/length, slight quality improvement, no compositional bias introduced.
3. **Hybrid assembly (Unicycler, any bridging mode) dramatically outperformed either read type alone** — going from 67 fragmented contigs (short-read-only) down to 2 contigs representing a complete chromosome + likely plasmid.
4. **Bakta annotation confirms assembly completeness**: single origin of replication, zero gaps, coding density and gene counts consistent with a finished bacterial genome.

This is a textbook example of why hybrid assembly is the standard approach for bacterial genomics when both short and long reads are available: short reads correct base-level errors, long reads resolve repeats that short reads alone cannot span.

---

## 7. Suggestions / Next Steps

- **Confirm circularity** of the large contig — Unicycler reports this in its assembly graph (`assembly.gfa`); Bandage (a GUI tool) can visualize whether the contig closes into a loop.
- **Classify the smaller (~5.4 kb) contig** — check GC%, and BLAST it or look for plasmid replication genes to confirm it's a plasmid rather than an unresolved chromosomal fragment.
- **Species/strain identification** — since Bakta was run with `Organism: N.A.`, running a quick tool like `Kraken2` or `GTDB-Tk` (or just BLASTing a few marker genes) would let you label the organism, which improves the accuracy of downstream Bakta annotation (it uses organism-aware gene-calling models when species is specified).
- **Polish the assembly** (optional) — tools like `Pilon` or a short-read polishing round can further correct any residual long-read-derived base errors in the final hybrid assembly.
