# biosyntax

Syntax highlighting for biological text in R. `biosyntax` embeds
[libbiosyntax](https://github.com/kojix2/libbiosyntax) and produces ANSI, HTML,
or semantic-span output.

Documentation: <https://kojix2.github.io/biosyntax-r/>

## Installation

```r
# install.packages("BiocManager")
BiocManager::install("kojix2/biosyntax-r")
```

## Usage

```r
library(biosyntax)

x <- biosyntax(c(
  "##fileformat=VCFv4.3",
  "chr1\t42\t.\tA\tG\t60\tPASS\tDP=12"
), format = "vcf")

x
as_ansi(x)
as_html(x)
biosyntax_spans(x)
```

`x` prints with ANSI colors in an interactive terminal and as HTML in knitr or
Quarto. Use `supported_formats()` to list formats and `syntax_classes()` to list
token classes.

## Bioconductor objects

Biostrings sequences, VariantAnnotation VCF objects, and GenomicRanges ranges
can be passed directly:

```r
dna <- Biostrings::DNAStringSet(c(ref = "ACGT", alt = "ANGT"))
biosyntax(dna)

vcf <- VariantAnnotation::readVcf("sample.vcf", genome = "hg38")
biosyntax(vcf[1:10])

gr <- GenomicRanges::GRanges("chr1:10-20")
biosyntax(gr, format = "bed")
```

These integrations use each package's existing conversion or export methods.
The Bioconductor packages are optional dependencies.

## Development

```sh
R CMD build .
R CMD check --as-cran biosyntax_*.tar.gz
```

Bioconductor requires an actively maintained email address in `DESCRIPTION`.
Replace the current GitHub no-reply address before submission.

## License

The R code is MIT licensed. The vendored libbiosyntax files in `src/` are
LGPL-2.1-or-later. See `LICENSE.note` and `inst/COPYRIGHTS`.
