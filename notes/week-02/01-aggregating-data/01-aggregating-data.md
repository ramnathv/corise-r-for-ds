
## Aggregating Data

**Aggregating** data involves summarizing the data at a higher level
than the original data, such as computing the `mean`, `sum`, or `count`
of values for different `groups` of data. The two primary functions that
you will use to aggregate data are:

<img src="https://i.imgur.com/BMjwi2P.png" width="100%" />

- `group_by()`: This function is used to group data by one or more
  variables. The result is a `grouped_df` object, which can then be used
  with other `dplyr` functions to aggregate the data.

- `summarize()` or `summarise()`: These functions are used to compute
  summary statistics for each group of data. For example, you can
  compute the `mean()`, `median()`, `sum()`, or `count()` of values in
  each group.

Additionally, the grammar of data manipulation provided by `tidyverse`
allows us to utilize the full power of data manipulation operations like
`mutate()`, `filter()`, `arrange()` etc. to grouped data as well.

Let us load the `tidyverse` and read the babynames data so we can use it
to explore data aggregation.

``` r
# Load packages and common utility functions
library(tidyverse)
source(here::here("_common.R"))
```

``` r
file_name_names <- here::here("data/names.csv.gz")
tbl_names <- readr::read_csv(file_name_names, show_col_types = FALSE)
tbl_names
#> # A tibble: 2,052,781 × 4
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
```

### `group_by()`: Group by one or more variables

The `group_by()` function lets you group a table by one or more columns.
Applying the `group_by` function to a table does not change its
appearance, except for adding some metadata on the grouping variables.

``` r
# Group by ONE column
tbl_names |> 
  group_by(sex)
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
```

``` r
# Group by multiple columns
tbl_names |> 
  group_by(sex, name)
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
```

### `summarize()`: Summarize each group down to one row

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
tbl_names |> 
  group_by(sex) |> 
  summarize(
    nb_births = sum(nb_births),
    nb_names = n_distinct(name)
  )
#> # A tibble: 2 × 3
#>   sex   nb_births nb_names
#>   <chr>     <dbl>    <int>
#> 1 F     179027755    69527
#> 2 M     182860478    43093
```

How about we try grouping by multiple variables? Let us compute the same
summaries, but grouping by `sex` and `year` this time.

``` r
tbl_names |> 
  group_by(sex, year) |> 
  summarize(
    nb_births = sum(nb_births),
    nb_names = n_distinct(name)
  )
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
```

It is very important to pay attention to the message that gets printed.

    #> `summarize()` has grouped output by 'sex'. You can override using the `.groups`
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
tbl_names |> 
  group_by(sex, year) |> 
  summarize(
    nb_births = sum(nb_births),
    nb_names = n_distinct(name),
    .groups = "drop"
  )
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
```

While, you can apply any of the data manipulation verbs in the
`tidyverse` to a grouped data frame, there are some that are going to be
used more than the others.

### `mutate()`: Create, modify, and delete columns

A grouped data frame is just like a normal data frame EXCEPT that any
operation you do on it is applied to each group separately. For example,
suppose you want to compute the percentage of births in a year by `sex`
and `name`. You can group by `sex` and `name` and use the `mutate()`
function to add a column for the total number of births for each group,
and then use that to compute the percentages.

Let us now `ungroup()` the data, `filter()` for names with more than
50,000 births and `arrange()` them in descending order of births, so we
can see how some names have a lion’s share of births happening in a few
years. For example, 40% of all Lunas were born in the years 2019, 2020,
and 2021

``` r
tbl_names |> 
  group_by(sex, name) |> 
  mutate(
    nb_births_total = sum(nb_births),
    pct_births_in_year = nb_births / nb_births_total
  ) |> 
  ungroup() |> 
  filter(nb_births_total > 50000) |> 
  arrange(desc(pct_births_in_year))
#> # A tibble: 130,352 × 6
#>     year name    sex   nb_births nb_births_total pct_births_in_year
#>    <dbl> <chr>   <chr>     <dbl>           <dbl>              <dbl>
#>  1  2021 Luna    F          8173           57494              0.142
#>  2  2020 Luna    F          7818           57494              0.136
#>  3  2019 Luna    F          7778           57494              0.135
#>  4  2018 Mila    F          8158           61710              0.132
#>  5  2018 Luna    F          6931           57494              0.121
#>  6  2019 Mila    F          7330           61710              0.119
#>  7  2012 Bentley M          5883           52305              0.112
#>  8  2021 Mateo   M          9112           82438              0.111
#>  9  2019 Mateo   M          9001           82438              0.109
#> 10  2020 Mateo   M          8967           82438              0.109
#> # ℹ 130,342 more rows
```

Note that it is very important to ungroup the data using `ungroup()`
before applying any data frame wide operations. It is more efficient to
operate on whole data frames and grouped operations are always going to
be slower.

### `across()`: Apply a function across multiple columns

Finally, there are situations where you might want to apply a function
across multiple columns. This is where the `across()` function comes
very handy. You can use different selector functions available to
summarize a group of columns without having to write multiple lines of
code. Shown below are two examples, where we summarize the mean of a
number of columns of the data by `cut`.

- In the first example, we select the columns to summarize across by
  name
- In the second example, we select the columns to summarize across by
  their data type.

``` r
# Summarize multiple columns by name
diamonds |> 
  group_by(cut) |> 
  summarize(across(c(carat, price), mean))
#> # A tibble: 5 × 3
#>   cut       carat price
#>   <ord>     <dbl> <dbl>
#> 1 Fair      1.05  4359.
#> 2 Good      0.849 3929.
#> 3 Very Good 0.806 3982.
#> 4 Premium   0.892 4584.
#> 5 Ideal     0.703 3458.

# Summarize multiple columns by data type
diamonds |> 
  group_by(cut) |> 
  summarize(across(where(is.numeric), mean))
#> # A tibble: 5 × 8
#>   cut       carat depth table price     x     y     z
#>   <ord>     <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 Fair      1.05   64.0  59.1 4359.  6.25  6.18  3.98
#> 2 Good      0.849  62.4  58.7 3929.  5.84  5.85  3.64
#> 3 Very Good 0.806  61.8  58.0 3982.  5.74  5.77  3.56
#> 4 Premium   0.892  61.3  58.7 4584.  5.97  5.94  3.65
#> 5 Ideal     0.703  61.7  56.0 3458.  5.51  5.52  3.40
```
