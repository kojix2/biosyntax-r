#' Render BioSyntax output
#'
#' @param x A `biosyntax` object, or an object accepted by [biosyntax()].
#' @param ... For non-`biosyntax` inputs, arguments passed to [biosyntax()].
#' @param block For `as_html()`, wrap the result in a `<pre>` block.
#' @return `as_ansi()` returns a character vector, one element per input line.
#'   `as_html()` returns a length-one character object of class
#'   `biosyntax_html`.
#' @export
as_ansi <- function(x, ...) {
    UseMethod("as_ansi")
}

#' @export
as_ansi.biosyntax <- function(x, ...) {
    .Call(C_biosyntax_render_ansi, x$lines, x$format)
}

#' @export
as_ansi.default <- function(x, ...) {
    as_ansi(biosyntax(x, ...))
}

#' @rdname as_ansi
#' @export
as_html <- function(x, ..., block = TRUE) {
    UseMethod("as_html")
}

#' @export
as_html.biosyntax <- function(x, ..., block = TRUE) {
    native <- .native_spans(x)
    info <- .class_info()
    rendered <- vapply(
        seq_along(x$lines),
        function(i) .render_html_line(x$lines[[i]], native[[i]], info),
        character(1)
    )

    html <- paste(rendered, collapse = "\n")
    if (isTRUE(block)) {
        html <- paste0('<pre class="biosyntax">', html, '</pre>')
    }
    structure(html, class = c("biosyntax_html", "html", "character"))
}

#' @export
as_html.default <- function(x, ..., block = TRUE) {
    as_html(biosyntax(x, ...), block = block)
}

#' @export
print.biosyntax_html <- function(x, ...) {
    cat(unclass(x), "\n", sep = "")
    invisible(x)
}

# Registered without importing the optional knitr package.
knit_print.biosyntax <- function(x, ...) {
    structure(unclass(as_html(x)), class = "knit_asis")
}

knit_print.biosyntax_html <- function(x, ...) {
    structure(unclass(x), class = "knit_asis")
}

.render_html_line <- function(line, spans, info) {
    bytes <- charToRaw(line)
    total <- length(bytes)
    cursor <- 0
    pieces <- character()

    if (length(spans$start)) {
        for (i in seq_along(spans$start)) {
            start <- spans$start[[i]]
            end <- min(total, start + spans$length[[i]])
            if (start < cursor || end <= start) {
                next
            }
            if (start > cursor) {
                pieces <- c(pieces, .html_escape(.raw_text(bytes, cursor, start)))
            }

            class_id <- spans$class_id[[i]]
            row <- info[class_id + 1L, , drop = FALSE]
            text <- .html_escape(.raw_text(bytes, start, end))
            cls <- paste0("biosyntax-", gsub("[^A-Za-z0-9_-]", "-", row$name))
            style <- .html_style(row)
            style_attr <- if (nzchar(style)) paste0(' style="', style, '"') else ""
            pieces <- c(
                pieces,
                paste0('<span class="', cls, '"', style_attr, '>', text, '</span>')
            )
            cursor <- end
        }
    }

    if (cursor < total) {
        pieces <- c(pieces, .html_escape(.raw_text(bytes, cursor, total)))
    }
    paste0(pieces, collapse = "")
}

.raw_text <- function(bytes, start, end) {
    if (end <= start) {
        return("")
    }
    rawToChar(bytes[seq.int(start + 1, end)])
}

.html_escape <- function(x) {
    x <- gsub("&", "&amp;", x, fixed = TRUE)
    x <- gsub("<", "&lt;", x, fixed = TRUE)
    x <- gsub(">", "&gt;", x, fixed = TRUE)
    x <- gsub('"', "&quot;", x, fixed = TRUE)
    x
}

.html_style <- function(row) {
    style <- character()
    if (nzchar(row$foreground)) {
        style <- c(style, paste0("color:", row$foreground))
    }
    if (nzchar(row$background)) {
        style <- c(style, paste0("background-color:", row$background))
    }
    if (identical(row$font_style, "bold")) {
        style <- c(style, "font-weight:700")
    } else if (identical(row$font_style, "italic")) {
        style <- c(style, "font-style:italic")
    } else if (identical(row$font_style, "underline")) {
        style <- c(style, "text-decoration:underline")
    }
    paste(style, collapse = ";")
}
