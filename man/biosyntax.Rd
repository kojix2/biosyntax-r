\name{biosyntax}
\alias{biosyntax}
\alias{as_ansi}
\alias{as_html}
\title{Highlight biological text}
\usage{
biosyntax(x, ...)

as_ansi(x, ...)

as_html(x, ..., block = TRUE)
}
\arguments{
  \item{x}{A character vector, a \code{biosyntax} object, or a supported
  Bioconductor object. Character input requires a \code{format} argument.}
  \item{...}{Arguments passed to a class-specific method. For character input,
  use \code{format}, for example \code{format = "vcf"}.}
  \item{block}{For \code{as_html()}, wrap the output in a \code{<pre>} block.}
}
\value{
\code{biosyntax()} returns an object of class \code{biosyntax}.
\code{as_ansi()} returns one ANSI-rendered character string per input line.
\code{as_html()} returns a length-one HTML string inheriting from
\code{biosyntax_html} and \code{html}.
}
\description{
Creates an object that can be rendered as ANSI, HTML, or semantic spans.
}
\details{
Methods support Biostrings sequences, VariantAnnotation \code{VCF} objects, and
GenomicRanges \code{GRanges} objects when their packages are installed.
}
\examples{
x <- biosyntax(
    c("##fileformat=VCFv4.3", "chr1\t42\t.\tA\tG\t60\tPASS\tDP=12"),
    format = "vcf"
)
print(x, color = FALSE)
as_html(x)
}
