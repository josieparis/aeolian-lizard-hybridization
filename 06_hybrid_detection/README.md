# 06_hybrid_detection/

* `introgress/introgress_analysis.R` — reads the introgress-input VCF (`populations` run A5 in `04_populations`,
  then the same vcftools filter as the structure set), keeps loci fixed between the reference *raffonei* and
  *siculus* groups (1,081), runs `est.h` (1,000 bootstraps) and draws the triangle plot. `introgress` (1.2.3) was
  archived from CRAN, so the package's R functions are vendored in `introgress_functions/` and `source()`d.
  `introgress_old_hybrids.R` in the original folder is an earlier version and is not included.
* `newhybrids/newhybrids_v4_analysis.R` — full hybriddetective / parallelnewhybrid workflow (panel selection,
  frequency-based simulation, convergence checks, power comparison, empirical + simulated run). Needs local
  NewHybrids, PLINK and PGDSpider installs; paths are set at the top. `plot_newhybrids.R` plots the PofZ output.
  Versions v1–v3 in the original folder were development iterations.
* `genotype_plot/raf_sic_genotype_plot.R` — GenotypePlot of the four hybrid individuals at the 49 FST > 0.9 loci.
