# NeEstimator v2.1 — settings used (recovered from the archived output file)

Input: `outputs/refmap_raffonei/neestimator/populations.snps.genepop`
(reference-mapped catalogue, autosomal loci only via `Z_W_removed_whitelist.tsv`,
popmap `2017_raffonei` = the 74 *P. raffonei* sampled at Capo Grosso in 2017,
`--min-mac 2 -p 1 -r 1`, one population). 3,501 loci after NeEstimator's own screening.

NeEstimator was run through its GUI (no command line is preserved); the header of
`populations.snpsLD.txt` (run 2023-08-10) records:

| Setting | Value |
|---|---|
| Method | Linkage disequilibrium |
| Mating model | Random |
| Critical allele frequencies (Pcrit) | 0.05, 0.02, 0.01, "No S*" (singletons excluded), 0+ |
| Confidence intervals | parametric and jackknife on samples |

Results as reported in the paper:

| Column | Ne | 95 % CI (jackknife) |
|---|---|---|
| Pcrit 0.05 ("with singletons" in the paper) | 63.8 | 54.7 – 75.5 |
| Pcrit 0.02 | 69.2 | 53.5 – 93.5 |
| Pcrit 0.01 / No S* / 0+ ("excluding singletons") | 49.8 | 25.5 – 133.7 |

Earlier de novo-based runs (`raffonei.denovo.missing50*`, `raffonei.denovo.no-missing*`)
were superseded by the reference-mapped one above.
