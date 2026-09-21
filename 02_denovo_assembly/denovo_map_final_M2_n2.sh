#!/bin/bash
##############################################################################
## Final de novo catalogue used for all structure / hybrid analyses.
## Command taken verbatim (paths generalised) from
##   outputs/denovo_master/denovo_map.log  (denovo_map.pl v2.60, 2022-05-02):
##   denovo_map.pl --samples outputs/samples/ --popmap data/popmaps/samples_simple \
##                 --paired -o . -M 2 -n 2 -T 32
## m defaults to 3.  134 individuals in popmap samples_simple (one nominal pop).
## Optimal M (=2 for each species) and n (=2) were chosen with the r80 method
## using the scripts in parameter_optimisation/.
##############################################################################
set -euo pipefail
MASTER=${MASTER:-/path/to/capo_grosso_analysis}
samples_dir=$MASTER/outputs/samples            # demultiplexed *.1.fq.gz / *.2.fq.gz
popmap=$MASTER/data/popmaps/samples_simple
out_dir=$MASTER/outputs/denovo_master
mkdir -p "$out_dir"

denovo_map.pl \
    --samples "$samples_dir" \
    --popmap  "$popmap" \
    --paired \
    -o "$out_dir" \
    -M 2 \
    -n 2 \
    -T 32
