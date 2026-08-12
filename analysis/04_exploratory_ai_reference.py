"""Descriptive AI-alone reference reported in Supplementary Table S7."""

from pathlib import Path

import pandas as pd


data_dir = Path(__file__).resolve().parents[1] / "data"
ai_runs = pd.read_pickle(data_dir / "avg_ds.pkl")
if len(ai_runs) != 5:
    raise ValueError("The descriptive AI-alone reference must contain five runs.")

totals = ai_runs["grand_total"].to_numpy(dtype=float)
print("AI-ALONE DESCRIPTIVE REFERENCE (not part of randomisation or inference)")
print("  Independent run totals:", "; ".join(f"{value:.1f}" for value in totals))
print(
    f"  Mean (SD)={totals.mean():.1f} ({totals.std(ddof=1):.1f}); "
    f"coefficient of variation={100 * totals.std(ddof=1) / totals.mean():.1f}%"
)

cases = [
    ("Pneumonia", "c1_total"),
    ("Iron-deficiency anaemia", "c2_total"),
    ("Acute gout", "c3_total"),
    ("Acute appendicitis", "c4_total"),
    ("Paediatric diarrhoea", "c5_total"),
]
for label, column in cases:
    values = ai_runs[column].to_numpy(dtype=float)
    print(f"  {label:26s} mean (SD)={values.mean():.1f} ({values.std(ddof=1):.1f})")
