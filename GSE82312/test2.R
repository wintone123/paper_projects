library(dplyr)
library(pheatmap)
library(RColorBrewer)

max_legend <- function(a) {
    cond <- TRUE
    n <- 0
    while (cond) {
        n <- n + 1
        b <- a %/% 2
        if (b == 1) {
            cond <- FALSE
            return(n + 1)
        } else {
            a <- b
        }
    }
}

fill_gap <- function(list_in) {
    list_out <- vector()
    list_out <- append(list_out, list_in[1])
    for (i in 2:length(list_in)) {
        a <- list_in[i]
        b <- list_in[i - 1]
        if (a == b + 1000) {
            list_out <- append(list_out, a)
        } else {
            list_out <- append(list_out, seq(b, a, 1000)[-1])
        }
    }
    return(list_out)
}

make_matrix <- function(input, mat_row) {
    mat_col <- unique(sort(input$X8))
    mat_col <- fill_gap(mat_col)
    data_mat <- matrix(0, length(mat_row), length(mat_col))
    rownames(data_mat) <- mat_row
    colnames(data_mat) <- mat_col
    input_size <- nrow(input)
    n <- 1
    for (i in 1:input_size) {
        data_mat[input$X4[i], as.character(input$X8[i])] <- data_mat[input$X4[i], as.character(input$X8[i])] + input$X9[i]
        if (i >= (input_size %/% 100) * n) {
            cat("------------------", n, "%-----------------", "\r")
            n <- n + 1
        }
    }
    return(data_mat)
}

file <- "/data/agl_data/ningjun/RNA-DNA/GSE82312/chr11-all.txt"
output_name <- "/data/agl_data/ningjun/RNA-DNA/GSE82312/chr11-all.png"

col <- colorRampPalette(brewer.pal(9, "YlOrRd"))

cat("-------------- loading file -------------", "\n")
input <- readr::read_delim(file, delim = "\t", col_names = FALSE)
input <- data.frame(input)

cat("------------- making matrix -------------", "\n")
chrom_list <- paste0("chr", c(1:21, "X"))
mat_row <- unique(input$X4)
i <- 0
for (chrom in chrom_list) {
    cat("-----------------", chrom, "-----------------", "\n")
    chrom_temp <- filter(input, X7 == chrom)
    if (i == 0) {
        data_mat <- make_matrix(chrom_temp, mat_row)
        i <- 1
    } else {
        data_mat <- cbind(data_mat, make_matrix(chrom_temp, mat_row))
    }
}

cat("--------------making heatmap--------------", "\n")
breaks <- c(0, 2^(0:max_legend(max(data_mat))))
pic <- pheatmap(data_mat, cluster_rows = FALSE, cluster_cols = FALSE,
			 	show_rownames = FALSE, show_colnames = FALSE,
				col = col(length(breaks)), breaks = breaks,
                legend = FALSE, border_color = NA,
                filename = output_name)
