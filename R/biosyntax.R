#' Highlight biological text
#'
#' Creates an object that can be rendered as ANSI, HTML, or semantic spans.
#' Printing uses ANSI colors in interactive terminals and HTML in knitr.
#'
#' @param x A character vector of text lines, a `biosyntax` object, or a
#'   supported Bioconductor object.
#' @param ... Arguments passed to a class-specific method.
#' @return An object of class `biosyntax`.
#' @export
biosyntax <- function(x, ...) {
    UseMethod("biosyntax")
}

#' @export
biosyntax.character <- function(x, format = NULL, ...) {
    if (is.null(format)) {
        stop("`format` is required for character input.", call. = FALSE)
    }
    .new_biosyntax(x, format)
}

#' @export
biosyntax.biosyntax <- function(x, ...) {
    x
}

#' @export
biosyntax.default <- function(x, ...) {
    stop(
        "No `biosyntax()` method for objects of class ",
        paste(class(x), collapse = "/"),
        ".",
        call. = FALSE
    )
}

.new_biosyntax <- function(lines, format) {
    lines <- .validate_lines(lines)
    format <- .validate_format(format)
    structure(
        list(lines = lines, format = format),
        class = "biosyntax"
    )
}

.validate_lines <- function(lines) {
    if (!is.character(lines)) {
        stop("Text lines must be a character vector.", call. = FALSE)
    }
    if (anyNA(lines)) {
        stop("Text lines must not contain `NA`.", call. = FALSE)
    }
    enc2utf8(lines)
}

.validate_format <- function(format) {
    if (!is.character(format) || length(format) != 1L || is.na(format)) {
        stop("`format` must be one non-missing character string.", call. = FALSE)
    }
    .Call(C_biosyntax_normalize_format, format)
}

#' @export
as.character.biosyntax <- function(x, ...) {
    x$lines
}

#' @export
print.biosyntax <- function(x, ..., color = getOption("biosyntax.color", NULL)) {
    if (is.null(color)) {
        color <- interactive() && !nzchar(Sys.getenv("NO_COLOR"))
    }
    lines <- if (isTRUE(color)) as_ansi(x) else x$lines
    if (length(lines)) {
        cat(lines, sep = "\n")
        cat("\n")
    }
    invisible(x)
}
