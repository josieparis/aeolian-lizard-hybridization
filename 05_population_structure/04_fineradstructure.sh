#!/bin/bash
##############################################################################
## RECONSTRUCTED (2026).  fineRADstructure v0.3.2 on the haplotype set from
## populations --fineRAD (populations_structure/fineRAD/round_2/populations.haps.radpainter,
## 17,254 variant sites).  Parameters from the STAR Methods: "100,000 MCMC
## iterations with a thinning interval of 1000, discarding the first 10,000
## iterations as burn-in, and building a tree with 10,000 hill-climbing
## iterations" -- i.e. the developers' recommended settings.  The output file
## names below match the archived results (populations.haps_chunks.out,
## populations.haps_chunks.mcmc.xml, populations.haps_chunks.mcmcTree.xml),
## which are plotted by plot_fineRADstructure.R (uses FinestructureLibrary.R
## shipped with fineRADstructure).
##############################################################################
set -euo pipefail
MASTER=${MASTER:-/path/to/capo_grosso_analysis}
cd "$MASTER/outputs/denovo_master/populations_structure/fineRAD/round_2"
in=populations.haps.radpainter

RADpainter paint $in                                   # -> populations.haps_chunks.out
finestructure -x 10000 -y 100000 -z 1000 \
    populations.haps_chunks.out populations.haps_chunks.mcmc.xml
finestructure -m T -x 10000 \
    populations.haps_chunks.out populations.haps_chunks.mcmc.xml populations.haps_chunks.mcmcTree.xml
