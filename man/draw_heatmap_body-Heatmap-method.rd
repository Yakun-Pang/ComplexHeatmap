\name{draw_heatmap_body-Heatmap-method}
\alias{draw_heatmap_body,Heatmap-method}
\alias{draw_heatmap_body}
\title{
Draw the heatmap body


}
\description{
Draw the heatmap body


}
\usage{
\S4method{draw_heatmap_body}{Heatmap}(object, k = 1, ...)
}
\arguments{

  \item{object}{a \code{\link{Heatmap}} object.
  \item{k}{a matrix may be splitted by rows, the value identifies which row-slice.
  \item{...}{pass to \code{\link[grid]{viewport}}, basically for defining the position of the viewport.

}
\details{
The matrix can be splitted into several parts by rows if \code{km} or \code{split} is 

A viewport is created which contains grids.

This function is only for internal use.


}
\value{
This function returns no value.


}
\author{
Zuguang Gu <z.gu@dkfz.de>


}