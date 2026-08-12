"""Inter-rater ICC(2,1), agreement summaries, and investigation-ordering sensitivity."""

from pathlib import Path

import numpy as np
import pandas as pd


DATA = Path(__file__).resolve().parents[1] / "data"
rater_a = pd.read_excel(DATA / "rater_A_scores.xlsx")
rater_b = pd.read_excel(DATA / "rater_B_scores.xlsx")

outcomes = [
    ("Grand total", "grand_total"),
    ("Case 1: Pneumonia", "c1_total"),
    ("Case 2: Anemia", "c2_total"),
    ("Case 3: Gout", "c3_total"),
    ("Case 4: Appendicitis", "c4_total"),
    ("Case 5: Diarrhea", "c5_total"),
    ("Diagnosis", "dx_total"),
    ("Investigation ordering", "exam_total"),
    ("Treatment planning", "tx_total"),
    ("Risk assessment", "risk_total"),
    ("Follow-up", "fu_total"),
]
required = {"participant", "group"} | {column for _, column in outcomes}
for label, frame in (("rater A", rater_a), ("rater B", rater_b)):
    missing = sorted(required - set(frame.columns))
    if missing:
        raise ValueError(f"{label} input is missing columns: {missing}")
if len(rater_a) != 174 or len(rater_b) != 174:
    raise ValueError("Expected 174 rows in each standardised rater input.")
if not rater_a["participant"].equals(rater_b["participant"]):
    raise ValueError("Rater files are not aligned by participant.")
if not rater_a["group"].equals(rater_b["group"]):
    raise ValueError("Group labels differ between rater files.")


def icc_2_1(values: np.ndarray) -> float:
    """Two-way random-effects, absolute-agreement, single-rater ICC."""
    n_targets, n_raters = values.shape
    grand_mean = values.mean()
    target_means = values.mean(axis=1)
    rater_means = values.mean(axis=0)
    ms_targets = n_raters * np.square(target_means - grand_mean).sum() / (n_targets - 1)
    ms_raters = n_targets * np.square(rater_means - grand_mean).sum() / (n_raters - 1)
    residual = values - target_means[:, None] - rater_means[None, :] + grand_mean
    ms_error = np.square(residual).sum() / ((n_targets - 1) * (n_raters - 1))
    return (ms_targets - ms_error) / (
        ms_targets
        + (n_raters - 1) * ms_error
        + n_raters * (ms_raters - ms_error) / n_targets
    )


print("ICC(2,1): SINGLE-RATER ABSOLUTE AGREEMENT")
for outcome_index, (label, column) in enumerate(outcomes):
    pair = np.column_stack(
        [rater_a[column].to_numpy(dtype=float), rater_b[column].to_numpy(dtype=float)]
    )
    estimate = icc_2_1(pair)
    rng = np.random.default_rng(20260812 + outcome_index)
    bootstrap = np.empty(5_000)
    for iteration in range(5_000):
        indices = rng.integers(0, len(pair), size=len(pair))
        bootstrap[iteration] = icc_2_1(pair[indices])
    low, high = np.quantile(bootstrap, [0.025, 0.975])
    difference = pair[:, 0] - pair[:, 1]
    print(
        f"  {label:28s} ICC={estimate:.3f} ({low:.3f} to {high:.3f}); "
        f"mean A-B={difference.mean():+.2f}; SD={difference.std(ddof=1):.2f}"
    )

grand_difference = (
    rater_a["grand_total"].to_numpy(dtype=float)
    - rater_b["grand_total"].to_numpy(dtype=float)
)
agreement_mean = grand_difference.mean()
agreement_sd = grand_difference.std(ddof=1)
print(
    "\nGRAND-TOTAL AGREEMENT\n"
    f"  Mean A-B={agreement_mean:.2f}; 95% limits of agreement="
    f"{agreement_mean - 1.96 * agreement_sd:.1f} to "
    f"{agreement_mean + 1.96 * agreement_sd:.1f}"
)


def pooled_d(group1: np.ndarray, group2: np.ndarray) -> float:
    n1, n2 = len(group1), len(group2)
    pooled_sd = np.sqrt(
        ((n1 - 1) * group1.var(ddof=1) + (n2 - 1) * group2.var(ddof=1))
        / (n1 + n2 - 2)
    )
    return (group1.mean() - group2.mean()) / pooled_sd


print("\nINVESTIGATION-ORDERING GROUP EFFECT BY RATER")
assisted = rater_a["group"].eq("Assisted").to_numpy()
if assisted.sum() != 87:
    raise ValueError("Expected group labels 'Assisted' and 'Conventional' with 87 rows each.")
for label, frame in (("Rater A", rater_a), ("Rater B", rater_b)):
    group1 = frame.loc[assisted, "exam_total"].to_numpy(dtype=float)
    group2 = frame.loc[~assisted, "exam_total"].to_numpy(dtype=float)
    effect = pooled_d(group1, group2)
    rng = np.random.default_rng(20260812)
    bootstrap = np.empty(10_000)
    for iteration in range(10_000):
        sample1 = rng.choice(group1, len(group1), replace=True)
        sample2 = rng.choice(group2, len(group2), replace=True)
        bootstrap[iteration] = pooled_d(sample1, sample2)
    low, high = np.quantile(bootstrap, [0.025, 0.975])
    print(
        f"  {label}: assisted={group1.mean():.2f}; conventional={group2.mean():.2f}; "
        f"difference={group1.mean() - group2.mean():+.2f}; "
        f"d={effect:+.2f} ({low:+.2f} to {high:+.2f})"
    )
