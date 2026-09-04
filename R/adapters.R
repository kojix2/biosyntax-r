.sequence_lines <- function(x) {
    seqs <- enc2utf8(as.character(x))
    nm <- names(x)
    if (is.null(nm) || !length(nm) || !any(nzchar(nm))) {
        return(seqs)
    }
    nm[is.na(nm) | !nzchar(nm)] <- paste0("sequence_", which(is.na(nm) | !nzchar(nm)))
    as.vector(rbind(paste0(">", nm), seqs))
}

# S3 dispatch supports these S4 classes without importing Biostrings.
biosyntax.DNAString <- function(x, format = "fasta-nt", ...) {
    .new_biosyntax(as.character(x), format)
}

biosyntax.RNAString <- biosyntax.DNAString

biosyntax.AAString <- function(x, format = "fasta-clustal", ...) {
    .new_biosyntax(as.character(x), format)
}

biosyntax.BString <- function(x, format = "fasta", ...) {
    .new_biosyntax(as.character(x), format)
}

biosyntax.XString <- function(x, format = "fasta", ...) {
    .new_biosyntax(as.character(x), format)
}

biosyntax.DNAStringSet <- function(x, format = "fasta-nt", ...) {
    .new_biosyntax(.sequence_lines(x), format)
}

biosyntax.RNAStringSet <- biosyntax.DNAStringSet

biosyntax.AAStringSet <- function(x, format = "fasta-clustal", ...) {
    .new_biosyntax(.sequence_lines(x), format)
}

biosyntax.BStringSet <- function(x, format = "fasta", ...) {
    .new_biosyntax(.sequence_lines(x), format)
}

biosyntax.XStringSet <- function(x, format = "fasta", ...) {
    .new_biosyntax(.sequence_lines(x), format)
}

biosyntax.VCF <- function(x, format = "vcf", include_header = TRUE, ...) {
    .require_suggested("VariantAnnotation")
    # writeVcf() re-opens its destination, so use a path rather than a
    # textConnection.
    path <- tempfile(fileext = ".vcf")
    on.exit(unlink(path), add = TRUE)
    VariantAnnotation::writeVcf(x, path, index = FALSE)
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    if (!isTRUE(include_header)) {
        lines <- lines[!startsWith(lines, "#")]
    }
    .new_biosyntax(lines, format)
}

biosyntax.GRanges <- function(x, format = c("bed", "gff3", "gff", "gtf"), ...) {
    .require_suggested("rtracklayer")
    format <- match.arg(format)
    export_format <- if (format %in% c("gff", "gff3")) "gff3" else format
    con <- textConnection(NULL, open = "w", local = TRUE)
    on.exit(close(con), add = TRUE)
    rtracklayer::export(x, con, format = export_format)
    lines <- textConnectionValue(con)
    .new_biosyntax(lines, format)
}

biosyntax.GRangesList <- biosyntax.GRanges

.require_suggested <- function(package) {
    if (!requireNamespace(package, quietly = TRUE)) {
        stop(
            "Package `", package, "` is required for this object type. ",
            "Install it with `BiocManager::install(\"", package, "\")`.",
            call. = FALSE
        )
    }
}
