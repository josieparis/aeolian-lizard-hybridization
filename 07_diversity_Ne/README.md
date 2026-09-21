# 07_diversity_Ne/

* `hierFstat.R` — vcfR → genind → hierfstat `basic.stats` / `allelic.richness`; run on
  `populations_no_missing` (ref-mapped, autosomal, no missing data) and on each `pop_down1-5` iteration
  (the script as archived points at `raffonei.iter5.recode.vcf`). The same script was used for FST on the
  2,623-SNP structure set with a two-population popmap.
* `raincloud_plots.R` — per-individual observed heterozygosity distributions.
* `neestimator_settings.md` — how the LD-Ne estimates were obtained (NeEstimator GUI; no command line exists).
