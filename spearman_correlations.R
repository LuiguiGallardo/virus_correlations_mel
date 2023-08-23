#!/usr/bin/env Rscript
## Purpose of script: Spearman correlations
## Date created: 23.08.2023
## Author: luigui gallardo-becerra (bfllg77@gmail.com)
# Packages required
# install.packages("Hmisc")
# install.packages("dplyr")
# install.packages("ggplot2")
# install.packages("reshape")
# install.packages("rlist")
# install.packages("igraph")
# install.packages("ggpubr")
# install.packages("optparse")
library(Hmisc)
library(dplyr)
library(ggplot2)
library(reshape2)
library(rlist)
library(igraph)
library(ggpubr)
library(optparse)

# Parameters definition
option_list <- list(
    make_option(c("-i", "--input"),
        default = NULL,
        help = "Input file"
    ),
    make_option(c("-o", "--output"),
        default = "correlations_output",
        help = "Output folder name [default=%default]"
    ),
    make_option(c("-p", "--pvalue"),
        default = 0.05,
        help = "P-value cutoff [default= %default]"
    ),
    make_option(c("-r", "--rvalue"),
        default = 0.4,
        help = "Spearman's R-value cutoff [default= %default]"
    )
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Error message if no arguments provided
if (is.null(opt$input)) {
    print_help(opt_parser)
    stop("At least one argument must be supplied (input file).n", call. = FALSE)
}

# Data input
table <- read.delim(
    file = opt$input,
    header = TRUE,
    row.names = 1
)
table_transposed <- t(table)

# Output folder creation
dir.create(file.path(opt$output), showWarnings = FALSE)

# Correlation matrix
res_cor <- rcorr(t(table_transposed), type = "spearman")
matrix_cor <- res_cor$r # This is the R value matrix filter
matrix_cor.p <- res_cor$P # This is the p-value matrix filter

# Filter of R and p values
matrix_cor[which(matrix_cor >= (-opt$rvalue) & matrix_cor <= opt$rvalue)] <- 0 # Filter of R (positive and negative)
matrix_cor[which(matrix_cor.p > opt$pvalue)] <- 0 # Filter of p-value

# Reshape the correlation matrix
melted_cormat <- melt(matrix_cor)

# Final filter: remove zeros, self-correlations
final_matrix <- melted_cormat %>%
    filter(value != 0) %>%
    filter(Var1 != Var2) %>%
    filter(grepl("k__", Var1)) %>%
    filter(!grepl("k__", Var2))

# Create output table
write.table(final_matrix,
    file = paste0(opt$output, "/", opt$output, "_results.tsv"),
    sep = "\t",
    row.names = FALSE
)

try(for (row in 1:nrow(final_matrix)) {
    x <- paste0(final_matrix$Var1[row])
    y <- paste0(final_matrix$Var2[row])
    spearman_plot <-
        ggplot(table,
            aes(
                x = get(x),
                y = get(y)
            ),
            fill = TRUE
        ) +
        geom_text(label = rownames(table), vjust = -1) +
        theme_bw() +
        theme(legend.position = "bottom") +
        labs(
            x = paste0(x, "\nAXISX"),
            y = paste0(y, "\nAXISY")
        ) +
        theme(axis.title = element_text(size = 8)) +
        theme(legend.title = element_text(size = 10)) +
        theme(legend.text = element_text(size = 10)) +
        theme(axis.text = element_text(size = 10)) +
        stat_smooth(level = 0.95, method = "lm") +
        stat_cor(method = "spearman", size = 5) +
        theme(
            panel.grid.major = element_line(colour = "gray"),
            panel.grid.minor = element_line(colour = "gray")
        )
    png(paste0(opt$output, "/", x, "_", y, ".png"))
    plot(spearman_plot)
    dev.off()
}, silent = TRUE)
