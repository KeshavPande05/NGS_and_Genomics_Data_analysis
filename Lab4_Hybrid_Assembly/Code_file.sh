# Create a directory
mkdir 20260806_Hydbrid_Assembly

# Change Directory 
cd 20260806_Hydbrid_Assembly/

# Create sub-directory
mkdir 1_raw_fastqc 2_uniycler_shortonly 3_unicycler_longonly 4_unicycler_hydbrid 5_unicycler_hybrid_conservative 6_unicycler_hybridbold

# Change directory
cd 1_raw_fastqc/

# Run fastqc on all 3 files illuminaf.fq , illunina_r.fq and minion.fq
fastqc *.fq

# Run Nanoplot for minion.f     
# It didnt work for me so we shared file from classmate an HTML given in the output folder
conda create -n nanoplot_env python=3.11 -y
conda activate nanoplot_env
conda install -c conda-forge -c bioconda nanoplot

NanoPlot --fastq minion_2d.fq --outdir nanoplot_qc_report
conda deactivate


#Trim_galore(phred_score = 28) 
trim_galore -q 28 --paired illumina_f.fq illumina_r.fq -o Trim_galore_after_fastqc


# output file for aftertrim fastqc
mkdir fastqc_after_trim

# After Trim fastqc 
fastqc illumina_f_val_1.fq illumina_r_val_2.fq -o fastqc_after_trim


#Compare the previous and After trim html How it improved 


# Next step is Unicycler 
# short read only assembly 
# we are currently in Trim_folder_under_1_raw_data
unicycler -1 illumina_f_val_1.fq -2 illumina_r_val_2.fq -o ../../2_uniycler_shortonly/
cd ../../2_unicycler_shortonly

# quast report for short read 
quast assembly.fasta -o quast_report_after_unicycler_short


# 1_raw_data directory to run Long read on minion.fq(check directory)
cd ..
# for long read
unicycler -l minion_2d.fq -o ../3_unicycler_longonly/
quast assembly.fasta -o quast_after_unicycler_long_read


#Combined  
unicycler -1 illumina_f_val_1.fq -2 illumina_r_val_2.fq -l ../minion_2d.fq -o ../../4_unicycler_hydbrid/
quast assembly.fasta -o Quast_after_Hybrid


# Combined report of all assembly 
quast.py \
  2_uniycler_shortonly/assembly.fasta \
  3_unicycler_longonly/assembly.fasta \
  4_unicycler_hydbrid/assembly.fasta \
  -o Quast_report_after_all_assembly_to_compare

#For Mode conservative
unicycler \
  -1 illumina_f_val_1.fq \
  -2 illumina_r_val_2.fq \
  -l ../minion_2d.fq \
  -o ../../5_unicycler_hybrid_conservative/ \
  --mode conservative \
  -t 8

# For Bold
unicycler   -1 illumina_f_val_1.fq   -2 illumina_r_val_2.fq   -l ../minion_2d.fq   -o ../../6_unicycler_hybrid_bold/   --mode bold   -t 11

#Final Quast
quast assembly.fasta  ../3_unicycler_longonly/assembly.fasta  ../4_unicycler_hydbrid/assembly.fasta ../5_unicycler_hybrid_conservative/assembly.fasta  ../6_unicycler_hybrid_bold/assembly.fasta  -o ../Quast_report_after_all_assembly_to_compare/

