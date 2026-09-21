#!/bin/bash
##############################################################################
## PLINK v1.9 binary conversion and PCA.  Options copied from the PLINK logs
## on the server:
##   round_3/plink.log:               plink --file pop_structure_filtered --make-bed
##   PCA/pop_structure_filtered.log:  plink --bfile pop_structure_filtered --out pop_structure_filtered --pca
## The .eigenvec was then annotated by hand with population / location /
## plotting-shape columns -> pop_structure_filtered.eigenvec.tsv, the input
## of PCA_plotting_script.R.  PC1 explains 87 % of the variance.
##############################################################################
set -euo pipefail
MASTER=${MASTER:-/path/to/capo_grosso_analysis}
cd "$MASTER/outputs/denovo_master/populations_structure/round_3"
plink --file  pop_structure_filtered --make-bed
plink --bfile pop_structure_filtered --out pop_structure_filtered --pca
