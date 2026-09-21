# data/

Small configuration inputs copied verbatim from the analysis directories. Sample IDs are the
tissue-collection numbers (DB#####) used in the ENA submission (PRJEB77477).

* `barcodes/` — process_radtags barcode → sample files, one per sequencing lane (619, 816-1/2/3, 1267/1268/1269).
* `popmaps_denovo/` — every popmap used with the de novo catalogue (`data/popmaps/` on the server).
  Paper runs use: `no_intermediates`, `samples_simple`, `samples_simple_fineRAD`, `raffonei_2015_2017`,
  `siculus_2015_2017`, `all_siculus`, `pure_samples_raf_sic`, `samples_introgress`, `NewHybrids_{pure,unknown,hybrid}_samples`,
  `samples_sic_raf_hybrid`. The rest belong to exploratory analyses (Ne temporal simulations, SFS subsets…).
* `popmaps_refmap/` — popmaps used with the reference-mapped catalogue: `all_inds_refmap_popmap` (133 inds),
  `raf_sic_highqual` (60 + 30, ≤ 10 % missing), `2017_raffonei` (74, Ne), `raffonei_downsample/*iter1-5` (30 each).
* `whitelists/` — locus-ID whitelists passed to `populations -W`:
  * `structure_whitelist_pure_sic_raf.tsv` — loci in both species, r ≥ 0.5, mac ≥ 2 (structure, introgress, fineRAD)
  * `newhybrids_unknown_r0.8_whitelist.tsv`, `newhybrids_top_50_whitelist.tsv` — NewHybrids v4 panels
  * `genotypeplot_fst_greater_than_0.9.whitelist.tsv` — 49 loci for the hybrid genotype plot
  * `refmap_Z_W_removed_whitelist.tsv` — 39,220 autosomal loci of the reference-mapped catalogue
