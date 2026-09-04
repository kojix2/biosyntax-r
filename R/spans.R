#' Inspect syntax-highlight spans
#'
#' Returns the semantic spans produced by libbiosyntax. R-facing positions are
#' one-based byte offsets; `end` is inclusive.
#'
#' @param x A `biosyntax` object, or an object accepted by [biosyntax()].
#' @param ... For non-`biosyntax` inputs, arguments passed to [biosyntax()].
#' @return A data frame with columns `line`, `start`, `end`, `length`,
#'   `class_id`, and `class`.
#' @export
biosyntax_spans <- function(x, ...) {
    if (!inherits(x, "biosyntax")) {
        x <- biosyntax(x, ...)
    }
    native <- .native_spans(x)
    info <- .class_info()

    out <- lapply(seq_along(native), function(i) {
        z <- native[[i]]
        if (!length(z$start)) {
            return(NULL)
        }
        data.frame(
            line = rep.int(i, length(z$start)),
            start = z$start + 1,
            end = z$start + z$length,
            length = z$length,
            class_id = z$class_id,
            class = info$name[z$class_id + 1L],
            stringsAsFactors = FALSE
        )
    })
    out <- Filter(Negate(is.null), out)
    if (!length(out)) {
        return(data.frame(
            line = integer(),
            start = double(),
            end = double(),
            length = double(),
            class_id = integer(),
            class = character(),
            stringsAsFactors = FALSE
        ))
    }
    ans <- do.call(rbind, out)
    rownames(ans) <- NULL
    ans
}

.native_spans <- function(x) {
    .Call(C_biosyntax_spans, x$lines, x$format)
}
