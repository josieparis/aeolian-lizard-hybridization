#!/bin/bash
##############################################################################
## RECONSTRUCTED (2026) from the @PG header lines of the BAMs in
## outputs/refmap_raffonei/aligned/, which record the exact commands run:
##   @PG ID:bwa       VN:0.7.17-r1188  CL:bwa mem -t 12 -M <genome.fna> <S>.1.fq.gz <S>.2.fq.gz
##   @PG ID:samtools  VN:1.14          CL:samtools view -bS <S>.sam
##   @PG ID:samtools.1 VN:1.14         CL:samtools sort -o <S>.bam -
## Reference: Podarcis raffonei rPodRaf1.pri, NCBI RefSeq GCF_027172205.1
## (downloaded with NCBI Datasets, bwa index built on the .fna).
## Secondary/supplementary alignments are NOT removed here; gstacks discards
## them itself (see gstacks.log: "skipped some suboptimal (secondary/
## supplementary) alignment records"), which is what the paper describes.
## Per-sample flagstat + idxstats were also produced (used for Z/W sexing).
##############################################################################
set -euo pipefail
MASTER=${MASTER:-/path/to/capo_grosso_analysis}
genome=$MASTER/outputs/refmap_raffonei/genome/GCF_027172205.1_rPodRaf1.pri_genomic.fna
samples_dir=$MASTER/outputs/samples
aligned=$MASTER/outputs/refmap_raffonei/aligned
popmap=$MASTER/outputs/refmap_raffonei/popmaps/all_inds_refmap_popmap
mkdir -p "$aligned"

[ -f "$genome.bwt" ] || bwa index "$genome"

cut -f1 "$popmap" | while read -r s; do
    bwa mem -t 12 -M "$genome" "$samples_dir/$s.1.fq.gz" "$samples_dir/$s.2.fq.gz" > "$aligned/$s.sam"
    samtools view -bS "$aligned/$s.sam" | samtools sort -o "$aligned/$s.bam" -
    samtools index "$aligned/$s.bam"
    samtools flagstat "$aligned/$s.bam" > "$aligned/$s.bam.flagstat"
    samtools idxstats "$aligned/$s.bam" > "$aligned/$s.idxstats"
    rm "$aligned/$s.sam"
done
