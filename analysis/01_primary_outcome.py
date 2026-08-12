"""Primary outcome: reported randomised comparison and bootstrap confidence intervals."""
from pathlib import Path

import pandas as pd, numpy as np
from scipy import stats
from scipy.stats import mannwhitneyu, shapiro

data_dir = Path(__file__).resolve().parents[1] / "data"
avg1 = pd.read_pickle(data_dir / 'avg1.pkl')
avg2 = pd.read_pickle(data_dir / 'avg2.pkl')
g1, g2 = avg1['grand_total'].dropna(), avg2['grand_total'].dropna()
N1, N2 = len(g1), len(g2)

print("DESCRIPTIVE STATISTICS")
for label, values in [('DeepSeek-Assisted', g1), ('Conventional Resources', g2)]:
    print(f"  {label}: {values.mean():.1f} ± {values.std(ddof=1):.1f}, "
          f"median={values.median():.1f}, IQR=[{values.quantile(.25):.1f}, {values.quantile(.75):.1f}]")

print("\nNORMALITY (Shapiro-Wilk)")
for label, d in [('G1', g1), ('G2', g2)]:
    w, p = shapiro(d)
    print(f"  {label}: W={w:.3f}, P={p:.3f}")

print("\nPRIMARY ANALYSIS")
U, p_mw = mannwhitneyu(g1, g2, alternative='two-sided')
welch = stats.ttest_ind(g1, g2, equal_var=False)
t, p_welch = welch.statistic, welch.pvalue
delta = g1.mean() - g2.mean()
ps = np.sqrt((g1.std(ddof=1)**2 + g2.std(ddof=1)**2) / 2)
d = delta / ps

rng = np.random.default_rng(20260812)
n_boot = 10_000
boot_delta = np.empty(n_boot)
boot_d = np.empty(n_boot)
g1_array, g2_array = g1.to_numpy(), g2.to_numpy()
for i in range(n_boot):
    b1 = rng.choice(g1_array, size=N1, replace=True)
    b2 = rng.choice(g2_array, size=N2, replace=True)
    boot_delta[i] = b1.mean() - b2.mean()
    boot_ps = np.sqrt((b1.std(ddof=1)**2 + b2.std(ddof=1)**2) / 2)
    boot_d[i] = boot_delta[i] / boot_ps

delta_ci = np.quantile(boot_delta, [0.025, 0.975])
d_ci = np.quantile(boot_d, [0.025, 0.975])

print(f"  Welch t={t:.2f}, df={welch.df:.1f}, P={p_welch:.2e} (primary mean comparison)")
print(f"  Mann-Whitney U={U:.1f}, P={p_mw:.2e} (rank-based sensitivity)")
print(f"  Δ={delta:.1f} [{delta_ci[0]:.1f}, {delta_ci[1]:.1f}] (10,000-resample bootstrap)")
print(f"  Cohen's d={d:.2f} [{d_ci[0]:.2f}, {d_ci[1]:.2f}] (10,000-resample bootstrap)")
