"""Figure 1: prospective RCT CONSORT participant flow."""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch


OUTPUT = Path("output")
OUTPUT.mkdir(exist_ok=True)


def box(ax, x, y, width, height, text, *, face="white", dashed=False, bold=False, size=10):
    patch = FancyBboxPatch(
        (x, y),
        width,
        height,
        boxstyle="round,pad=0.012,rounding_size=0.018",
        facecolor=face,
        edgecolor="#30363D",
        linewidth=1.4,
        linestyle=(0, (4, 3)) if dashed else "solid",
    )
    ax.add_patch(patch)
    ax.text(
        x + width / 2,
        y + height / 2,
        text,
        ha="center",
        va="center",
        fontsize=size,
        fontweight="bold" if bold else "normal",
        linespacing=1.25,
    )


def arrow(ax, start, end):
    ax.add_patch(
        FancyArrowPatch(
            start,
            end,
            arrowstyle="-|>",
            mutation_scale=15,
            linewidth=1.5,
            color="#343A40",
            connectionstyle="arc3,rad=0",
        )
    )


def make_figure():
    fig, ax = plt.subplots(figsize=(7.2, 8.6), dpi=300)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")

    box(ax, 0.18, 0.86, 0.51, 0.09,
        "Platform records assessed before randomization\n(n=226)",
        face="#EEF3FB", bold=True)
    box(ax, 0.74, 0.85, 0.24, 0.11,
        "Excluded before\nrandomization (n=52)\nScreening, testing, invalid,\nor duplicate records",
        face="#FAFAFA", dashed=True, size=8.4)
    arrow(ax, (0.69, 0.905), (0.74, 0.905))
    arrow(ax, (0.435, 0.86), (0.435, 0.78))

    box(ax, 0.29, 0.70, 0.29, 0.08, "Randomized 1:1\n(n=174)", face="#FCECEC", bold=True)
    ax.plot([0.435, 0.435], [0.70, 0.65], color="#343A40", linewidth=1.5)
    ax.plot([0.25, 0.75], [0.65, 0.65], color="#343A40", linewidth=1.5)
    arrow(ax, (0.25, 0.65), (0.25, 0.59))
    arrow(ax, (0.75, 0.65), (0.75, 0.59))

    box(ax, 0.055, 0.50, 0.39, 0.09, "Allocated to DeepSeek assistance\n(n=87)",
        face="#E8F0FC", bold=True)
    box(ax, 0.555, 0.50, 0.39, 0.09, "Allocated to conventional resources\n(n=87)",
        face="#FCECEC", bold=True)
    arrow(ax, (0.25, 0.50), (0.25, 0.43))
    arrow(ax, (0.75, 0.50), (0.75, 0.43))

    detail = "Received assigned condition (n=87)\n\nCompleted five-case assessment (n=87)\n\nOutcome data available (n=87)"
    box(ax, 0.055, 0.27, 0.39, 0.16, detail, size=9.5)
    box(ax, 0.555, 0.27, 0.39, 0.16, detail, size=9.5)

    arrow(ax, (0.25, 0.27), (0.25, 0.18))
    arrow(ax, (0.75, 0.27), (0.75, 0.18))
    box(ax, 0.08, 0.10, 0.34, 0.08, "Included in ITT analysis\n(n=87)", face="#F7F7F7", bold=True)
    box(ax, 0.58, 0.10, 0.34, 0.08, "Included in ITT analysis\n(n=87)", face="#F7F7F7", bold=True)
    ax.text(0.05, 0.045, "All outcome responses were independently scored by two clinical raters.", fontsize=7.7)
    ax.text(0.05, 0.015, "ITT, intention to treat.", fontsize=8.5)

    for suffix in ("png", "tiff"):
        save_options = {"pil_kwargs": {"compression": "tiff_lzw"}} if suffix == "tiff" else {}
        fig.savefig(
            OUTPUT / f"Figure1_CONSORT_Flow_Corrected.{suffix}",
            bbox_inches="tight",
            facecolor="white",
            dpi=300,
            **save_options,
        )
    plt.close(fig)


if __name__ == "__main__":
    make_figure()
