"""Reported case- and competency-dimension comparisons."""

from pathlib import Path

import numpy as np
import pandas as pd
from scipy.stats import mannwhitneyu
from statsmodels.stats.multitest import multipletests


DATA = Path(__file__).resolve().parents[1] / "data"
avg1 = pd.read_pickle(DATA / "avg1.pkl")
avg2 = pd.read_pickle(DATA / "avg2.pkl")

outcomes = [("Grand total", "grand_total")]
outcomes += [
    (label, f"c{index}_total")
    for index, label in enumerate(
        [
            "Pneumonia",
            "Iron-deficiency anaemia",
            "Acute gout",
            "Appendicitis",
            "Paediatric diarrhoea",
        ],
        start=1,
    )
]
outcomes += [
    ("Diagnosis", "dx_total"),
    ("Investigation ordering", "exam_total"),
    ("Treatment planning", "tx_total"),
    ("Risk assessment", "risk_total"),
    ("Follow-up", "fu_total"),
]


def pooled_d(group1: np.ndarray, group2: np.ndarray) -> float:
    n1, n2 = len(group1), len(group2)
    pooled_sd = np.sqrt(
        ((n1 - 1) * group1.var(ddof=1) + (n2 - 1) * group2.var(ddof=1))
        / (n1 + n2 - 2)
    )
    return (group1.mean() - group2.mean()) / pooled_sd


rows = []
raw_p = []
for label, column in outcomes:
    group1 = avg1[column].dropna().to_numpy(dtype=float)
    group2 = avg2[column].dropna().to_numpy(dtype=float)
    if (len(group1), len(group2)) != (87, 87):
        raise ValueError(f"{label}: expected 87 observations per arm")

    difference = group1.mean() - group2.mean()
    effect = pooled_d(group1, group2)
    p_value = mannwhitneyu(group1, group2, alternative="two-sided").pvalue
    raw_p.append(p_value)

    # Reinitialising the fixed generator for each outcome matches the reported
    # participant-level bootstrap convention.
    rng = np.random.default_rng(20260812)
    bootstrap_d = np.empty(10_000)
    for iteration in range(10_000):
        sample1 = rng.choice(group1, size=len(group1), replace=True)
        sample2 = rng.choice(group2, size=len(group2), replace=True)
        bootstrap_d[iteration] = pooled_d(sample1, sample2)

    ci_low, ci_high = np.quantile(bootstrap_d, [0.025, 0.975])
    rows.append(
        {
            "outcome": label,
            "difference": difference,
            "d": effect,
            "d_ci_low": ci_low,
            "d_ci_high": ci_high,
            "raw_p": p_value,
        }
    )

fdr_p = multipletests(raw_p, method="fdr_bh")[1]

print("CASE- AND DIMENSION-LEVEL RESULTS")
for row, adjusted_p in zip(rows, fdr_p):
    print(
        f"  {row['outcome']:28s} "
        f"difference={row['difference']:+.1f}  "
        f"d={row['d']:+.2f} ({row['d_ci_low']:+.2f} to {row['d_ci_high']:+.2f})  "
        f"raw P={row['raw_p']:.2e}  FDR P={adjusted_p:.2e}"
    )

print(
    "\nThe primary-outcome inference in the manuscript is the unadjusted Welch "
    "test. FDR values above are the descriptive 11-outcome Mann–Whitney family."
)
