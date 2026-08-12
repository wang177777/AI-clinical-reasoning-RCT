#!/usr/bin/env Rscript

# Corrected Figure 2 and Figure 3 from the aggregate values reported in the
# article. No participant-level data are read by this script.

suppressPackageStartupMessages({
  library(ggplot2)
  library(cowplot)
})

dir.create("output", showWarnings = FALSE)
blue <- "#4C78A8"; orange <- "#E28E2C"; dark <- "#263238"; grid_col <- "#E5E5E5"
n <- 87

theme_trial <- theme_classic(base_size = 10) + theme(
  axis.text = element_text(colour = dark), axis.title = element_text(colour = dark),
  legend.title = element_blank(), legend.position = "bottom",
  plot.tag = element_text(face = "bold", size = 13)
)

# Figure 2
primary <- data.frame(
  group = factor(c("DeepSeek-assisted\n(n=87)", "Conventional resources\n(n=87)"),
    levels = c("DeepSeek-assisted\n(n=87)", "Conventional resources\n(n=87)")),
  mean = c(77.4885057471, 68.1666666667),
  sd = c(9.8181064968, 10.4607979893)
)
primary$err <- 1.96 * primary$sd / sqrt(n)

f2a <- ggplot(primary, aes(group, mean, colour = group)) +
  geom_linerange(aes(ymin = mean - sd, ymax = mean + sd), linewidth = 7, alpha = 0.18) +
  geom_errorbar(aes(ymin = mean - err, ymax = mean + err), width = 0.10, linewidth = 0.8) +
  geom_point(size = 3) +
  geom_text(aes(label = sprintf("%.1f", mean), y = mean + err + 2.2), fontface = "bold") +
  scale_colour_manual(values = c(blue, orange)) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20), expand = expansion(mult = c(0, 0.01))) +
  labs(x = NULL, y = "Expert-scored total response score (0–100)", tag = "a") +
  theme_trial + theme(legend.position = "none", panel.grid.major.y = element_line(colour = grid_col, linewidth = 0.35))

effect <- data.frame(delta = 9.3, lo = 6.3, hi = 12.3, y = 1.01)
f2b <- ggplot(effect, aes(delta, y)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "#888888") +
  geom_segment(aes(x = lo, xend = hi, y = y, yend = y), linewidth = 0.8, colour = dark) +
  geom_segment(aes(x = lo, xend = lo, y = y - 0.001, yend = y + 0.001), linewidth = 0.8, colour = dark) +
  geom_segment(aes(x = hi, xend = hi, y = y - 0.001, yend = y + 0.001), linewidth = 0.8, colour = dark) +
  geom_point(shape = 18, size = 4, colour = dark) +
  annotate("text", x = 9.3, y = 1.055, label = "9.3 (6.3 to 12.3)", fontface = "bold") +
  scale_x_continuous(limits = c(-2, 14), breaks = seq(0, 14, 2)) +
  scale_y_continuous(NULL, breaks = NULL, limits = c(0.95, 1.09), expand = expansion(mult = 0)) +
  labs(x = "Mean difference (95% bootstrap CI), points", tag = "b") +
  theme_trial + theme(panel.grid.major.x = element_line(colour = grid_col, linewidth = 0.35), axis.line.y = element_blank())

figure2 <- plot_grid(f2a, f2b, nrow = 1, rel_widths = c(1.1, 1), align = "h", axis = "tb")
ggsave("output/Figure2_Primary_Outcome_Corrected.png", figure2, width = 8, height = 4.4, dpi = 300, bg = "white")
ggsave("output/Figure2_Primary_Outcome_Corrected.tiff", figure2, width = 8, height = 4.4, dpi = 300, compression = "lzw", bg = "white")

# Figure 3
dims <- data.frame(
  dimension = factor(rep(c("Diagnosis", "Investigation ordering", "Treatment planning", "Risk assessment", "Follow-up"), 2),
    levels = rev(c("Diagnosis", "Investigation ordering", "Treatment planning", "Risk assessment", "Follow-up"))),
  group = factor(rep(c("DeepSeek-assisted", "Conventional resources"), each = 5),
    levels = c("DeepSeek-assisted", "Conventional resources")),
  mean = c(13.5172413793, 13.8160919540, 25.7758620690, 11.6436781609, 12.7356321839,
           12.8103448276, 14.7471264368, 18.6609195402, 10.2241379310, 11.7241379310),
  sd = c(1.6608492432, 1.4569699015, 3.5932418969, 2.6467488239, 2.3138097554,
         2.6569800344, 1.5170993652, 3.7170992792, 3.3582236970, 2.7971732208),
  max = rep(c(20, 20, 30, 15, 15), 2)
)
dims$pct <- 100 * dims$mean / dims$max
dims$err <- 100 * 1.96 * dims$sd / sqrt(n) / dims$max

