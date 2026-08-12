# AI-assisted clinical reasoning among Chinese physicians: a randomised controlled trial

Analysis and figure-generation code for the prospective, two-arm, parallel-group randomised controlled trial.

## Trial overview

- 174 physicians formed the complete randomised population.
- Allocation was 1:1: DeepSeek-assisted reasoning (n=87) versus conventional resources (n=87).
- All 174 participants received the assigned condition, completed the assessment, and were included in the intention-to-treat analysis.
- The retained case-task timestamps span 29 October to 4 November 2025. The public registry lists a broader recruitment period ending 25 March 2026.
- The original protocol set an operational target of 100 physicians per arm; recruitment yielded 87 complete randomised participants per arm, and the report does not use a post hoc power calculation.
- The earliest retained study supplement identifies computer-generated 1:1 allocation using Python's random module. The original sequence, seed, allocation roster, and concealment log were not retained, so later registry details about restrictions and sequence custody are not asserted as verified implementation.
- The intervention used the public DeepSeek chat interface with web-search/browsing disabled, plus conventional clinical resources. The exact backend model build and participant query sequences were not retained.
- Responses to five standardised clinical cases were independently scored by two clinical raters. Allocation masking cannot be verified from the retained audit trail and is not claimed in the corrected report.
- The implemented outcome ranges were 0–4 for diagnosis, 0–4 for investigation ordering, 0–6 for treatment planning, and 0–3 each for risk assessment and follow-up (20 points per case; 100 points overall).
- The case-platform completion-duration field was complete for all 174 participants: 44.1 (SD 26.1) minutes with assistance and 55.3 (SD 31.8) minutes with conventional resources. A distinct antecedent-survey duration field was not analysed.
- Assisted responses averaged 11,788 characters versus 1,781 with conventional resources (6.62-fold ratio), and answer length correlated with total score (Spearman rho=0.776). The corrected report therefore interprets the score as expert-rated written-response performance that may combine clinical-content quality, completeness, and AI-enabled text production, rather than clinical reasoning ability alone.
- The two-rater average for investigation ordering favoured conventional resources, but rater A and rater B produced opposite group-effect directions and single-rater reliability was low (ICC(2,1)=0.267). The report treats this as a hypothesis-generating signal, not a rater-invariant harmful effect.
- The exploratory AI-alone reference comprised five DeepSeek runs outside randomisation and was used descriptively only.
- Chinese Clinical Trial Registry: [ChiCTR2600120307](https://www.chictr.org.cn/hvshowproject.html?id=296940&v=1.0) (retrospectively registered 12 March 2026).

This repository is limited to the prospective randomised physician component of the broader registered study. The registry is retrospective and describes a broader two-stage design; the corrected article reports only the two-arm physician randomised comparison.

## Repository structure

```text
analysis/
  01_primary_outcome.py
  02_case_dimension.py
  03_mixed_effects.R
  04_exploratory_ai_reference.py
  07_interrater_reliability.py
  08_process_construct_validity.R

figures/
  Fig1_study_flow.py
  corrected_aggregate_figures.R

data/
  README.md
```

## Requirements

Python 3.10 or later:

```bash
pip install -r requirements.txt
```

R 4.3 or later for the reported Satterthwaite mixed-model tests and the main outcome and competency-profile figures:

```r
install.packages(c("lme4", "lmerTest", "ggplot2", "cowplot"))
```

## Data availability

Participant-level data, source records, recordings, and data dictionaries are not included in this repository and are not publicly posted. The registry states that requests may be directed to the corresponding author after publication; any request would require ethics, consent, privacy, and institutional review. Source records, identifiable responses, recordings, and the data dictionary will not be shared. Aggregate results supporting the manuscript are reported in the article and supplementary information. See [data/README.md](data/README.md) for the expected private input-file layout.

## Reproducibility scope

The repository contains illustrative scripts only for statistical and figure-construction procedures retained in the corrected report. It is not an independently executable replication package.

The current public snapshot has been audited against the final manuscript and supplement. No participant-level data or standalone aggregate-result CSV files are committed. The numerical constants in `figures/corrected_aggregate_figures.R` are the unrounded values underlying the rounded means, standard deviations, effect sizes, and confidence intervals displayed in Figures 2–3 and Table 2; they do not represent a separate public dataset.

`analysis/01_primary_outcome.py` implements the reported Welch primary mean comparison, rank-based sensitivity analysis, and fixed-seed participant bootstrap. `analysis/02_case_dimension.py` applies the reported 11-outcome Mann–Whitney/FDR family and fixed-seed effect-size bootstrap.

`analysis/03_mixed_effects.R` implements the supplementary raw-score and percentage-of-maximum linear mixed-effects models with Satterthwaite denominator degrees of freedom. Dimension maxima are 20, 20, 30, 15, and 15 points, so the raw interaction is not scale-neutral. The script also constructs the equal-weight composite used in the corrected sensitivity analysis.

`analysis/07_interrater_reliability.py` implements single-rater absolute-agreement ICC(2,1), participant-bootstrap intervals, grand-total limits of agreement, and the rater-specific investigation-ordering sensitivity analysis.

`analysis/08_process_construct_validity.R` implements the reported total-task-duration and answer-length summaries, score–length correlation, and the two exploratory answer-length-conditioned models. Those conditional coefficients are non-causal construct-validity diagnostics because answer length is a post-randomisation variable and plausible mediator.

`figures/corrected_aggregate_figures.R` reproduces the corrected Figure 2 and Figure 3 directly from the aggregate values reported in the article and does not require participant-level inputs.

Participant-level inputs and preprocessing objects from the independent rater files are not public. Running the participant-level analyses requires the non-public study inputs described in `data/README.md`.

## License

MIT License. See [LICENSE](LICENSE).
