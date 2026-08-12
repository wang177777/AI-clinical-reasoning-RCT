# Web-Based DeepSeek Assistance for Clinical Decision-Making Among Physicians in China: Randomized Controlled Trial

Analysis and figure-construction code accompanying the prospective, 2-arm, parallel-group randomized controlled trial prepared for the *Journal of Medical Internet Research*.

## Trial overview

- The complete randomized population comprised 174 licensed physicians: 87 assigned to DeepSeek assistance plus conventional resources and 87 assigned to conventional resources alone.
- All 174 participants received their assigned condition, completed the five-case assessment, and were included in the intention-to-treat analysis.
- The intervention used the public DeepSeek chat interface with web search disabled.
- Two clinical raters independently scored diagnosis, investigation ordering, treatment planning, risk assessment, and follow-up. Implemented maxima were 20, 20, 30, 15, and 15 points, respectively, for a total range of 0-100.
- Mean total scores were 77.5 (SD 9.8) with DeepSeek assistance and 68.2 (SD 10.5) with conventional resources (mean difference 9.3 points, 95% bootstrap CI 6.3-12.3; Cohen d=0.92, 95% bootstrap CI 0.60-1.30).
- Treatment planning showed the largest difference. Investigation ordering favored conventional resources in the 2-rater average, but its rater-specific directions differed and single-rater reliability was low (ICC=0.267).
- Mean full-task duration was 44.1 minutes with assistance and 55.3 minutes with conventional resources. Assisted responses were 6.62 times as long, and answer length correlated with total score (Spearman rho=0.776).
- Chinese Clinical Trial Registry: [ChiCTR2600120307](https://www.chictr.org.cn/hvshowproject.html?id=296940&v=1.0), retrospectively registered March 12, 2026.

## Repository structure

```text
analysis/
  01_primary_outcome.py
  02_case_dimension.py
  03_mixed_effects.R
  07_interrater_reliability.py
  08_process_construct_validity.R

figures/
  Fig1_study_flow.py
  corrected_aggregate_figures.R

data/
  README.md
```

## Reproducibility scope

The scripts implement the statistical and figure-construction procedures reported in the manuscript:

- Welch primary comparison, Mann-Whitney sensitivity analysis, and fixed-seed participant bootstrap;
- 11-outcome Mann-Whitney/FDR family and dimension-specific effect-size bootstrap;
- raw-score and percentage-of-maximum mixed-effects models and the equal-weight composite;
- ICC(2,1), agreement summaries, and the rater-specific investigation-ordering analysis;
- total-task duration, answer length, score-length association, and noncausal answer-length-conditioned construct checks; and
- the CONSORT flow and aggregate outcome figures using the reported counts and values.

The figure script contains the unrounded aggregate values underlying the rounded values in the manuscript. Participant-level inputs are required to run participant-level analyses and are not public.

## Data availability

Participant-level data, source records, identifiable responses, recordings, interaction logs, the data dictionary, and standalone aggregate-result data files are not included in this repository. Aggregate findings are reported in the manuscript and multimedia appendix. See [data/README.md](data/README.md) for the private input schemas used by the code.

## Requirements

Python 3.10 or later:

```bash
pip install -r requirements.txt
```

R 4.3 or later:

```r
install.packages(c("lme4", "lmerTest", "ggplot2", "cowplot"))
```

## License

MIT License. See [LICENSE](LICENSE).
