\name{supported_formats}
\alias{supported_formats}
\alias{syntax_classes}
\alias{biosyntax_engine_version}
\title{Inspect the embedded libbiosyntax engine}
\usage{
supported_formats()

syntax_classes()

biosyntax_engine_version()
}
\value{
\code{supported_formats()} and \code{syntax_classes()} return data frames.
\code{biosyntax_engine_version()} returns a character scalar.
}
\description{
Reports supported biological formats, semantic token classes and the version of
the embedded libbiosyntax C engine.
}
\examples{
head(supported_formats())
head(syntax_classes())
biosyntax_engine_version()
}
