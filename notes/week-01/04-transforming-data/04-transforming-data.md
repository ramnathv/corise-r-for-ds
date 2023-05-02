
## Transforming Data

``` r
library(tidyverse)
knitr::opts_chunk$set(comment = "#>")
```

Visualizing data is a lot of fun. However, the key to visualizing data
is getting it into a tidy format that makes it easy to visualize. Ask
any practicing data scientist and they will tell you how data
transformation is easily the most time consuming portion of their daily
workflow.

Fortunately for us, the `tidyverse` provides us with a grammar of data
transformation as well, that makes it easy to make data bend to our will
and wishes. Once you understand this grammar, you will be able to make
any dataset dance to your tunes!

Let us read in the `babynames` dataset, so we can use it in addition to
the `diamonds` dataset.

``` r
FILE_NAMES <- here::here("data/names.csv.gz")
babynames <- readr::read_csv(FILE_NAMES, show_col_types = FALSE)
babynames
```

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

We can categorize data transformation operations into FOUR groups.

1.  Manipulate
2.  Aggregate
3.  Reshape
4.  Combine

In this lesson, we will touch upon the basics of this grammar.

### Manipulating Data

The first set of operations involve manipulating rows and columns of a
table while leaving its shape, and interpretation of a cell, largely
intact. For example, suppose we want to display the `carat`, `price` and
`price_per_carat` columns for the top 5 diamonds by `price_per_carat`.
We can accomplish this using the grammar provided by the `dplyr`
package, which is a part of the `tidyverse`.

Note how the pipe operator (`|>`) allows us to pass the dataset through
a series of transformations, that together accomplish what we want. Also
note how each row in the dataset still corresponds to an `observation`,
and each cell is a `value` of a `variable`.

``` r
# Start with the diamonds data.
diamonds |> 
  # Select the columns carat and price
  select(carat, price) |> 
  # Add a new column for price_per_carat
  mutate(price_per_carat = price / carat) |> 
  # Arrange the rows in descending order of price_per_carat
  arrange(desc(price_per_carat)) |> 
  # Slice the first five rows
  slice_head(n = 5)
```

    #> # A tibble: 5 × 3
    #>   carat price price_per_carat
    #>   <dbl> <int>           <dbl>
    #> 1  1.04 18542          17829.
    #> 2  1.07 18279          17083.
    #> 3  1.03 17590          17078.
    #> 4  1.07 18114          16929.
    #> 5  1.02 17100          16765.

Let us take another example of data manipulation, this time on the
`babynames` data. Suppose, we want the most popular female names for
babies born in the year 2021. We can accomplish this by stringing
together a similar series of operations.

``` r
# Start with the babynames data
babynames |> 
  # Filter the rows for year = 2021 and sex = "F"
  filter(year == 2021, sex == "F") |> 
  # Select the columns name, sex, and nb_births
  select(name, sex, nb_births) |> 
  # Arrange the rows in descending order of nb_births
  arrange(desc(nb_births)) |> 
  # Slice the first five rows
  slice_head(n = 5)
```

    #> # A tibble: 5 × 3
    #>   name      sex   nb_births
    #>   <chr>     <chr>     <dbl>
    #> 1 Olivia    F         17728
    #> 2 Emma      F         15433
    #> 3 Charlotte F         13285
    #> 4 Amelia    F         12952
    #> 5 Ava       F         12759

A large part of transforming data will involve data manipulation
operations. This is just a trailer of what is to come, and we will learn
more about data manipulation in the next lesson.

### Aggregating Data

The second set of data manipulation operations that are extremely useful
are data aggregation operations. Unlike data manipulation operations,
aggregation operations change the underlying shape of the data.
Moreover, they change the unit of observation from individual
observations to groups.

For example, suppose we want to summarize diamonds by combination of
`cut` and `clarity`. We can group them by `cut` and `clarity` and
summarize each group by computing the `avg_price`, `avg_carat` and
`avg_price_per_carat`. The `dplyr` package provides us with the useful
functions `group_by()` and `summarize()` to accomplish what we want.

