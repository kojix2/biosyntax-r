.biosyntax_cache <- new.env(parent = emptyenv())

#' BioSyntax formats and semantic classes
#'
#' @return `supported_formats()` and `syntax_classes()` return data frames.
#'   `biosyntax_engine_version()` returns the embedded libbiosyntax version.
#' @export
supported_formats <- function() {
    x <- .Call(C_biosyntax_formats)
    data.frame(
        id = x$id,
        name = x$name,
        description = x$description,
        stateful = x$stateful,
        stringsAsFactors = FALSE
    )
}

#' @rdname supported_formats
#' @export
syntax_classes <- function() {
    x <- .Call(C_biosyntax_classes)
    data.frame(
        id = x$id,
        name = x$name,
        scope = x$scope,
        foreground = x$foreground,
        background = x$background,
        font_style = x$font_style,
        ansi_sgr = x$ansi_sgr,
        stringsAsFactors = FALSE
    )
}

#' @rdname supported_formats
#' @export
biosyntax_engine_version <- function() {
    .Call(C_biosyntax_version)
}

.class_info <- function() {
    if (is.null(.biosyntax_cache$classes)) {
        .biosyntax_cache$classes <- syntax_classes()
    }
    .biosyntax_cache$classes
}
