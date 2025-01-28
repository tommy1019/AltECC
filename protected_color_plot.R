library(ggplot2)
library(reshape2)
library(latex2exp)
library(cowplot)

args <- commandArgs(trailingOnly = TRUE)
# args <- c("out_pc.txt", "out_ecc.txt", "out.pdf")

ecc_data <- read.csv(args[2])

legends <- args[4] == "legends"

datasets <- ecc_data$Dataset
dataset_ecc_lp <- ecc_data$lp_objective

types <- c(" smallest", " median", " largest")
types_display <- c("Smallest Color", "Median Color", "Largest Color")

data <- read.csv(args[1])
data$protected_color_mistake_percent <- data$protected_color_mistakes / data$protected_color_count
data$approx_bound <- data$total_mistakes / data$lp_objective
data$dataset_index <- match(data$Dataset, datasets)
data$ecc_approx_bound <- data$total_mistakes / dataset_ecc_lp[data$dataset_index]

if (legends) {
    pdf(args[3], width = 4.5, height = 2.1)
} else {
    pdf(args[3], width = 3.2, height = 2.1)
}

datasets <- c("DAWN", "MAG-10", "Cooking", "Brain", "Walmart-Trips", "Trivago-Clickout")
for (dataset in datasets) {
    data_filtered <- data[(data$protected_color_type == " median") & (data$Dataset == dataset), ]
    print(dataset)
    print(min(data_filtered$approx_bound))
    print(max(data_filtered$approx_bound))
}

for (i in 1:3) {
    data_filtered <- data[data$protected_color_type == types[i], ]

    plot1 <- ggplot(data_filtered, aes(
        x = protected_color_limit_percent,
        y = protected_color_mistake_percent * 100,
        colour = Dataset,
        shape = Dataset
    )) +
        geom_point() +
        geom_line() +
        ggtitle(paste(types_display[i], "PC Unsatisfied Percent", sep = " ")) +
        xlab("Protected Color Constraint %") +
        ylab("PC Unsatisfied %") +
        labs(color = "Dataset", shape = "Dataset") +
        geom_abline(intercept = 0, slope = 1, color = "gray") +
        geom_abline(intercept = 0, slope = 2, color = "gray") +
        geom_vline(xintercept = 100, linetype = "dashed") +
        geom_text(aes(x = 97, label = "minECC", y = 15), colour = "black", angle = 90, size = 2.8, fontface = 0) +
        theme_bw() +
        theme(plot.title = element_blank())

    if (!legends) {
        plot1 <- plot1 + theme(legend.position = "none")
    }

    print(plot1)

    plot2 <- ggplot(data_filtered, aes(
        x = protected_color_limit_percent,
        y = approx_bound,
        colour = Dataset,
        shape = Dataset
    )) +
        geom_point() +
        geom_line() +
        ggtitle(paste(types_display[i], "Approximation Bound", sep = " ")) +
        xlab("Protected Color Limit %") +
        ylab("PCECC Approx Bound") +
        labs(color = "Dataset", shape = "Dataset") +
        theme_bw() +
        theme(plot.title = element_blank())

    if (!legends) {
        plot2 <- plot2 + theme(legend.position = "none")
    }

    print(plot2)

    plot3 <- ggplot(data_filtered, aes(
        x = protected_color_limit_percent,
        y = lp_runtime,
        colour = Dataset,
        shape = Dataset
    )) +
        geom_point() +
        geom_line() +
        ggtitle(paste(types_display[i], "Runtime", sep = " ")) +
        xlab("Protected Color Limit %") +
        ylab("Runtime (seconds)") +
        labs(color = "Dataset", shape = "Dataset") +
        theme_bw() +
        theme(plot.title = element_blank(), legend.position = "none")

    if (!legends) {
        plot3 <- plot3 + theme(legend.position = "none")
    }

    print(plot3)

    plot4 <- ggplot(data_filtered, aes(
        x = protected_color_limit_percent,
        y = ecc_approx_bound,
        colour = Dataset,
        shape = Dataset
    )) +
        geom_point() +
        geom_line() +
        ggtitle(paste(types_display[i], "ECC Approximation Bound", sep = " ")) +
        xlab("Protected Color Limit %") +
        ylab("ECC Approx Bound") +
        labs(color = "Dataset", shape = "Dataset") +
        theme_bw() +
        theme(plot.title = element_blank(), legend.position = "none")

    if (!legends) {
        plot4 <- plot4 + theme(legend.position = "none")
    }

    print(plot4)
}

dev.off()
