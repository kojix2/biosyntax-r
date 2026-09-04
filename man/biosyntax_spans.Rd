\name{biosyntax_spans}
\alias{biosyntax_spans}
\title{Inspect semantic BioSyntax spans}
\usage{
biosyntax_spans(x, ...)
}
\arguments{
  \item{x}{A \code{biosyntax} object, or an object accepted by
  \code{biosyntax()}.}
  \item{...}{For non-\code{biosyntax} inputs, arguments passed to
  \code{biosyntax()}.}
}
\value{
A data frame with line number, one-based byte start, inclusive byte end,
length, class ID, and semantic class name.
}
\description{
Returns the semantic token spans produced by libbiosyntax without applying a
particular renderer.
}
\examples{
biosyntax_spans("chr1\t42\t.\tA\tG", format = "vcf")
}
