test_that("Biostrings objects are accepted directly", {
    skip_if_not_installed("Biostrings")

    dna <- Biostrings::DNAStringSet(c(ref = "ACGT", alt = "ANGT"))
    x <- biosyntax(dna)
    expect_s3_class(x, "biosyntax")
    expect_equal(x$format, "fasta-nt")
    expect_equal(as.character(x), c(">ref", "ACGT", ">alt", "ANGT"))

    aa <- Biostrings::AAString("MKWVTF")
    expect_equal(biosyntax(aa)$format, "fasta-clustal")
})

test_that("GRanges uses rtracklayer rather than a private serializer", {
    skip_if_not_installed("GenomicRanges")
    skip_if_not_installed("rtracklayer")

    gr <- GenomicRanges::GRanges("chr1:10-20")
    x <- biosyntax(gr, format = "bed")
    expect_s3_class(x, "biosyntax")
    expect_equal(x$format, "bed")
    expect_true(startsWith(as.character(x)[[1]], "chr1"))

    gff <- biosyntax(gr, format = "gff3")
    expect_equal(gff$format, "gff")
})

test_that("VCF objects round-trip through VariantAnnotation's writer", {
    skip_if_not_installed("VariantAnnotation")

    path <- tempfile(fileext = ".vcf")
    on.exit(unlink(path), add = TRUE)
    writeLines(c(
        "##fileformat=VCFv4.2",
        "##contig=<ID=chr1,length=1000>",
        "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO",
        "chr1\t42\t.\tA\tG\t60\tPASS\t."
    ), path)
    vcf <- VariantAnnotation::readVcf(path, genome = "test")
    x <- biosyntax(vcf)
    expect_s3_class(x, "biosyntax")
    expect_equal(x$format, "vcf")
    expect_true(any(grepl("^chr1\\t42\\t", as.character(x))))

    body_only <- biosyntax(vcf, include_header = FALSE)
    expect_false(any(startsWith(as.character(body_only), "#")))
    expect_true(any(grepl("^chr1\\t42\\t", as.character(body_only))))
})
