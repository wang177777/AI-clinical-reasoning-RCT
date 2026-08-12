# Private data inputs

No participant-level data, source records, recordings, or data dictionary are included in this public repository or publicly posted. Any controlled request described by the trial registry remains subject to ethics, consent, privacy, and institutional review; source records, identifiable responses, recordings, and the data dictionary will not be shared.

The analysis scripts expect private study files in this directory, including:

- `avg1.pkl` — DeepSeek-assisted participant-level two-rater mean scores (n=87)
- `avg2.pkl` — conventional-resource participant-level two-rater mean scores (n=87)
- `avg_ds.pkl` — descriptive AI-alone scores (five runs)
- The three score objects use `grand_total`, `c1_total`–`c5_total`, `dx_total`, `exam_total`, `tx_total`, `risk_total`, and `fu_total` where applicable.
- `mixed_model_long.csv` — private long-format score table used by the reported R mixed model; required columns are `participant`, `group`, `dimension`, and `score`
- `rater_A_scores.xlsx` and `rater_B_scores.xlsx` — standardised private rater inputs with aligned `participant` and `group` columns and the score columns `grand_total`, `c1_total`–`c5_total`, `dx_total`, `exam_total`, `tx_total`, `risk_total`, and `fu_total`; the retained audit trail does not verify allocation masking
- `process_construct_validity.csv` — private participant-level process table with columns `participant`, `group`, `total_score`, `completion_time_s`, and `answer_chars`; `completion_time_s` is the case-platform completion-duration field (the distinct antecedent-survey duration is excluded), and `answer_chars` uses the five concatenated texts retained in the final rater A workbook, including the identical 140-character label/separator template in every record

These inputs must not be committed to the public repository.

Aggregate results supporting the manuscript are reported in the article and supplementary information.
