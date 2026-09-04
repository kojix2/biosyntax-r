# biosyntax: biological syntax highlighting in R

`biosyntax` highlights biological text without parsing or changing the
data. It returns ANSI, HTML, or semantic spans and accepts several
Bioconductor classes.

## Text input

``` r

library(biosyntax)

vcf_lines <- c(
  "##fileformat=VCFv4.3",
  "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO",
  "chr1\t42\t.\tA\tG\t60\tPASS\tDP=12"
)

x <- biosyntax(vcf_lines, format = "vcf")
biosyntax_spans(x)
#>    line start end length class_id      class
#> 1     1     1   2      2        2    comment
#> 2     1     3  12     10        1     header
#> 3     1    14  20      7        1     header
#> 4     2     1   6      6        1     header
#> 5     2     8  10      3        1     header
#> 6     2    12  13      2        1     header
#> 7     2    15  17      3        1     header
#> 8     2    19  21      3        1     header
#> 9     2    23  26      4        1     header
#> 10    2    28  33      6        1     header
#> 11    2    35  38      4        1     header
#> 12    3     1   4      4        3      chrom
#> 13    3     6   7      2        4   position
#> 14    3     9   9      1      211       null
#> 15    3    11  11      1       41       nt_a
#> 16    3    13  13      1       43       nt_g
#> 17    3    15  16      2       12 number_alt
#> 18    3    18  21      4       14       good
#> 19    3    23  24      2       21   keyword6
#> 20    3    26  27      2       11     number
x
```

``` biosyntax
##fileformat=VCFv4.3
#CHROM POS    ID REF    ALT    QUAL   FILTER INFO
chr1 42    . A    G    60  PASS DP=12
```

## Biostrings

``` r

dna <- Biostrings::DNAStringSet(c(ref = "ACGTACGT", alt = "ACGTNCGT"))
biosyntax(dna)
```

``` biosyntax
>ref
ACGTACGT
>alt
ACGTNCGT
```

DNA and RNA use the nucleotide color scheme. Amino-acid sequences use
the CLUSTAL scheme by default.

## VariantAnnotation

``` r

path <- tempfile(fileext = ".vcf")
writeLines(c(
  "##fileformat=VCFv4.2",
  "##contig=<ID=chr1,length=1000>",
  "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO",
  "chr1\t42\t.\tA\tG\t60\tPASS\t."
), path)
vcf <- VariantAnnotation::readVcf(path, genome = "example")
biosyntax(vcf)
```

``` biosyntax
##fileformat=VCFv4.2
##fileDate=20260904
##FILTER=<ID=PASS,Description="All filters passed">
##contig=<ID=chr1,length=1000>
#CHROM POS    ID REF    ALT    QUAL   FILTER INFO
chr1 42    chr1:42_A/G   A    G    60  PASS .
```

``` r

unlink(path)
```

## GenomicRanges

``` r

gr <- GenomicRanges::GRanges("chr1:10-20")
biosyntax(gr, format = "bed")
```

``` biosyntax
chr1  9 20    . 0 .
```

## Explicit output

``` r

ansi <- as_ansi(x)
html <- as_html(x)
```
