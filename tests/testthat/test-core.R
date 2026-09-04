test_that("metadata is exposed from libbiosyntax", {
    expect_match(biosyntax_engine_version(), "^[0-9]+\\.[0-9]+\\.[0-9]+$")
    expect_true(all(c("vcf", "fasta-nt", "fasta-clustal") %in% supported_formats()$name))
    expect_true(all(c("chrom", "position", "nt_a") %in% syntax_classes()$name))
})

test_that("character input needs an explicit format", {
    expect_error(biosyntax("ACGT"), "format")
    expect_error(biosyntax(NA_character_, format = "fasta"), "must not contain")
    expect_error(biosyntax("ACGT", format = "unknown-format"), "unsupported")
})

test_that("VCF text renders as ANSI and HTML", {
    lines <- c(
        "##fileformat=VCFv4.3",
        "chr1\t42\t.\tA\tG\t60\tPASS\tDP=12"
    )
    x <- biosyntax(lines, format = "vcf")

    expect_equal(as.character(x), lines)
    expect_true(any(grepl("\033\\[", as_ansi(x))))

    rendered <- as_html(x)
    expect_s3_class(rendered, "biosyntax_html")
    expect_true(inherits(rendered, "html"))
    html <- as.character(rendered)
    expect_match(html, "<pre class=\"biosyntax\"")
    expect_match(html, "biosyntax-chrom")
    expect_match(html, "chr1", fixed = TRUE)
})

test_that("span positions are one-based for R users", {
    x <- biosyntax("chr1\t42\t.\tA\tG", format = "vcf")
    spans <- biosyntax_spans(x)

    chrom <- spans[spans$class == "chrom", , drop = FALSE]
    pos <- spans[spans$class == "position", , drop = FALSE]
    expect_equal(chrom$start, 1)
    expect_equal(chrom$length, 4)
    expect_equal(pos$start, 6)
    expect_equal(pos$length, 2)
})

test_that("HTML escapes unhighlighted text", {
    x <- biosyntax("# a < b & c", format = "vcf")
    rendered <- as_html(x)
    expect_s3_class(rendered, "biosyntax_html")
    expect_true(inherits(rendered, "html"))
    html <- as.character(rendered)
    expect_match(html, "&lt;", fixed = TRUE)
    expect_match(html, "&amp;", fixed = TRUE)
})

test_that("FASTQ state is preserved across a vector of lines", {
    x <- biosyntax(c("@r1", "ACGT", "+", "IIII"), format = "fastq")
    spans <- biosyntax_spans(x)
    expect_true(any(spans$line == 1 & spans$class == "header"))
    expect_true(any(spans$line == 2 & spans$class == "nt_a"))
    expect_true(any(spans$line == 4 & grepl("qual", spans$class)))
})


test_that("format aliases are normalized by the C engine", {
    x <- biosyntax("chr1\tsource\tgene\t1\t10\t.\t+\t.\tID=x", format = "gff3")
    expect_equal(x$format, "gff")
})

test_that("as_html passes block through for non-biosyntax input", {
    html <- as.character(as_html("chr1\t42\t.\tA\tG", format = "vcf", block = FALSE))
    expect_false(grepl("<pre", html, fixed = TRUE))
    expect_match(html, "biosyntax-chrom")
})

test_that("empty and UTF-8 input render safely", {
    empty <- biosyntax(character(), format = "fasta")
    expect_equal(as_ansi(empty), character())
    expect_identical(as.character(as_html(empty, block = FALSE)), "")
    expect_equal(nrow(biosyntax_spans(empty)), 0L)

    utf8 <- biosyntax("# 配列 <&>", format = "vcf")
    expect_match(as.character(as_html(utf8)), "配列", fixed = TRUE)
    expect_match(as.character(as_html(utf8)), "&lt;&amp;&gt;", fixed = TRUE)
})

test_that("WIG mode is preserved across lines", {
    fixed <- biosyntax(c(
        "fixedStep chrom=chr1 start=1 step=1",
        "10 20"
    ), format = "wig")
    variable <- biosyntax(c(
        "variableStep chrom=chr1 span=1",
        "10 20"
    ), format = "wig")

    fixed_spans <- biosyntax_spans(fixed)
    variable_spans <- biosyntax_spans(variable)
    expect_false(any(fixed_spans$line == 2L & fixed_spans$class == "position"))
    expect_true(any(variable_spans$line == 2L & variable_spans$class == "position"))
})

test_that("every advertised format produces valid spans", {
    samples <- c(
        fasta = ">sequence",
        fastq = "@read-1",
        sam = "read1\t0\tchr1\t1\t60\t4M\t*\t0\t0\tACGT\tIIII",
        vcf = "chr1\t42\t.\tA\tG\t60\tPASS\tDP=12",
        bed = "chr1\t0\t10\tfeature\t500\t+",
        gtf = "chr1\tsource\tgene\t1\t10\t.\t+\t.\tgene_id \"g1\";",
        gff = "chr1\tsource\tgene\t1\t10\t.\t+\t.\tID=g1",
        pdb = "ATOM      1  N   MET A   1      11.104  13.207   2.100",
        clustal = "CLUSTAL W multiple sequence alignment",
        faidx = "chr1\t1000\t6\t60\t61",
        flagstat = "10 + 2 in total (QC-passed reads + QC-failed reads)",
        wig = "fixedStep chrom=chr1 start=1 step=1",
        `fasta-nt` = "ACGTN",
        `fasta-hc` = "ACGTN",
        `fasta-clustal` = "MKWVTF",
        `fasta-hydro` = "MKWVTF",
        `fasta-taylor` = "MKWVTF",
        `fasta-zappo` = "MKWVTF",
        `fasta-orf` = "ATGAAATAA"
    )

    expect_setequal(names(samples), supported_formats()$name)
    for (format in names(samples)) {
        line <- unname(samples[[format]])
        spans <- biosyntax_spans(line, format = format)
        expect_true(nrow(spans) > 0L, info = format)
        expect_true(all(spans$start >= 1), info = format)
        expect_true(all(spans$end <= nchar(line, type = "bytes")), info = format)
        expect_true(all(spans$class_id %in% syntax_classes()$id), info = format)
    }
})
