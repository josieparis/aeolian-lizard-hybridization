# Paris et al. 2024 iScience — where every analysis lives

**Paper:** Paris JR, Ficetola GF, Ferrer Obiol J, Silva-Rocha I, Carretero MA, Salvi D (2024). *Does hybridization with an invasive species threaten Europe's most endangered reptile? Genomic assessment of Aeolian lizards on Vulcano island.* iScience 27:111097. doi:10.1016/j.isci.2024.111097 · PMC11513564 · ENA PRJEB77477

Two roots (abbreviated below):

| Alias | Path |
|---|---|
| **SERVER** | `raganella:/bigdata/dsalvi/LIZARD/raffonei_siculus/capo_grosso_analysis/` |
| **DROPBOX** | `~/Library/CloudStorage/Dropbox/Laquila_lizards/capo_grosso/analysis/` |

Server side = Stacks pipeline + PLINK/ADMIXTURE runs (all under `outputs/denovo_master/` and `outputs/refmap_raffonei/`).
Dropbox side = every R script, NewHybrids/introgress/NeEstimator runs, figures.
The server scripts still reference the old path `/home/dsalvi/LIZARD/raffonei_siculus/analysis/` — same tree, since moved to `/bigdata` and renamed `capo_grosso_analysis`.

---

## 1. Reads → loci

| Paper step | Script / command record | Notes |
|---|---|---|
| Raw reads (7 HiSeq lanes) | SERVER `data/raw_reads/` (28 GB) | GWM-619 (2015), GWM-816-1/2/3 (2016), GWM-1267/1268/1269 (2018); .md5 files present |
| fastp v0.23.2 (drop reads <125 bp) | **not preserved** | FastQC reports of clean reads in DROPBOX `QC/clean/*.clean_fastqc.html`; the fastp command itself is not in any script or history |
| process_radtags | SERVER `scripts/process_radtags_{619,816-1,816-2,816-3,1267,1268,1269}.sh` | barcodes in `data/barcodes/`; outputs `outputs/process_radtags_*/`; 134 demuxed samples in `outputs/samples/` |
| M optimisation, per species | SERVER `scripts/denovo_map_raf_M{1..8}.sh`, `denovo_map_sic_M{1..8}.sh` | run Mar 2022 |
| n optimisation | SERVER `scripts/denovo_map_M2_n{2..10}.sh` (+ `M4_m5`, `M5_m5`, `default`, `hyb`) | |
| Plot r80 loci vs M/n | DROPBOX `denovo_opt/plotting_denovo_opt_params.R`, `param_opt_M_values.xlsx`, `littlen_opt.txt`, `*_r80.txt` | |
| **Final de novo assembly** (M=2, n=2, 134 inds) | SERVER `outputs/denovo_master/denovo_map.log` line 2: `denovo_map.pl --samples outputs/samples/ --popmap data/popmaps/samples_simple --paired -o . -M 2 -n 2 -T 32` (2022-05-02, Stacks 2.60) | No standalone .sh for this exact run — `scripts/denovo_map_opt.sh` (n4) and `denovo_map_raffonei_capo_grosso.sh` (n3) are earlier variants |
| **Ref-mapped assembly** (rPodRaf1.pri GCF_027172205.1, bwa mem -M, secondaries removed) | SERVER `outputs/refmap_raffonei/scripts/ref_map.sh`; genome + bwa index `outputs/refmap_raffonei/genome/`; BAMs + `.flagstat` + `.idxstats` in `aligned/` (133); `output/ref_map.log` | The bwa/samtools alignment loop itself is **not preserved** (Aug 2023, history rotated) |
| (earlier P. muralis ref-map, Aug 2022) | SERVER `outputs/refmap_muralis/` | superseded, not in paper |

## 2. Structure & hybrid detection (de novo catalog)

