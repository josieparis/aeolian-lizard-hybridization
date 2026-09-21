#!/bin/bash
##############################################################################
## RECONSTRUCTED (2026). Two small steps whose original commands were not kept:
##  (a) genetic sex check — "confirmed by calculating the proportion of reads
##      aligning to the Z/W chromosomes" — from the per-sample samtools idxstats
##      produced in 01_bwa_align.sh;
##  (b) the locus whitelist  outputs/refmap_raffonei/output/Z_W_removed_whitelist.tsv
##      used by every diversity / Ne populations run.  Verified against the
##      original file: it contains 39,220 of 41,230 catalogue loci and exactly
##      zero loci on NC_070620.1 (W) or NC_070621.1 (Z).
## rPodRaf1.pri (GCF_027172205.1) sex chromosomes: Z = NC_070621.1, W = NC_070620.1
## (from genome/sequence_report.jsonl).
##############################################################################
set -euo pipefail
MASTER=${MASTER:-/path/to/capo_grosso_analysis}
refmap=$MASTER/outputs/refmap_raffonei
Z=NC_070621.1
W=NC_070620.1

# (a) fraction of mapped reads on Z and on W per individual (ZW females: W>0, Z ~ half of ZZ males)
printf "sample\tmapped_total\tfrac_Z\tfrac_W\n"
for f in "$refmap"/aligned/*.idxstats; do
    awk -v s="$(basename "$f" .idxstats)" -v Z="$Z" -v W="$W" '
        $1!="*" {tot+=$3} $1==Z {z=$3} $1==W {w=$3}
        END {printf "%s\t%d\t%.5f\t%.5f\n", s, tot, z/tot, w/tot}' "$f"
done > "$refmap/sex_from_ZW_read_fraction.tsv"

# (b) whitelist of catalogue loci NOT on Z or W (locus IDs, one per line)
awk -F'\t' -v Z="$Z" -v W="$W" '!/^#/ && $2!=Z && $2!=W {print $1}' \
    "$refmap/output/populations.sumstats.tsv" | sort -un > "$refmap/output/Z_W_removed_whitelist.tsv"
wc -l "$refmap/output/Z_W_removed_whitelist.tsv"
