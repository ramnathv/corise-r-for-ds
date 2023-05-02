
## Aggregating Data

``` r
library(tidyverse)
knitr::opts_chunk$set(comment = "#>")
babynames <- here::here("data/names.csv.gz") |>     
   readr::read_csv(show_col_types = FALSE)
```

### `group_by`: Group by one or more variables

The `group_by()` function lets you group a table by one or more columns.
Applying the `group_by` function to a table does not change its
appearance, except for adding some metadata on the grouping variables.

``` r
# Group by ONE column
babynames |> 
  group_by(sex)
```

    #> # A tibble: 2,052,781 × 4
    #> # Groups:   sex [2]
    #>     year name      sex   nb_births
    #>    <dbl> <chr>     <chr>     <dbl>
    #>  1  1880 Mary      F          7065
    #>  2  1880 Anna      F          2604
    #>  3  1880 Emma      F          2003
    #>  4  1880 Elizabeth F          1939
    #>  5  1880 Minnie    F          1746
    #>  6  1880 Margaret  F          1578
    #>  7  1880 Ida       F          1472
    #>  8  1880 Alice     F          1414
    #>  9  1880 Bertha    F          1320
    #> 10  1880 Sarah     F          1288
    #> # ℹ 2,052,771 more rows

``` r
# Group by multiple columns
babynames |> 
  group_by(sex, name)
```

    #> # A tibble: 2,052,781 × 4
    #> # Groups:   sex, name [112,620]
    #>     year name      sex   nb_births
    #>    <dbl> <chr>     <chr>     <dbl>
    #>  1  1880 Mary      F          7065
    #>  2  1880 Anna      F          2604
    #>  3  1880 Emma      F          2003
    #>  4  1880 Elizabeth F          1939
    #>  5  1880 Minnie    F          1746
    #>  6  1880 Margaret  F          1578
    #>  7  1880 Ida       F          1472
    #>  8  1880 Alice     F          1414
    #>  9  1880 Bertha    F          1320
    #> 10  1880 Sarah     F          1288
    #> # ℹ 2,052,771 more rows

### `summarize`: Summarize each group down to one row

The reason we group a table by columns is to be able to manipulate it by
group. While the `group_by` function can be used in tandem with several
other manipulation functions, the most common function used is the
`summarize` function. It aggregates the data for each group such that
there is only ONE row per group.

You can use any arbitrary function inside `summarize` as long as it
collapses multiple values into a single value. For example, we can
summarize the `babynames` dataset for each `sex` in terms of the total
number of births and number of distinct names.

``` r
babynames |> 
  group_by(sex) |> 
  summarize(
    nb_births = sum(nb_births),
    nb_names = n_distinct(name)
  )
```

    #> # A tibble: 2 × 3
    #>   sex   nb_births nb_names
    #>   <chr>     <dbl>    <int>
    #> 1 F     179027755    69527
    #> 2 M     182860478    43093

How about we try grouping by multiple variables? Let us compute the same
summaries, but grouping by `sex` and `year` this time.

``` r
babynames |> 
  group_by(sex, year) |> 
  summarize(
    nb_births = sum(nb_births),
    nb_names = n_distinct(name)
  )
```

    #> `summarise()` has grouped output by 'sex'. You can override using the `.groups`
    #> argument.

    #> # A tibble: 284 × 4
    #> # Groups:   sex [2]
    #>    sex    year nb_births nb_names
    #>    <chr> <dbl>     <dbl>    <int>
    #>  1 F      1880     90994      942
    #>  2 F      1881     91953      938
    #>  3 F      1882    107847     1028
    #>  4 F      1883    112319     1054
    #>  5 F      1884    129019     1172
    #>  6 F      1885    133055     1197
    #>  7 F      1886    144533     1282
    #>  8 F      1887    145982     1306
    #>  9 F      1888    178622     1474
    #> 10 F      1889    178366     1479
    #> # ℹ 274 more rows

It is very important to pay attention to the message that gets printed.

    #> `summarise()` has grouped output by 'sex'. You can override using the `.groups`
    #> argument.

When you group by multiple variables, each summarize operation removes
only the last level of grouping. For example, in this case, the grouping
by `year` was removed, but the grouping by `sex` is still retained. This
design has some advantages as it lets us do hierarchical summaries
without having to invoke multiple `group_by` operations. However, it can
also introduce nasty surprises if you are not careful.

My recommendation would be to override this default behavior and always
drop all grouping after a summarize operation. This might add some
overhead especially if you are going to group it again. But doing that
explicitly will save you a lot of pain.

``` r
babynames |> 
  group_by(sex, year) |> 
  summarize(
    nb_births = sum(nb_births),
    nb_names = n_distinct(name),
    .groups = "drop"
  )
```

    #> # A tibble: 284 × 4
    #>    sex    year nb_births nb_names
    #>    <chr> <dbl>     <dbl>    <int>
    #>  1 F      1880     90994      942
    #>  2 F      1881     91953      938
    #>  3 F      1882    107847     1028
    #>  4 F      1883    112319     1054
    #>  5 F      1884    129019     1172
    #>  6 F      1885    133055     1197
    #>  7 F      1886    144533     1282
    #>  8 F      1887    145982     1306
    #>  9 F      1888    178622     1474
    #> 10 F      1889    178366     1479
    #> # ℹ 274 more rows
