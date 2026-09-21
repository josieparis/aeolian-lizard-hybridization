#!/bin/bash

##########################################
## Script to run ref_map
###########################################
# ref_map.pl --samples dir --popmap path [-s spacer] --out-path path [--rm-pcr-duplicates] [-X prog:"opts" ...] 


### Set paths
## set master dir
MASTER=${MASTER:-/path/to/capo_grosso_analysis}/outputs/refmap_raffonei   # original: /home/dsalvi/LIZARD/raffonei_siculus/capo_grosso_analysis/outputs/refmap_raffonei
popmap_dir=$MASTER/popmaps
input_dir=$MASTER/aligned
output_dir=$MASTER/output

ref_map.pl --samples $input_dir --popmap $popmap_dir/all_inds_refmap_popmap --out-path $output_dir -T 24
