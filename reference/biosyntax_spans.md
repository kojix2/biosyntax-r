# Inspect semantic BioSyntax spans

Returns the semantic token spans produced by libbiosyntax without
applying a particular renderer.

## Usage

``` r
biosyntax_spans(x, ...)
```

## Arguments

- x:

  A `biosyntax` object, or an object accepted by
  [`biosyntax()`](https://kojix2.github.io/biosyntax-r/reference/biosyntax.md).

- ...:

  For non-`biosyntax` inputs, arguments passed to
  [`biosyntax()`](https://kojix2.github.io/biosyntax-r/reference/biosyntax.md).

## Value

A data frame with line number, one-based byte start, inclusive byte end,
length, class ID, and semantic class name.

## Examples

``` r
biosyntax_spans("chr1\t42\t.\tA\tG", format = "vcf")
#>   line start end length class_id    class
#> 1    1     1   4      4        3    chrom
#> 2    1     6   7      2        4 position
#> 3    1     9   9      1      211     null
#> 4    1    11  11      1       41     nt_a
#> 5    1    13  13      1       43     nt_g
```