f3a <- ggplot(dims, aes(pct, dimension, colour = group, shape = group)) +
  geom_errorbarh(aes(xmin = pct - err, xmax = pct + err), position = position_dodge(width = 0.42), height = 0.12) +
  geom_point(position = position_dodge(width = 0.42), size = 2.4) +
  scale_colour_manual(values = c(blue, orange)) +
  scale_x_continuous(limits = c(55, 102), breaks = seq(60, 100, 10)) +
  labs(x = "Score (% of implemented maximum), mean (95% CI)", y = NULL, tag = "a") +
  theme_trial + theme(panel.grid.major.x = element_line(colour = grid_col, linewidth = 0.35))

effects <- data.frame(
  dimension = factor(c("Diagnosis", "Investigation ordering", "Treatment planning", "Risk assessment", "Follow-up"),
    levels = rev(c("Diagnosis", "Investigation ordering", "Treatment planning", "Risk assessment", "Follow-up"))),
  d = c(0.3190510388, -0.6259734868, 1.9462625285, 0.4695043470, 0.3940537083),
  lo = c(0.0226180987, -0.9319131505, 1.5492632287, 0.1718421707, 0.0902208652),
  hi = c(0.6349090488, -0.3396461086, 2.4407428728, 0.7895080961, 0.7026274330)
)
f3b <- ggplot(effects, aes(d, dimension)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "#888888") +
  geom_errorbarh(aes(xmin = lo, xmax = hi), height = 0.12, colour = dark) +
  geom_point(shape = 18, size = 3.1, colour = dark) +
  scale_x_continuous(limits = c(-1.2, 2.6), breaks = seq(-1, 2.5, 0.5)) +
  labs(x = "Cohen's d (95% bootstrap CI)", y = NULL, tag = "b") +
  theme_trial + theme(legend.position = "none", panel.grid.major.x = element_line(colour = grid_col, linewidth = 0.35))

cases <- data.frame(
  case = factor(rep(c("Pneumonia", "Anaemia", "Gout", "Appendicitis", "Paediatric\ndiarrhoea"), 2),
    levels = c("Pneumonia", "Anaemia", "Gout", "Appendicitis", "Paediatric\ndiarrhoea")),
  group = factor(rep(c("DeepSeek-assisted", "Conventional resources"), each = 5),
    levels = c("DeepSeek-assisted", "Conventional resources")),
  mean = c(15.3735632184, 15.5747126437, 14.3160919540, 16.5632183908, 15.6609195402,
           13.4425287356, 13.1954022989, 12.0689655172, 15.7758620690, 13.6839080460),
  sd = c(2.5337470997, 2.7781631204, 2.4401140634, 1.8328472540, 2.5191063533,
         2.7134733677, 2.8847597960, 3.3298966513, 2.3411866161, 3.6153057564)
)
cases$err <- 1.96 * cases$sd / sqrt(n)
f3c <- ggplot(cases, aes(case, mean, colour = group, shape = group)) +
  geom_errorbar(aes(ymin = mean - err, ymax = mean + err), position = position_dodge(width = 0.35), width = 0.10) +
  geom_point(position = position_dodge(width = 0.35), size = 2.4) +
  scale_colour_manual(values = c(blue, orange)) +
  scale_y_continuous(limits = c(0, 20), breaks = seq(0, 20, 5), expand = expansion(mult = c(0, 0.01))) +
  labs(x = NULL, y = "Case score (0–20), mean (95% CI)", tag = "c") +
  theme_trial + theme(panel.grid.major.y = element_line(colour = grid_col, linewidth = 0.35))

top <- plot_grid(f3a, f3b, nrow = 1, align = "h", axis = "tb")
figure3 <- plot_grid(top, f3c, ncol = 1, rel_heights = c(1, 1.05), align = "v")
ggsave("output/Figure3_Dimension_and_Case_Effects_Corrected.png", figure3, width = 10, height = 7.7, dpi = 300, bg = "white")
ggsave("output/Figure3_Dimension_and_Case_Effects_Corrected.tiff", figure3, width = 10, height = 7.7, dpi = 300, compression = "lzw", bg = "white")
