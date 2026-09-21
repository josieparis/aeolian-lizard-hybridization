#!/bin/bash
##############################################################################
## RECONSTRUCTED (2026) loop for ADMIXTURE v1.3.0.  The per-run logs are
## preserved on the server (populations_structure/admixture/run{1..10}/log{K}.out)
## and record: "Cross-validation will be performed. Folds=10", 24 threads,
## a distinct random seed per run, K = 1..8 (the paper reports K = 1-7).
## Q matrices were renamed run<r>.<K>.Q after each run.  CV errors from all
## logs were collected into CV_error_10runs.txt (columns K, error, Run) for
## plot_CV_error.R.  Best K = 3 (K = 2 nearly identical CV); K = 2 assigns
## every pure individual with > 99 % probability.
##############################################################################
set -euo pipefail
MASTER=${MASTER:-/path/to/capo_grosso_analysis}
cd "$MASTER/outputs/denovo_master/populations_structure/admixture"
bed=pop_structure_filtered.bed          # copy of round_3/pop_structure_filtered.{bed,bim,fam}

for r in $(seq 1 10); do
    mkdir -p run$r && cd run$r
    for K in $(seq 1 8); do
        admixture --cv=10 -j24 -s $RANDOM ../$bed $K | tee log$K.out
        mv pop_structure_filtered.$K.Q run$r.$K.Q
    done
    cd ..
done

# CV-error table for plot_CV_error.R
{ printf "K\terror\tRun\n"
  for r in $(seq 1 10); do
      grep -h "CV error" run$r/log*.out | sed -E "s/CV error \(K=([0-9]+)\): ([0-9.]+)/K\1\t\2\trun$r/"
  done; } > CV_error_10runs.txt
