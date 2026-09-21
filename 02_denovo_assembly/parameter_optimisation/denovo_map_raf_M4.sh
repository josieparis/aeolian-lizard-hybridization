#!/bin/bash
##########################################
## Script to run denovomap
###########################################
# denovo_map.pl --samples dir --popmap path -o dir [--paired [--rm-pcr-duplicates]] (assembly options) (filtering options) [-X prog:"opts" ...]

### Set paths
## set master dir
MASTER=${MASTER:-/path/to/capo_grosso_analysis}   # original: /home/dsalvi/LIZARD/raffonei_siculus/analysis
popmap_dir=$MASTER/data/popmaps
input_dir=$MASTER/data/process_radtags_out
output_dir=$MASTER/outputs/denovo_opt_raf/M4

denovo_map.pl \
    --samples $input_dir \
    --paired \
    --popmap $popmap_dir/denovo_opt_raf_noscog_onepop \
    -o $output_dir \
    -m 3 \
    -M 4 \
    -n 4 \
    -X "populations: -R 0.8" \
    -T 12

