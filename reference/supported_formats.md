# Inspect the embedded libbiosyntax engine

Reports supported biological formats, semantic token classes and the
version of the embedded libbiosyntax C engine.

## Usage

``` r
supported_formats()

syntax_classes()

biosyntax_engine_version()
```

## Value

`supported_formats()` and `syntax_classes()` return data frames.
`biosyntax_engine_version()` returns a character scalar.

## Examples

``` r
head(supported_formats())
#>   id  name            description stateful
#> 1  1 fasta         FASTA sequence    FALSE
#> 2  2 fastq            FASTQ reads     TRUE
#> 3  3   sam SAM/BAM/CRAM alignment    FALSE
#> 4  4   vcf       VCF/BCF variants    FALSE
#> 5  5   bed          BED intervals    FALSE
#> 6  6   gtf        GTF annotations    FALSE
head(syntax_classes())
#>   id     name              scope foreground background font_style
#> 1  0    plain    biosyntax.plain                                 
#> 2  1   header   biosyntax.header    #E6DB74    #3E3D32       bold
#> 3  2  comment  biosyntax.comment    #B1B1AF                italic
#> 4  3    chrom    biosyntax.chrom    #1E8449                  bold
#> 5  4 position biosyntax.position    #1E8449                      
#> 6  5     name     biosyntax.name    #CE9178                      
#>                            ansi_sgr
#> 1                                 0
#> 2 01;38;2;230;219;116;48;2;62;61;50
#> 3               03;38;2;177;177;175
#> 4                 01;38;2;30;132;73
#> 5                    38;2;30;132;73
#> 6                  38;2;206;145;120
biosyntax_engine_version()
#> [1] "0.1.1"
```