``` r
diamonds_by_cut_clarity <- 
  # Start with diamonds data
  diamonds |> 
    # Group by cut and clarity
    group_by(cut, clarity) |> 
    # Summarize each group
    summarize(
      avg_price = mean(price),
      avg_carat = mean(carat),
      avg_price_per_carat = sum(price) / sum(carat),
      .groups = "drop"
    )

diamonds_by_cut_clarity
```

    #> # A tibble: 40 × 5
    #>    cut   clarity avg_price avg_carat avg_price_per_carat
    #>    <ord> <ord>       <dbl>     <dbl>               <dbl>
    #>  1 Fair  I1          3704.     1.36                2721.
    #>  2 Fair  SI2         5174.     1.20                4298.
    #>  3 Fair  SI1         4208.     0.965               4363.
    #>  4 Fair  VS2         4175.     0.885               4716.
    #>  5 Fair  VS1         4165.     0.880               4734.
    #>  6 Fair  VVS2        3350.     0.692               4844.
    #>  7 Fair  VVS1        3871.     0.665               5824.
    #>  8 Fair  IF          1912.     0.474               4031.
    #>  9 Good  I1          3597.     1.20                2990.
    #> 10 Good  SI2         4580.     1.04                4424.
    #> # ℹ 30 more rows

Suppose, we want to get the top 5 most popular Male and Female names of
all time. Can we accomplish it with the grammar we have learnt so far?
Well, the answer is ALMOST yes. We can summarize the total number of
births by `sex` and `name`, and then use the `slice_max()` function to
slice the rows to get the top 5 rows in terms of `nb_births` for each
`sex`.

``` r
babynames_top_5 <- 
  # Start with the babynames table
  babynames |> 
    # Group by sex and name
    group_by(sex, name) |> 
    # Summarize total number of births by sex and name
    summarize(
      nb_births = sum(nb_births)
    ) |> 
    slice_max(nb_births, n = 5)
```

    #> `summarise()` has grouped output by 'sex'. You can override using the `.groups`
    #> argument.

``` r
babynames_top_5
```

    #> # A tibble: 10 × 3
    #> # Groups:   sex [2]
    #>    sex   name      nb_births
    #>    <chr> <chr>         <dbl>
    #>  1 F     Mary        4132497
    #>  2 F     Elizabeth   1661030
    #>  3 F     Patricia    1572795
    #>  4 F     Jennifer    1469379
    #>  5 F     Linda       1453755
    #>  6 M     James       5202714
    #>  7 M     John        5150510
    #>  8 M     Robert      4834094
    #>  9 M     Michael     4392696
    #> 10 M     William     4156142

You might have noticed a small difference between the `summarize` step
in these two examples. In the first example with the `diamonds` data, we
set `.groups = "drop"`. This was done to drop the grouping, since we
wanted to get the top 5 rows overall. In the second example with the
`babynames` data, we don’t set `.groups = "drop"`. This results in the
data still being grouped by the `sex` variable and that is perfect as
the `slice_max()` function can then get us the top 5 names for each
`sex`.

Once again, this is just the trailer, and we will learn a lot more about
data aggregation in later lessons. The major point I want to emphasize
here once again is how a powerful consistent grammar allows you to
handle complex transformations in a flexible manner!

### Reshaping Data

The first two operations we encountered before don’t alter the
fundamental shape of the data. The next set of operations we will learn
about are the reshaping operations, which alter the fundamental shape of
the data.

For example, suppose we want to display the `avg_price_per_carat` for
every combination of `cut` and `clarity`, where `cut` is laid out in
rows and the `clarity` is laid out in columns. We can accomplish this by
taking the `diamonds_by_cut_clarity` table and pivoting it wider, taking
the column names from `clarity`, and the cell values from
`avg_price_per_carat`.

``` r
diamonds_by_cut_clarity |> 
  pivot_wider(
    id_cols = cut,
    names_from = clarity,
    values_from = avg_price_per_carat
  )
```

    #> # A tibble: 5 × 9
    #>   cut          I1   SI2   SI1   VS2   VS1  VVS2  VVS1    IF
    #>   <ord>     <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
    #> 1 Fair      2721. 4298. 4363. 4716. 4734. 4844. 5824. 4031.
    #> 2 Good      2990. 4424. 4443. 5010. 5017. 5007. 4489. 6649.
    #> 3 Very Good 3181. 4687. 4648. 5197. 5189. 5363. 4973. 7105.
    #> 4 Premium   3067. 4847. 4903. 5458. 5654. 5797. 5294. 6390.
    #> 5 Ideal     3546. 4719. 4680. 4898. 5172. 5545. 4976. 4995.

The `tidyverse` provides several functions to reshape data and we will
learn all about it in Week 2.

### Combining Data

Finally, the last set of data transformation operations, we will learn
about are those that involve more than one dataset. We often want to
combine datasets either by joining them or stacking them. The
`tidyverse` provides several functions to accomplish this in a
consistent manner.

![types-of-joins](https://dataschool.com/assets/images/how-to-teach-people-sql/sqlJoins/sqlJoins_7.png)

We will learn more about this in Week 2.
