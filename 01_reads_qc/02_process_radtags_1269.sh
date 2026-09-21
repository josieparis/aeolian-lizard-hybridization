#!/bin/bash
##########################################
## Script to run process radtags
###########################################
# process_radtags -p in_dir [--paired [--interleaved]] [-b barcode_file] -o out_dir -e enz [-c] [-q] [-r] [-t len]
# process_radtags -f in_file [-b barcode_file] -o out_dir -e enz [-c] [-q] [-r] [-t len]
# process_radtags -1 pair_1 -2 pair_2 [-b barcode_file] -o out_dir -e enz [-c] [-q] [-r] [-t len]


### Set paths
## set master dir
MASTER=${MASTER:-/path/to/capo_grosso_analysis}   # original: /home/dsalvi/LIZARD/raffonei_siculus/analysis
barcode_dir=$MASTER/data/barcodes
input_dir=$MASTER/data/clean_reads
output_dir=$MASTER/outputs/process_radtags_1269

## run 
process_radtags \
		-1 $input_dir/180209_SND405_A_L002_GWM-1269_R1.clean.fastq.gz \
		-2 $input_dir/180209_SND405_A_L002_GWM-1269_R2.clean.fastq.gz \
		-b $barcode_dir/library_1269_barcodes.tsv \
		-o $output_dir \
		-e sbfI \
		--renz_2 mspI \
		-q -c -r
