# Aeolian lizard hybridization


<img width="642" height="304" alt="Screenshot 2026-09-21 at 17 54 33" src="https://github.com/user-attachments/assets/8be42fa5-3318-4118-8872-1c3c87c95c10" />


Code and configuration files for:

> Paris JR, Ficetola GF, Ferrer Obiol J, Silva-Rocha I, Carretero MA, Salvi D (2024).
> **Does hybridization with an invasive species threaten Europe's most endangered reptile?
> Genomic assessment of Aeolian lizards on Vulcano island.** *iScience* 27(11):111097.
> https://doi.org/10.1016/j.isci.2024.111097

ddRAD-seq of the critically endangered Aeolian wall lizard *Podarcis raffonei* (Capo Grosso,
Vulcano; Scoglio Faraglione) and the invasive Italian wall lizard *P. siculus* (Vulcano; Milazzo,
Sicily), sampled in 2015 and 2017: population structure, hybrid detection, genetic diversity and
effective population size.

**Data:** raw reads at ENA [PRJEB77477](https://www.ebi.ac.uk/ena/browser/view/PRJEB77477).
Reference genome *P. raffonei* rPodRaf1.pri, NCBI RefSeq
[GCF_027172205.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_027172205.1/).

## Provenance — please read

The paper states "this paper does not report original code"; this repository was assembled
afterwards (September 2026) from the original analysis directories. Three kinds of file:

| Tag | Meaning |
|---|---|
| **original** | copied verbatim from the analysis server / analysis folder. Only the hard-coded master path was replaced by `MASTER=${MASTER:-/path/to/capo_grosso_analysis}` (the original value is kept in a trailing comment). R scripts keep their original `setwd()` lines, which point at the author's directory layout. |
| **from log** | the command was run interactively; it is copied from the tool's own log (`denovo_map.log`, `populations.log`, PLINK `.log`, BAM `@PG` headers, ADMIXTURE `log*.out`, NeEstimator output). Parameters are therefore exact. |
| **RECONSTRUCTED** | no script or log survives; the file is a rewrite from the parameters given in the paper's STAR Methods plus whatever the surviving inputs/outputs constrain (file names, counts). Each such file says so in its header and states its evidence. |

All ~100 `populations` invocations that exist on the server, including exploratory ones not used
in the paper, are listed in [`04_populations/all_stacks_commands.tsv`](04_populations/all_stacks_commands.tsv).
A step-by-step mapping from the paper's Methods to files, including where the original outputs live,
is in [`docs/methods_to_scripts_index.md`](docs/methods_to_scripts_index.md).

## Pipeline

```
01_reads_qc/                fastp length filter → process_radtags per lane ×7 [original]
02_denovo_assembly/         M / n parameter sweeps [original] → r80 plots [original] → final denovo_map M2 n2 [from log]
03_refmap_assembly/         bwa mem to rPodRaf1.pri [from BAM @PG] → ref_map.pl [original] → Z/W sexing + Z/W-free whitelist [RECONSTRUCTED]
04_populations/             every populations run used in the paper, in order [from log]
05_population_structure/    vcftools filter → PLINK PCA [from log] → ADMIXTURE ×10 [RECONSTRUCTED loop, params from logs]
                            → fineRADstructure [RECONSTRUCTED] ; R plotting scripts [original]
06_hybrid_detection/        introgress, NewHybrids (parallelnewhybrid + hybriddetective), GenotypePlot — R [original]
07_diversity_Ne/            hierfstat HE/HO/AR/FIS + FST, raincloud plots [original]; NeEstimator settings [from output]
08_maps/                    rayshader / ggplot maps and islet-size plot [original]
data/                       barcodes, popmaps (de novo and ref-map), locus whitelists [original]
docs/                       methods → scripts index
```

### 1. Reads and demultiplexing
* `01_fastp_length_filter.sh` — drop reads < 125 bp (fastp 0.23.2) on each of the 7 HiSeq 2500 lanes.
* `02_process_radtags_<lane>.sh` — SbfI + MspI, `-q -c -r`, barcodes in `data/barcodes/`. 133 individuals retained.

### 2. De novo catalogue (Stacks 2.60)
* `parameter_optimisation/` — `denovo_map_raf_M1-8.sh`, `denovo_map_sic_M1-8.sh` (M per species, `-X "populations: -R 0.8"`),
  `denovo_map_M2_n2-10.sh` (n), `plotting_denovo_opt_params.R`. Result: M = 2 for both species, n = 2.
* `denovo_map_final_M2_n2.sh` — all 134 samples, `--paired -M 2 -n 2`.

### 3. Reference-mapped catalogue (Stacks 2.64)
* `01_bwa_align.sh` — `bwa mem -t 12 -M` (0.7.17) → `samtools view -bS | sort` (1.14); gstacks discards secondary alignments.
* `02_ref_map.sh` — `ref_map.pl` on the 133 BAMs.
* `03_sex_from_ZW_reads_and_ZW_whitelist.sh` — fraction of reads on Z (NC_070621.1) and W (NC_070620.1) per individual,
  and the autosomal-only whitelist (39,220 of 41,230 loci; `data/whitelists/refmap_Z_W_removed_whitelist.tsv`).

### 4. `populations` runs
`paper_populations_runs.sh` — the ordered set: structure whitelist (`-p 2 -r 0.5 --min-mac 2 --write-single-snp`) →
all-sample SNP set → fineRAD haplotypes → by-year/site subsets → FST → introgress input → NewHybrids panels →
GenotypePlot loci → (ref-map) diversity, down-sampling ×5, Ne input, sex-chromosome check.

### 5. Population structure
* `01_vcftools_filter.sh` — `--minDP 3 --max-meanDP 80 --minGQ 30` → 2,623 SNPs; QC tables for `plot_depth_missingness.R`.
* `02_plink_pca.sh` + `PCA_plotting_script.R`, `PCA_plot_species_clusters.R`.
* `03_admixture_runs.sh` — K 1–8, 10 runs, `--cv=10`; `plot_CV_error.R`, `plot_admixture_results.R`,
  `admixture_hierarchical.R` (Capo Grosso by year, Vulcano by year, Vulcano vs Milazzo).
* `04_fineradstructure.sh` (100k MCMC, thin 1000, burn-in 10k, tree 10k) + `plot_fineRADstructure.R`.

### 6. Hybrid detection
* `introgress/introgress_analysis.R` — introgress 1.2.3 (archived from CRAN; the package functions are vendored in
  `introgress_functions/`), 1,081 fixed loci, `est.h` with 1,000 bootstraps, triangle plot.
* `newhybrids/newhybrids_v4_analysis.R` — hybriddetective `getTopLoc` (50-locus panel) → `freqbasedsim_GTFreq`
  (3 sims × 3 reps) → `parallelnh_OSX` (simulated: burn-in 10k / 50k sweeps; empirical+simulated: 50k / 200k)
  → `nh_preCheckR`, `hybridPowerComp`; `plot_newhybrids.R`.
* `genotype_plot/raf_sic_genotype_plot.R` — GenotypePlot 0.2.1, 87 SNPs / 49 loci with FST > 0.9, four hybrids.

### 7. Diversity and Ne
* `hierFstat.R` — hierfstat 0.5.11 on the ref-mapped, autosomal, no-missing set (≤ 10 % missing individuals:
  *raffonei* n = 60, *siculus* n = 30; down-sampled iterations 1–5); also used for FST on the linkage-pruned set.
* `raincloud_plots.R` — per-individual heterozygosity.
* `neestimator_settings.md` — NeEstimator 2.1 LD method; Pcrit columns behind the 63.8 / 49.8 estimates.

### 8. Maps
`map_aeolian_islands.R` (rayshader 0.38.1), `master_capo_grosso_map.R`, `islet_sizes_plot.R`.

## Software versions (as recorded in logs)

| Tool | Version | Tool | Version |
|---|---|---|---|
| fastp | 0.23.2 | PLINK | 1.9 |
| Stacks (de novo) | 2.60 | ADMIXTURE | 1.3.0 |
| Stacks (ref-map) | 2.64 | fineRADstructure | 0.3.2 |
| bwa | 0.7.17-r1188 | NeEstimator | 2.1 |
| samtools | 1.14 | NewHybrids | 2.0 (via parallelnewhybrid 1.0.1, hybriddetective) |
| vcftools | 0.1.17 | R | 4.0.2 |
| | | introgress | 1.2.3 |
| | | GenotypePlot | 0.2.1 |
| | | hierfstat | 0.5.11 |

## Not in the paper

The original analysis directories also contain Stairway Plot 2 (SFS from the de novo catalogue), temporal-method
Ne, sample-size simulations, SLiM/slendR simulations and an earlier reference-mapping to *P. muralis*.
None of these appear in the published paper and they are not included here.

## Citation

If you use this code please cite the paper above. Contact: Josephine R. Paris.

## License

[MIT](LICENSE).
