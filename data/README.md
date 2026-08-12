# Private analysis inputs

No participant-level data, source records, recordings, interaction logs, standalone aggregate-result data files, or data dictionary are included in this public repository.

The analysis scripts use private study files with the following schemas:

- `avg1.pkl`: DeepSeek-assisted participant-level 2-rater mean scores (n=87)
- `avg2.pkl`: conventional-resource participant-level 2-rater mean scores (n=87)
- Score columns: `grand_total`, `c1_total`-`c5_total`, `dx_total`, `exam_total`, `tx_total`, `risk_total`, and `fu_total`
- `mixed_model_long.csv`: `participant`, `group`, `dimension`, and `score`
- `rater_A_scores.xlsx` and `rater_B_scores.xlsx`: aligned `participant`, `group`, and score columns
- `process_construct_validity.csv`: `participant`, `group`, `total_score`, `completion_time_s`, and `answer_chars`

These inputs must not be committed to the public repository. Aggregate findings are reported in the manuscript and multimedia appendix.
