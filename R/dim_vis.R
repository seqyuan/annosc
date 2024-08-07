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
#' plot_dim(rds, fill=NA, show.cls=c("CD4 Naive T", "CD14 Mono"))
#' plot_dim(rds, fill=TRUE, show.cls=c("T activated", "CD14 Mono"))
#' plot_dim(rds, fill=NA)
#' plot_dim(rds, fill=TRUE, show.pt=FALSE)
#' plot_dim(rds, fill=NA, show.pt=FALSE)
#' plot_dim(rds, reduction="pca")
#'
plot_dim <- function(object,
                     group.by=NULL,
                     reduction=NULL,
                     show.pt=TRUE,
                     pt.size=0.5,
                     fill=NA,
                     col=NULL,
                     show.ct=TRUE,
                     show.cls=c('All'),
                     label.size=5

){
  # get data
  df <- Seurat::DimPlot(object, reduction=reduction, group.by=group.by)$data
  colnames(df) <- c('UMAP_1','UMAP_2','cluster')

  cluster_level <- NULL
  if (is.null(group.by)){
    cluster_level <- levels(Idents(object))
  }else{
    cluster_level <- levels(object@meta.data[[group.by]])
  }


  if (is.null(cluster_level)){
    cluster_level <- unique(df$cluster)
  }
  df$cluster <- factor(df$cluster, levels=cluster_level)

  labels <- paste0("C", seq(1:length(cluster_level)))
  names(labels) <- cluster_level
  df$label <- labels[df$cluster]
  df$celltype <- factor(paste0(df$label, " ", df$cluster), levels=paste0(labels," ",cluster_level))

  cluster_num <- length(cluster_level)

  if (is.null(col)){
    if (length(unique(df$cluster))<11){
      col <- RColorBrewer::brewer.pal(cluster_num, 'Paired')
    }else{
      col <- colorRampPalette(RColorBrewer::brewer.pal(10,'Paired'))(cluster_num)
    }
  }

  group_means <- df %>%
    group_by(label) %>%
    summarise(x_mean = median(UMAP_1), y_mean = median(UMAP_2))

  group_means <- data.frame(group_means)
  rownames(group_means) <- group_means$label
  group_means <- group_means[paste0("C", seq(1:length(cluster_level))),]

  col_label <- col
  col_celltype <- col
  names(col_label) <- paste0("C", seq(1:length(cluster_level)))
  names(col_celltype) <- paste0(labels," ",cluster_level)

  axis <- ggh4x::guide_axis_truncated(
    trunc_lower = unit(0, 'npc'),
    trunc_upper = unit(3, 'cm')
  )

  cls2show <- df
  if (show.cls[1] != 'All'){
    cls2show <- subset(df, cluster %in% show.cls)
  }

  cls2show$celltype <- factor(cls2show$celltype, levels=paste0(labels," ",cluster_level))

  p <- ggplot(df, aes(x = UMAP_1, y = UMAP_2))

  if (show.pt==TRUE){
    p <- p + geom_point(size=pt.size, show.legend = TRUE, aes(color=celltype))
  }

  if (show.ct==TRUE){
    delta_r <- 0.03
    th_r <- 0.03
    delta <- diff(range(df$UMAP_1)) * delta_r
    th <- diff(range(df$UMAP_1)) * th_r

    if (is.na(fill)){
      p <- p + ggunchull::stat_unchull(data=cls2show, aes(x = UMAP_1, y = UMAP_2, color=celltype),
                                       alpha = 0.2,
                                       lty = 2,
                                       linewidth = 0.5,
                                       delta=0.7,
                                       fill=NA,
                                       show.legend = F,
                                       th = th )
    }else{
      p <- p + ggunchull::stat_unchull(data=cls2show, aes(x = UMAP_1, y = UMAP_2, color=celltype, fill=celltype),
                                       alpha = 0.2,
                                       lty = 2,
                                       linewidth = 0.5,
                                       delta=0.7,
                                       show.legend = F,
                                       th = th )
    }
  }

  p <- p + guides(color=guide_legend(override.aes = list(size=5)), x = axis, y = axis) +
    scale_x_continuous(breaks = NULL) +
    scale_y_continuous(breaks = NULL) +
    scale_color_manual(values = col_celltype) +
    scale_fill_manual(values = col_celltype) +
    theme( aspect.ratio = 1,
           panel.background = element_blank(),
           panel.grid = element_blank(),
           #axis.line = element_line()
           axis.line = element_line(arrow = arrow(type = "closed")),
           axis.title = element_text(hjust = 0.05, face = "italic"),
           legend.text = element_text(size = 12),
           legend.title = element_blank()
    )
  p <- p + shadowtext::geom_shadowtext(data = group_means,
                                       aes(x = x_mean, y = y_mean, label = label),
                                       nudge_x = 0.5, nudge_y = 0.5, size=label.size, bg.color=col_label)


  return(p)
}
