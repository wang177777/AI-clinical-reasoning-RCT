#!/usr/bin/env Rscript

# Supporting process outcomes and non-causal construct-validity diagnostics.
# Requires the private participant-level input described in data/README.md.

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[1]) else "analysis/08_process_construct_validity.R"
repo_root <- dirname(dirname(normalizePath(script_path, mustWork = FALSE)))
input_path <- file.path(repo_root, "data", "process_construct_validity.csv")
if (!file.exists(input_path)) {
  stop("Missing private input: ", input_path)
}

dat <- read.csv(input_path, stringsAsFactors = FALSE)
required <- c("participant", "group", "total_score", "completion_time_s", "answer_chars")
missing_columns <- setdiff(required, names(dat))
if (length(missing_columns) > 0) {
  stop("Missing required columns: ", paste(missing_columns, collapse = ", "))
}

dat$group <- factor(dat$group, levels = c("Conventional", "Assisted"))
if (nrow(dat) != 174 || any(table(dat$group) != c(87, 87))) {
  stop("Expected 174 participants allocated 87:87.")
}
if (anyNA(dat[required]) || any(dat$completion_time_s <= 0) || any(dat$answer_chars <= 0)) {
  stop("Process input contains missing or non-positive values.")
}

summarise_by_group <- function(variable) {
  aggregate(
    dat[[variable]],
    list(group = dat$group),
    function(x) c(n = length(x), mean = mean(x), sd = sd(x),
                  median = median(x), iqr = IQR(x))
  )
}

cat("TOTAL TASK DURATION, SECONDS\n")
print(summarise_by_group("completion_time_s"))
print(t.test(completion_time_s ~ group, data = dat, var.equal = FALSE))
print(wilcox.test(completion_time_s ~ group, data = dat, exact = FALSE))
duration_log_model <- lm(log(completion_time_s) ~ group, data = dat)
cat("Geometric-mean ratio, Assisted versus Conventional\n")
print(exp(c(
  estimate = coef(duration_log_model)["groupAssisted"],
  confint(duration_log_model)["groupAssisted", ]
)))

cat("\nANSWER LENGTH, UNICODE CHARACTERS\n")
print(summarise_by_group("answer_chars"))
print(t.test(answer_chars ~ group, data = dat, var.equal = FALSE))
print(wilcox.test(answer_chars ~ group, data = dat, exact = FALSE))
cat("Mean-length ratio, Assisted versus Conventional\n")
print(with(dat, mean(answer_chars[group == "Assisted"]) /
  mean(answer_chars[group == "Conventional"])))
print(cor.test(dat$total_score, dat$answer_chars, method = "spearman", exact = FALSE))

cat("\nNON-CAUSAL ANSWER-LENGTH-CONDITIONED MODELS\n")
full_model <- lm(total_score ~ group + log1p(answer_chars), data = dat)
print(coef(summary(full_model))["groupAssisted", ])
print(confint(full_model)["groupAssisted", ])

support_low <- max(tapply(dat$answer_chars, dat$group, min))
support_high <- min(tapply(dat$answer_chars, dat$group, max))
support_data <- subset(
  dat,
  answer_chars >= support_low & answer_chars <= support_high
)
support_model <- lm(
  total_score ~ group + log1p(answer_chars),
  data = support_data
)
cat("Common support:", support_low, "to", support_high, "characters; n=", nrow(support_data), "\n")
print(table(support_data$group))
print(coef(summary(support_model))["groupAssisted", ])
print(confint(support_model)["groupAssisted", ])

cat(
  "\nINTERPRETATION NOTE\n",
  "Answer length is post-randomisation and may mediate the intervention effect. ",
  "Conditioning on it can block mediation or induce collider bias. These group ",
  "coefficients do not estimate treatment effects and their signs must not be ",
  "interpreted as evidence that DeepSeek lowered actual performance.\n",
  sep = ""
)