| Paper step | Script / command record |
|---|---|
| Whitelist: loci in both species, -p 2, -r 0.5, --min-mac 2 | SERVER `denovo_master/populations_structure/round_1/populations.log` → `-M no_intermediates -r 0.5 -p 2 --min-mac 2 --write-single-snp --vcf` → `whitelist_pure_sic_raf.tsv` |
| All-sample dataset on that whitelist | `populations_structure/round_2/populations.log` → `-M samples_simple -W round_1/whitelist_pure_sic_raf.tsv --write-single-snp --vcf` (2,623 SNPs) |
| Haplotype dataset (17,254 sites) for fineRADstructure | `populations_structure/fineRAD/round_1/` (whitelist) → `fineRAD/round_2/populations.log` → `-M samples_simple_fineRAD -W ... --fineRAD` → `populations.haps.radpainter` |
| vcftools --minDP 3 --max-meanDP 80 --minGQ 30 | **command not preserved**; product = `populations_structure/PCA/pop_structure_filtered.{bed,bim,fam}` and DROPBOX `pop_structure/fst/pop_structure_filtered.vcf` |
| PCA (PLINK 1.9 --pca) | SERVER `populations_structure/PCA/pop_structure_filtered.log` (`plink --bfile pop_structure_filtered --pca`); plotting DROPBOX `pop_structure/PCA/PCA_plotting_script.R`, `species_separate/PCA_plot_species_clusters.R`; per-year subsets SERVER `round_4_raffonei_CG/`, `round_5_siculus_vulc/`, `round_6_milazzo_vulcano/` |
| Fst (hierfstat) | DROPBOX `diversity/hierFstat.R` (also used for diversity, see §3); inputs `pop_structure/fst/pop_structure_fst.recode.vcf`, `pop_IDs.txt`. Stacks-side --fstats run in SERVER `denovo_master/populations_fst/` (`-M pure_samples_raf_sic --fstats -p 2 -r 100`) |
| fineRADstructure v0.3.2 (100k MCMC, thin 1000, burn 10k, tree 10k) | RADpainter/fineSTRUCTURE **command not preserved**; run outputs DROPBOX `pop_structure/fineRAD/populations.haps_chunks.{out,mcmc.xml,mcmcTree.xml}`; plot `pop_structure/fineRAD/plot_fineRADstructure.R` |
| ADMIXTURE 1.3, K1–7, 10 runs, CV=10 | SERVER `populations_structure/admixture/run{1..10}/log{1..8}.out` (seeds, CV errors); loop command not preserved. DROPBOX `pop_structure/admixture/{plot_CV_error.R, plot_admixture_results.R, admixture_hierarchical.R, CV_error_10runs.txt, results/}`; sub-analyses `capo_grosso_by_year/`, `vulcano_by_year/`, `vulcano_milazzo/` |
| introgress 1.2.3 (1,081 fixed loci, est.h 1000 boots) | SERVER `denovo_master/introgess_check/populations.log` (`-M samples_introgress -W whitelist_pure_sic_raf.tsv --vcf`); DROPBOX `introgress/introgress_analysis.R` (main), `introgress_old_hybrids.R`, `introgress_functions/` (patched package source), `vcf_files/`, `popmap_introgress.tsv` |
| NewHybrids 2.0 via parallelnewhybrid + hybriddetective | SERVER `denovo_master/NewHybrid_v4/` (`whitelist/` → `top_loci/top_50_whitelist.tsv` → `pure_samples/all_loci/`, `unknown_samples_top50/`; genepop outputs); DROPBOX `NewHybrids_v4/newhybrids_v4_analysis.R`, `plotting/plot_newhybrids.R`, `parallelnewhybrids_simulation_50/`, `empirical_simulation_50/`, `combine_sim_empirical/`. v1–v3 = earlier iterations (both sides) |
| Genotype Plot 0.2.1 (87 SNPs / 49 loci, 4 hybrids) | SERVER `denovo_master/populations_fst/whitelist_fst_0.9/populations.log` (`-M samples_sic_raf_hybrid -r 100 -W fst_greater_than_0.9.whitelist.tsv --vcf`, Dec 2023); DROPBOX `visualise_hybrids/raf_sic_genotype_plot.R` + `genotype_plot.3.vcf`, `samples_popmap_by_ind` |
| Fixed-sites check | DROPBOX `fixed_sites/` |

