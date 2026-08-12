#!/usr/bin/env Rscript

# Reported group-by-dimension linear mixed-effects analysis.
# Participant-level inputs are private and are not included in this repository.

suppressPackageStartupMessages({
  library(lme4)
  library(lmerTest)
})

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[1]) else "analysis/03_mixed_effects.R"
repo_root <- dirname(dirname(normalizePath(script_path, mustWork = FALSE)))
input_file <- file.path(repo_root, "data", "mixed_model_long.csv")
if (!file.exists(input_file)) {
  stop(
    "Missing private input: ", input_file,
    ". See data/README.md for the required schema."
  )
}

dat <- read.csv(input_file, stringsAsFactors = FALSE, check.names = FALSE)
required_columns <- c("participant", "group", "dimension", "score")
missing_columns <- setdiff(required_columns, names(dat))
if (length(missing_columns) > 0) {
  stop("Missing required columns: ", paste(missing_columns, collapse = ", "))
}

dat$participant <- factor(dat$participant)
dat$group <- factor(dat$group, levels = c("Conventional", "AI-assisted"))
dat$dimension[dat$dimension %in% c("Examination", "Investigation", "Examination ordering")] <- "Investigation ordering"
dat$dimension[dat$dimension %in% c("Treatment", "Management")] <- "Treatment planning"
dat$dimension[dat$dimension %in% c("Risk", "Risk Assessment")] <- "Risk assessment"
dat$dimension[dat$dimension %in% c("Followup", "Follow up")] <- "Follow-up"
dat$dimension <- factor(
  dat$dimension,
  levels = c("Diagnosis", "Investigation ordering", "Treatment planning", "Risk assessment", "Follow-up")
)

if (anyNA(dat[, required_columns])) {
  stop("The mixed-model input contains missing required values.")
}

# Omnibus tests reported in the manuscript. Sum-to-zero contrasts make the
# Type III main-effect tests marginal across the other factor.
contrasts(dat$group) <- contr.sum(2)
contrasts(dat$dimension) <- contr.sum(5)
fit_omnibus <- lmer(
  score ~ group * dimension + (1 | participant),
  data = dat,
  REML = TRUE
)

cat("OMNIBUS TESTS (Type III; Satterthwaite denominator df)\n")
print(anova(fit_omnibus, type = 3, ddf = "Satterthwaite"))

# Reference-level parameterisation for the dimension-specific coefficients
# described in the manuscript, using Conventional and Diagnosis as references.
contrasts(dat$group) <- contr.treatment(2, base = 1)
contrasts(dat$dimension) <- contr.treatment(5, base = 1)
fit_coefficients <- lmer(
  score ~ group * dimension + (1 | participant),
  data = dat,
  REML = TRUE
)

cat("\nREFERENCE-LEVEL FIXED-EFFECT COEFFICIENTS\n")
print(summary(fit_coefficients)$coefficients)

cat("\nRANDOM-EFFECT AND RESIDUAL VARIANCE\n")
print(VarCorr(fit_coefficients), comp = c("Variance", "Std.Dev."))

cat("\nINTERPRETATION NOTE\n")
cat(
  "Dimension maxima are 20, 20, 30, 15, and 15 for Diagnosis, Investigation, ",
  "Treatment, Risk Assessment, and Follow-up, respectively. The raw-score ",
  "interaction is therefore supplementary and must not be interpreted as a ",
  "scale-neutral comparison of relative benefit.\n",
  sep = ""
)

# Scale-neutral repeated-measures interaction.
dimension_max <- c(
  "Diagnosis" = 20,
  "Investigation ordering" = 20,
  "Treatment planning" = 30,
  "Risk assessment" = 15,
  "Follow-up" = 15
)
dat$score_pct <- 100 * dat$score / unname(dimension_max[as.character(dat$dimension)])
if (anyNA(dat$score_pct)) stop("Unrecognised dimension while applying theoretical maxima.")

contrasts(dat$group) <- contr.sum(2)
contrasts(dat$dimension) <- contr.sum(5)
fit_normalized <- lmer(
  score_pct ~ group * dimension + (1 | participant),
  data = dat,
  REML = TRUE
)
cat("\nPERCENTAGE-OF-MAXIMUM OMNIBUS TESTS\n")
print(anova(fit_normalized, type = 3, ddf = "Satterthwaite"))

# Equal-weight participant-level composite: arithmetic mean of the five
# percentage-of-maximum dimension scores.
equal_weight <- aggregate(score_pct ~ participant + group, data = dat, FUN = mean)
names(equal_weight)[3] <- "equal_weight_pct"
cat("\nEQUAL-WEIGHT NORMALIZED COMPOSITE\n")
print(aggregate(equal_weight_pct ~ group, data = equal_weight,
                FUN = function(x) c(n = length(x), mean = mean(x), sd = sd(x))))
print(t.test(equal_weight_pct ~ group, data = equal_weight, var.equal = FALSE))
