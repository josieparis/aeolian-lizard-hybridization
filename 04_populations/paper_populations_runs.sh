#!/bin/bash
##############################################################################
## Every Stacks `populations` run that feeds an analysis reported in
## Paris et al. 2024 (iScience 27:111097), in pipeline order.  Each command is
## copied from line 2 of the corresponding populations.log on the analysis
## server (see all_stacks_commands.tsv for the complete set of 107 logs,
## including exploratory runs not used in the paper).  Only the paths have
## been generalised.  Whitelists referenced here are archived in
## ../data/whitelists/ ; popmaps in ../data/popmaps_denovo/ and ../data/popmaps_refmap/.
##
## Stacks 2.60 for the de novo catalogue (populations run 2022-05 .. 2022-08,
## the GenotypePlot run 2023-12); Stacks 2.64 for the reference-mapped
## catalogue (2023-08).  This file documents; it is not meant to be executed
## end-to-end (whitelist-building steps between runs were done by hand).
##############################################################################
set -euo pipefail
MASTER=${MASTER:-/path/to/capo_grosso_analysis}
POP=$MASTER/data/popmaps
DN=$MASTER/outputs/denovo_master           # de novo catalogue (M2 n2, 134 inds)
RM=$MASTER/outputs/refmap_raffonei         # reference-mapped catalogue (rPodRaf1.pri)

########################## A. de novo catalogue ##############################
cd "$DN"

## A1. population-structure SNP set -------------------------------------------
# round 1: loci present in BOTH species (-p 2), in >=50 % of individuals of each
# (-r 0.5), minor allele count >=2, one SNP per locus. Pure-phenotype individuals
# only (popmap no_intermediates).  The locus IDs of this output became
# whitelist_pure_sic_raf.tsv  (data/whitelists/structure_whitelist_pure_sic_raf.tsv).
populations -P . -M $POP/no_intermediates -r 0.5 -p 2 --min-mac 2 --write-single-snp \
            --out populations_structure/round_1 --vcf -t 24
cut -f1 populations_structure/round_1/populations.sumstats.tsv | grep -v '^#' | sort -un \
    > populations_structure/round_1/whitelist_pure_sic_raf.tsv

# round 2: genotype ALL 134 individuals (incl. intermediates) at those loci.
# -> populations.snps.vcf, then vcftools filtering (05_population_structure/01_vcftools_filter.sh)
#    -> 2,623 linkage-pruned SNPs used for PCA, ADMIXTURE, FST, introgress input.
populations -P . -M $POP/samples_simple -W populations_structure/round_1/whitelist_pure_sic_raf.tsv \
            --out populations_structure/round_2 --write-single-snp --vcf -t 24

## A2. haplotype set for fineRADstructure (17,254 variant sites) -------------
populations -P . -M $POP/no_intermediates -r 0.5 -p 2 --min-mac 2 \
            --out populations_structure/fineRAD/round_1 --vcf -t 24
populations -P . -M $POP/samples_simple_fineRAD -W populations_structure/round_1/whitelist_pure_sic_raf.tsv \
            --out populations_structure/fineRAD/round_2 --fineRAD -t 24
# -> populations_structure/fineRAD/round_2/populations.haps.radpainter
#    (05_population_structure/04_fineradstructure.sh)

## A3. within-species subsets on the same whitelist (ADMIXTURE by year / site) -
populations -P . -M $POP/raffonei_2015_2017 -W populations_structure/round_2/whitelist.tsv \
            -O populations_structure/round_4_raffonei_CG --vcf --plink
populations -P . -M $POP/siculus_2015_2017  -W populations_structure/round_2/whitelist.tsv \
            -O populations_structure/round_5_siculus_vulc --vcf --plink
populations -P . -M $POP/all_siculus        -W populations_structure/round_2/whitelist.tsv \
            -O populations_structure/round_6_milazzo_vulcano --vcf --plink

## A4. FST (Stacks --fstats; the paper reports hierfstat FST computed in R on the
##     linkage-pruned set — 07_diversity_Ne/hierFstat.R) ------------------------
populations -P . -M $POP/pure_samples_raf_sic --fstats -p 2 -r 100 -O populations_fst -t 8

## A5. introgress input: all individuals incl. hybrids/intermediates at the pure-
##     species loci; fixed markers (FST = 1) are selected inside introgress_analysis.R
populations -P . -M $POP/samples_introgress -W populations_structure/round_1/whitelist_pure_sic_raf.tsv \
            --out introgess_check --vcf -t 24

## A6. NewHybrids (v4 = the version in the paper) ----------------------------
# loci genotyped in >=80 % of the "unknown" (intermediate) individuals
populations -P . -M $POP/NewHybrids_unknown_samples -r 0.8 --write-single-snp -O NewHybrid_v4/whitelist -t 24
# -> NewHybrid_v4/whitelist/whitelist.tsv (data/whitelists/newhybrids_unknown_r0.8_whitelist.tsv)
# pure reference individuals at those loci -> genepop for hybriddetective::getTopLoc
populations -P . -M $POP/NewHybrids_pure_samples -r 0.8 -p 2 -W NewHybrid_v4/whitelist/whitelist.tsv \
            -O NewHybrid_v4/pure_samples -t 24 --genepop --vcf
# top-50 diagnostic panel chosen by getTopLoc (data/whitelists/newhybrids_top_50_whitelist.tsv);
# unknown individuals genotyped at that panel
populations -P . -M $POP/NewHybrids_unknown_samples -W NewHybrid_v4/top_loci/top_50_whitelist.tsv \
            -O NewHybrid_v4/unknown_samples_top50 --genepop -t 24 --vcf

## A7. GenotypePlot of the four hybrids (87 SNPs / 49 loci, FST > 0.9 between
##     pure species, no missing data) -- run 2023-12 ---------------------------
populations -P . -M $POP/samples_sic_raf_hybrid -r 100 -W populations_fst/fst_greater_than_0.9.whitelist.tsv \
            --vcf -O populations_fst/whitelist_high_fst

###################### B. reference-mapped catalogue ##########################
cd "$RM"
RPOP=$RM/popmaps
WL=$RM/output/Z_W_removed_whitelist.tsv     # autosomal loci only (03_refmap_assembly/03_*.sh)

## B1. genetic diversity (HE, HO, AR, FIS): individuals with <=10 % missing data
##     (raffonei n=60, siculus n=30), loci in both species, no missing genotypes
populations -P output -W $WL -M $RPOP/raf_sic_highqual --min-mac 2 -p 2 -r 1 -O populations_no_missing --vcf -t 24

## B2. down-sampling check: five random draws of 30 raffonei
for i in 1 2 3 4 5; do
  populations -P output -W $WL -M $RPOP/raffonei_downsample/raffonei_highqual_downsampled_iter$i \
              --min-mac 2 -p 2 -r 1 -O pop_down$i --vcf -t 24
done

## B3. Ne (LD method, NeEstimator v2.1): the 74 P. raffonei sampled in 2017,
##     autosomal loci, no missing data -> populations.snps.genepop
populations -P output -W $WL -M $RPOP/2017_raffonei --min-mac 2 -p 1 -r 1 -O neestimator --vcf -t 24 --genepop

## B4. sex-chromosome check (all individuals, all chromosomes) -- run 2024-09
populations -P output -O sex_chromosome_analysis -M $RPOP/all_inds_refmap_popmap --vcf -r 0.8 -t 8
