#!/bin/bash
##############################################################################
## Genotype-level filtering of the population-structure SNP set
## (populations_structure/round_2/populations.snps.vcf: all 134 individuals
## genotyped at the pure-species whitelist, one SNP per locus, 2,785 sites)
## -> 2,623 variant sites used for PCA / ADMIXTURE / FST.
##
## Provenance: the vcftools command (step 2) is copied verbatim from the
## author's analysis lab notebook (entry of 16 June 2022, the fileDate stamped
## in the output VCF), so its parameters are exact; the notebook also records
## the result, "After filtering, kept 2623 out of a possible 2785 Sites".
## The STAR Methods quote the same filters ("--minDP 3 and --max-meanDP 80",
## biallelic sites only, genotype quality 30).  Steps 3-4 (chromosome
## renaming and PLINK conversion) follow the notebook but are RECONSTRUCTED
## where noted.  Archived final VCF: 134 individuals, 2,623 sites, 15 header
## lines, CHROM = "1" throughout (Dropbox pop_structure/fst/pop_structure_filtered.vcf).
##############################################################################
set -euo pipefail
MASTER=${MASTER:-/path/to/capo_grosso_analysis}
cd "$MASTER/outputs/denovo_master/populations_structure/round_2"
mkdir -p ../round_3

# 1. per-individual missingness / depth and per-site depth tables, plotted by
#    plot_depth_missingness.R; the minDP and max-meanDP thresholds below were
#    chosen from these plots.
vcftools --vcf populations.snps.vcf --missing-indv    --out populations.snps.vcf
vcftools --vcf populations.snps.vcf --depth           --out populations.snps.vcf
vcftools --vcf populations.snps.vcf --site-mean-depth --out populations.snps.vcf

# 2. filtering (verbatim from the notebook): genotypes with depth < 3 or
#    GQ < 30 are set to missing; a site is kept only if it is biallelic, has a
#    mean depth <= 80 and is called in at least 50 % of individuals.
vcftools --vcf populations.snps.vcf --min-alleles 2 --max-alleles 2 --minGQ 30 --minDP 3 --max-meanDP 80 \
         --recode --recode-INFO-all --out ../round_3/filtered --max-missing 0.5
# -> ../round_3/filtered.recode.vcf   (2,623 of 2,785 sites)

# 3. rename every CHROM value (the de novo Stacks locus ID) to "1" so that
#    PLINK 1.9 accepts the file without --allow-extra-chr.  The notebook did
#    this with `sed '1,15d' | sed -r 's/^[0-9]+/1/'` on the 15-line header and
#    pasted the header back; the awk below is the equivalent that does not
#    depend on the header length.
cd ../round_3
awk 'BEGIN{OFS="\t"} /^#/ {print; next} {$1="1"; print}' filtered.recode.vcf > pop_structure_filtered.vcf

# 4. PED/MAP for PLINK (RECONSTRUCTED).  The notebook records
#    `plink --vcf pop_structure_filtered.vcf --out pop_structure_filtered`, which
#    in PLINK 1.9 writes a binary fileset; the next step on the server
#    (round_3/plink.log: `plink --file pop_structure_filtered --make-bed`, see
#    02_plink_pca.sh) reads PED/MAP, so --recode is added here.
plink --vcf pop_structure_filtered.vcf --recode --out pop_structure_filtered
