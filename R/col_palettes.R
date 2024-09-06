#' Title
#'
#' @param object A \code{Seurat} object
#' @param group.by Group (color) cells in different ways (for example, celltype)
#' @param reduction Which dimensionality reduction to use. If not specified, first searches for umap
#' @param show.pt Either to show points, default TRUE, FALSE means do not show points
#' @param pt.size Point size for points
#' @param fill NA means not fill the edge line contour, TRUE means fill
#' @param col Colors to use for plotting
#' @param show.ct Either to show edge line contour, default TRUE (show), if FALSE (now show)
#' @param show.cls A vector, default c('All'), can be subset of group.by clusters
#' @param label.size label size
#'
#' @return A \code{\link[patchwork]{patchwork}ed} ggplot object
#' @export
#'
#' @examples
#' plot_dim(rds, fill=TRUE)
#'
