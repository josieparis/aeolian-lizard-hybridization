#!/bin/bash
##############################################################################
## RECONSTRUCTED (2026) — the original command was run interactively and is
## not preserved. Parameters follow the STAR Methods of Paris et al. 2024:
## "Reads shorter than 125 bp in length were removed using fastp v0.23.2".
## Evidence for lane-level filtering before demultiplexing: the process_radtags
## scripts read  data/clean_reads/<lane>_R{1,2}.clean.fastq.gz  and FastQC
## reports of those .clean files exist (QC/clean/*.clean_fastqc.html).
##############################################################################
set -euo pipefail
MASTER=${MASTER:-/path/to/capo_grosso_analysis}
raw_dir=$MASTER/data/raw_reads          # 7 HiSeq 2500 lanes, 2 x 125 bp
clean_dir=$MASTER/data/clean_reads
mkdir -p "$clean_dir"

for r1 in "$raw_dir"/*_R1.fastq.gz; do
    lane=$(basename "$r1" _R1.fastq.gz)          # e.g. 150217_SND405_A_L007_GWM-619
    r2=$raw_dir/${lane}_R2.fastq.gz
    fastp \
        -i "$r1" -I "$r2" \
        -o "$clean_dir/${lane}_R1.clean.fastq.gz" \
        -O "$clean_dir/${lane}_R2.clean.fastq.gz" \
        --length_required 125 \
        --disable_adapter_trimming --disable_quality_filtering --disable_trim_poly_g \
        --thread 8 \
        --html "$clean_dir/${lane}.fastp.html" --json "$clean_dir/${lane}.fastp.json"
done