## 3. Diversity & Ne (ref-mapped catalog, Z/W loci removed)

| Paper step | Script / command record |
|---|---|
| Z/W removal whitelist | SERVER `refmap_raffonei/output/Z_W_removed_whitelist.tsv` (how it was built is not scripted) |
| HE/HO/AR/FIS, ≤10 % missing (raffonei 60, siculus 30) | SERVER `refmap_raffonei/populations_no_missing/populations.log` → `-M raf_sic_highqual -W Z_W_removed_whitelist.tsv --min-mac 2 -p 2 -r 1 --vcf`; DROPBOX `diversity/hierFstat.R` (reads `diversity/refmap_aligned_data/raffonei.iter5.recode.vcf`, `*.no.missing.recode.vcf`), results `diversity/final_diversity_stats.txt`, `het_per_individual.txt`; plot `diversity/raincloud_plots.R` |
| Downsampling iterations | SERVER `refmap_raffonei/pop_down{1..5}/` + popmaps `refmap_raffonei/popmaps/raffonei_downsample/`; DROPBOX `diversity/refmap_aligned_data/raffonei.iter{1..5}.recode.vcf` |
| (earlier de novo diversity, superseded) | SERVER `denovo_master/populations_diversity/`, `refmap_muralis/{raffonei,siculus,all_loci_diversity}/` |
| Ne (LD, NeEstimator 2.1, n=60, ± singletons) | SERVER `refmap_raffonei/neestimator/populations.log` → `-W Z_W_removed_whitelist.tsv -M 2017_raffonei --min-mac 2 -p 1 -r 1 --genepop`; DROPBOX `neesimator/populations.snps.gen` (input) + `populations.snpsLD.txt` (NeEstimator output); `neesimator/old/` = de novo-based versions |
| (Ne temporal / sample-size tests, not in paper) | SERVER `denovo_master/Ne_temporal/`, `Ne_samplesize_test/`, `Ne_LD/`; DROPBOX `Ne_test.txt` |
| Sex from Z/W read proportion | SERVER `refmap_raffonei/aligned/*.idxstats` (per-sample chromosome counts); `refmap_raffonei/sex_chromosome_analysis/` (populations -r 0.8, Sep 2024). No script for the proportion calculation found |

## 4. Other

| Item | Location |
|---|---|
| 12S / cytb / ND4 Sanger alignments & NJ trees | DROPBOX `../single_genes/` |
| Maps (rayshader) | DROPBOX `map/map_aeolian_islands.R`, `map/master_capo_grosso_map.R`; `islet_sizes_plot.R` |
| Sample metadata | DROPBOX `capo_grosso_sample_metadata.txt`, `../raffoeni_siculus_metadata/`; barcodes/2017 data in `../Steph_analysis/` |
| ENA submission PRJEB77477 | DROPBOX `../ENA_upload/` (sample + run TSVs, Webin receipts, 2024-08-30) |
| Figures & manuscript | DROPBOX `../Figures/`, `../Manuscript/`, `figs/` |
| Not in paper: Stairway Plot, SLiM, slendR | SERVER `stairway_plot/`, `denovo_master/SFS_building/`; DROPBOX `stairway_plot*/`, `slimulations/`, `slendR/` |

## 5. Gaps — commands that exist nowhere as a script

Server `.bash_history` only holds 2,000 lines (2025–26 work), so these interactive steps survive only as their outputs + the parameters quoted in the paper:

1. `fastp` read-length filter
2. `bwa mem -M` + samtools (sort, drop secondary) alignment loop to rPodRaf1.pri
3. `vcftools --minDP 3 --max-meanDP 80 --minGQ 30` filtering
4. ADMIXTURE 10-run × K1–7 loop (seeds/CV are in the log*.out files)
5. `RADpainter paint` / `finestructure -x 10000 -y 100000 -z 1000` / `-m T -x 10000`
6. NeEstimator v2.1 GUI settings (LD method, Pcrit for singleton exclusion)
7. Z/W read-proportion sex calculation and construction of `Z_W_removed_whitelist.tsv`

All seven are short and fully reconstructable from the paper's STAR Methods if you want a clean repo.
