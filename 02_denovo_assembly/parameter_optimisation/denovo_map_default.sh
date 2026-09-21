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
output_dir=$MASTER/outputs/denovo_map_default

## run with more or less defaults (m3, M2, n3)
denovo_map.pl \
    --samples $input_dir \
    --paired \
    --popmap $popmap_dir/capo_grosso_anchors_wag_popmap \
    -o $output_dir \
    -M 2 \
    -n 3 \
    -T 24
