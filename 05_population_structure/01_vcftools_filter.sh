#!/bin/bash
##############################################################################
## RECONSTRUCTED (2026).  Genotype-level filtering of the population-structure
## SNP set (populations_structure/round_2/populations.snps.vcf, one SNP per
## locus) -> 2,623 variant sites used for PCA / ADMIXTURE / FST.
## Parameters from the STAR Methods: vcftools v0.1.17, "--minDP 3 and
## --max-meanDP 80" with "genotype quality of 30".
## Evidence for the output names: PLINK logs on the server show
##   plink --file pop_structure_filtered --make-bed   (round_3/plink.log)
## i.e. a PED/MAP pair named pop_structure_filtered, and the QC plot script
## reads populations.snps.vcf.{imiss,idepth,ldepth.mean}.
##############################################################################
set -euo pipefail
MASTER=${MASTER:-/path/to/capo_grosso_analysis}
cd "$MASTER/outputs/denovo_master/populations_structure"
mkdir -p round_3 && cd round_3
vcf=../round_2/populations.snps.vcf

# per-individual / per-site QC tables (plotted by plot_depth_missingness.R)
vcftools --vcf $vcf --missing-indv     --out populations.snps.vcf
vcftools --vcf $vcf --depth            --out populations.snps.vcf
vcftools --vcf $vcf --site-mean-depth  --out populations.snps.vcf

# genotype filters
vcftools --vcf $vcf --minDP 3 --max-meanDP 80 --minGQ 30 \
         --recode --recode-INFO-all --out pop_structure_filtered
# PED/MAP for PLINK
vcftools --vcf pop_structure_filtered.recode.vcf --plink --out pop_structure_filtered
