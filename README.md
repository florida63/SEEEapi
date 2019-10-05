
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SEEEapi

<!-- badges: start -->

<!-- badges: end -->

The goal of SEEEapi is to provide an easy way to access the indicator
calculation services from the [French system for evaluating water
status](http://seee.eaufrance.fr/)

## Installation

You can install the released version of SEEEapi from
[GitHub](https://github.com) with:

``` r
#install.packages(remotes)
remotes::install_github("CedricMondy/SEEEapi)
```

## Example

### List of available indicators

You can list all available indicators :

``` r
library(SEEEapi)
get_indic()
#> # A tibble: 48 x 4
#>    Type               Indicator       Version `Input files`
#>    <chr>              <chr>           <chr>           <int>
#>  1 Outil d'évaluation EBio_CE_2015    1.0.0               5
#>  2 Outil d'évaluation EBio_CE_2018    1.0.0               5
#>  3 Outil d'évaluation EBio_CE_Reunion 1.0.0               4
#>  4 Outil d'évaluation EBio_PE_2015    1.0.0               4
#>  5 Outil d'évaluation EBio_PE_2018    1.0.0               4
#>  6 <NA>               I2M2            1.0.2               1
#>  7 Outil d'évaluation I2M2            1.0.3               1
#>  8 Outil d'évaluation I2M2            1.0.4               1
#>  9 Outil d'évaluation I2M2            1.0.5               1
#> 10 Outil d'évaluation IBD             1.1.0               1
#> # ... with 38 more rows
```

You can also list only the indicators from a given type:

``` r
get_indic(type = "diagnostic")
#> # A tibble: 6 x 4
#>   Type                Indicator     Version `Input files`
#>   <chr>               <chr>         <chr>           <int>
#> 1 Outil de diagnostic IIR           1.0.0               3
#> 2 Outil de diagnostic IPRplus       1.0.0               2
#> 3 Outil de diagnostic IPRplus       1.0.1               2
#> 4 Outil de diagnostic IPRplus       1.0.2               2
#> 5 Outil de diagnostic IPRplus       1.0.3               2
#> 6 Outil de diagnostic ODInvertebres 1.0.1               1
```

### Run calculations

The calculations can be executed online on the SEEE server:

``` r
calc_indic(indic      = "IPR", 
           version    = "1.0.3", 
           file_paths = c("IPR_entree_01_env.txt", "IPR_entree_02_faun.txt"))
```

    #> $info
    #> [1] "IPR v1.0.3 05/10/2019 Temps d'execution : 3.5secs"
    #> 
    #> $result
    #> # A tibble: 900 x 6
    #>    CODE_OPERATION CODE_STATION DATE      CODE_PAR LIB_PAR   RESULTAT       
    #>    <chr>          <chr>        <chr>     <chr>    <chr>     <chr>          
    #>  1 9860695        1141000      24/09/20~ <NA>     ALT       5              
    #>  2 9860695        1141000      24/09/20~ 7744     Score NER 0.161168846721~
    #>  3 9860695        1141000      24/09/20~ 7743     Score NEL 0.052334945860~
    #>  4 9860695        1141000      24/09/20~ 7644     Score NTE 2.565942961786~
    #>  5 9860695        1141000      24/09/20~ 7786     Score DIT 0.880800094018~
    #>  6 9860695        1141000      24/09/20~ 7746     Score DIO 3.475929372013~
    #>  7 9860695        1141000      24/09/20~ 7745     Score DII 4.315857327409~
    #>  8 9860695        1141000      24/09/20~ 7787     Score DTI 5.143375341550~
    #>  9 9860695        1141000      24/09/20~ 7036     IPR       16.59540888936~
    #> 10 9860163        2000011      11/10/20~ <NA>     ALT       220            
    #> # ... with 890 more rows

The calculation can also be executed locally by providing a directory
where the scripts will be saved (either using `get_algo` or directly by
`calc_indic`):

``` r
calc_indic(indic    = "IPR",
           version  = NULL,                     # default value, will use the most
                                                # recent version available
           data     = list(IPR_entree_01_env,   # can use data from the environment
                           IPR_entree_02_faun), # instead of file paths
           locally  = TRUE,
           dir_algo = "my/path/to/algos")
```
