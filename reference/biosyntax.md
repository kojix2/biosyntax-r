# Highlight biological text

Creates an object that can be rendered as ANSI, HTML, or semantic spans.

## Usage

``` r
biosyntax(x, ...)

as_ansi(x, ...)

as_html(x, ..., block = TRUE)
```

## Arguments

- x:

  A character vector, a `biosyntax` object, or a supported Bioconductor
  object. Character input requires a `format` argument.

- ...:

  Arguments passed to a class-specific method. For character input, use
  `format`, for example `format = "vcf"`.

- block:

  For `as_html()`, wrap the output in a `<pre>` block.

## Value

`biosyntax()` returns an object of class `biosyntax`. `as_ansi()`
returns one ANSI-rendered character string per input line. `as_html()`
returns a length-one HTML string inheriting from `biosyntax_html` and
`html`.

## Details

Methods support Biostrings sequences, VariantAnnotation `VCF` objects,
and GenomicRanges `GRanges` objects when their packages are installed.

## Examples

``` r
x <- biosyntax(
    c("##fileformat=VCFv4.3", "chr1\t42\t.\tA\tG\t60\tPASS\tDP=12"),
    format = "vcf"
)
print(x, color = FALSE)
#> ##fileformat=VCFv4.3
#> chr1 42  .   A   G   60  PASS    DP=12
#> 
as_html(x)
#> <pre class="biosyntax"><span class="biosyntax-comment" style="color:#B1B1AF;font-style:italic">##</span><span class="biosyntax-header" style="color:#E6DB74;background-color:#3E3D32;font-weight:700">fileformat</span>=<span class="biosyntax-header" style="color:#E6DB74;background-color:#3E3D32;font-weight:700">VCFv4.3</span>
#> <span class="biosyntax-chrom" style="color:#1E8449;font-weight:700">chr1</span>  <span class="biosyntax-position" style="color:#1E8449">42</span>    <span class="biosyntax-null" style="color:#B1B1AF">.</span> <span class="biosyntax-nt_a" style="color:#47FF19;background-color:#000000">A</span>    <span class="biosyntax-nt_g" style="color:#F09000;background-color:#000000">G</span>    <span class="biosyntax-number_alt" style="color:#AE81FF">60</span>  <span class="biosyntax-good" style="color:#4192FF;background-color:#000000">PASS</span> <span class="biosyntax-keyword6" style="color:#E6DB74">DP</span>=<span class="biosyntax-number" style="color:#0087AF">12</span></pre>
```
