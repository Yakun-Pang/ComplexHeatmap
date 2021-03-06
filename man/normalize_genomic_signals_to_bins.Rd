\name{normalize_genomic_signals_to_bins}
\alias{normalize_genomic_signals_to_bins}
\title{
Overlap genomic signals to the genomic bins
}
\description{
Overlap genomic signals to the genomic bins
}
\usage{
normalize_genomic_signals_to_bins(gr, value, value_column = NULL, method = "weighted",
    empty_value = NA, window = GHEATMAP_ENV$chr_window)
}
\arguments{

  \item{gr}{A \code{\link[GenomicRanges:GRanges-class]{GRanges}} object.}
  \item{value}{The corresponding signals corresponding to \code{gr}.}
  \item{value_column}{If \code{value} is not set and the values are in the meta-columns in \code{gr}, you can specify the column indices for these value columns, better to use name indices.}
  \item{method}{One of "weighted", "w0" and "absolute". For the three different methods, please refer to \url{https://bioconductor.org/packages/release/bioc/vignettes/EnrichedHeatmap/inst/doc/EnrichedHeatmap.html#toc_7} .}
  \item{empty_value}{The value for the bins where no signal is overlapped.}
  \item{window}{The genomic bins generated from \code{\link{bin_genome}}.}

}
\details{
The genomic bins should be generated by \code{\link{bin_genome}} in advance. The genomic bins are saved internally, so that multiple
uses of \code{\link{bin_genome}} ensure they all return the matrices with the same rows.

It supports following values.

\itemize{
  \item When neither \code{value} nor \code{value_column} is set, it simply overlap \code{gr} to the genomic bins and returns a one-column logical matrix which represents whether the current genomic bin overlaps to any signal.
  \item When the signals are numeric, \code{value} can be a numeric vector or a matrix, or \code{value_column} can contain multiple columns. The function returns a numeric matrix where the values are properly averaged depending on what \code{method} was used.
  \item When the signals are character, \code{value} can only be a vector or \code{value_column} can only contain one single column. The function returns a one-column character matrix.
}
}
\value{
A matrix with the same row as the genomic bins.
}
\examples{
\dontrun{
require(circlize)
require(GenomicRanges)

chr_window = bin_genome("hg19")

#### the first is a numeric matrix #######
bed1 = generateRandomBed(nr = 1000, nc = 10)
gr1 = GRanges(seqnames = bed1[, 1], ranges = IRanges(bed1[, 2], bed1[, 3]))

num_mat = normalize_genomic_signals_to_bins(gr1, bed1[, -(1:3)])

#### the second is a character matrix ######
bed_list = lapply(1:10, function(i) {
    generateRandomBed(nr = 1000, nc = 1, 
        fun = function(n) sample(c("gain", "loss"), n, replace = TRUE))
})
char_mat = NULL
for(i in 1:10) {
    bed = bed_list[[i]]
    bed = bed[sample(nrow(bed), 20), , drop = FALSE]
    gr_cnv = GRanges(seqnames = bed[, 1], ranges = IRanges(bed[, 2], bed[, 3]))

    char_mat = cbind(char_mat, normalize_genomic_signals_to_bins(gr_cnv, bed[, 4]))
}

#### two numeric columns ##########
bed2 = generateRandomBed(nr = 100, nc = 2)
gr2 = GRanges(seqnames = bed2[, 1], ranges = IRanges(bed2[, 2], bed2[, 3]))

v = normalize_genomic_signals_to_bins(gr2, bed2[, 4:5])

##### a list of genes need to be highlighted
bed3 = generateRandomBed(nr = 40, nc = 0)
gr3 = GRanges(seqnames = bed3[, 1], ranges = IRanges(bed3[, 2], bed3[, 2]))
gr3$gene = paste0("gene_", 1:length(gr3))

mtch = as.matrix(findOverlaps(chr_window, gr3))
at = mtch[, 1]
labels = mcols(gr3)[mtch[, 2], 1]

##### order of the chromosomes ########
chr = as.vector(seqnames(chr_window))
chr_level = paste0("chr", c(1:22, "X", "Y"))
chr = factor(chr, levels = chr_level)

#### make the heatmap #######
subgroup = rep(c("A", "B"), each = 5)

ht_opt$TITLE_PADDING = unit(c(4, 4), "points")
ht_list = Heatmap(num_mat, name = "mat", col = colorRamp2(c(-1, 0, 1), c("green", "white", "red")),
    row_split = chr, cluster_rows = FALSE, show_column_dend = FALSE,
    column_split = subgroup, cluster_column_slices = FALSE,
    column_title = "numeric matrix",
    top_annotation = HeatmapAnnotation(subgroup = subgroup, annotation_name_side = "left"),
    row_title_rot = 0, row_title_gp = gpar(fontsize = 10), border = TRUE,
    row_gap = unit(0, "points")) +
Heatmap(char_mat, name = "CNV", col = c("gain" = "red", "loss" = "blue"),
    border = TRUE, column_title = "character matrix") +
rowAnnotation(label = anno_mark(at = at, labels = labels)) +
rowAnnotation(pt = anno_points(v, gp = gpar(col = 4:5), pch = c(1, 16)), 
    width = unit(2, "cm")) +
rowAnnotation(bar = anno_barplot(v[, 1], gp = gpar(col = ifelse(v[ ,1] > 0, 2, 3))), 
    width = unit(2, "cm"))
draw(ht_list, merge_legend = TRUE)

##### or horizontally ###
ht_list = Heatmap(t(num_mat), name = "mat", col = colorRamp2(c(-1, 0, 1), c("green", "white", "red")),
    column_split = chr, cluster_columns = FALSE, show_row_dend = FALSE,
    row_split = subgroup, cluster_row_slices = FALSE,
    row_title = "numeric matrix",
    left_annotation = rowAnnotation(subgroup = subgroup, show_annotation_name = FALSE,
        annotation_legend_param = list(
            subgroup = list(direction = "horizontal", title_position = "lefttop", nrow = 1))),
    column_title_gp = gpar(fontsize = 10), border = TRUE,
    column_gap = unit(0, "points"),
    column_title = ifelse(seq_along(chr_level) \%\% 2 == 0, paste0("\n", chr_level), paste0(chr_level, "\n")),
    heatmap_legend_param = list(direction = "horizontal", title_position = "lefttop")) \%v\%
Heatmap(t(char_mat), name = "CNV", col = c("gain" = "red", "loss" = "blue"),
    border = TRUE, row_title = "character matrix",
    heatmap_legend_param = list(direction = "horizontal", title_position = "lefttop", nrow = 1)) \%v\%
HeatmapAnnotation(label = anno_mark(at = at, labels = labels, side = "bottom")) \%v\%
HeatmapAnnotation(pt = anno_points(v, gp = gpar(col = 4:5), pch = c(1, 16)),
    annotation_name_side = "left", height = unit(2, "cm")) \%v\%
HeatmapAnnotation(bar = anno_barplot(v[, 1], gp = gpar(col = ifelse(v[ ,1] > 0, 2, 3))), 
    annotation_name_side = "left", height = unit(2, "cm"))
draw(ht_list, heatmap_legend_side = "bottom", merge_legend = TRUE)
}
}
