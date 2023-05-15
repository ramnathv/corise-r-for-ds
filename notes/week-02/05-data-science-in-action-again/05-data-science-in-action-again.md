
## Unisex Names

<img src="https://fivethirtyeight.com/wp-content/uploads/2015/06/unisex.jpg" width="100%" />

There are some names that are used commonly by both the sexes.
FiveThirtyEight published a [blog
post](https://fivethirtyeight.com/features/there-are-922-unisex-names-in-america-is-yours-one-of-them/)
on this topic in 2015.

<img src="https://fivethirtyeight.com/wp-content/uploads/2015/06/flowers-datalab-unisexnames-1.png?w=1220" width="75%" />

Wouldn’t it be cool if we redid the same analysis, but with more data!
Let us dive into the data and figure out the most popular unisex names.
Let’s assume that a name is considered unisex if more than 33% males and
33% females have that name. We can tweak these thresholds subsequently
to see if it reveals a different set of names!

Let us load some R packages that we will need to accomplish this task.

``` r
# Load packages and common utility functions
library(tidyverse)
library(gt)
library(gtExtras)
knitr::opts_chunk$set(collapse = TRUE)
source(here::here("_common.R"))
```

### Import

As always, let’s start by importing the data from `data/names.csv.gz`.

``` r
file_name_names <- here::here('data/names.csv.gz')
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

------------------------------------------------------------------------

Note that we have two other dataset named
[data/namesbystate.csv.gz](data/namesbystate.csv.gz) and
[data/frenchnames.csv.gz](data/frenchnames.csv.gz) in the data folder.
The first dataset gives you number of births by `name`, `sex`, `year`
and US `state`, while the second dataset gives you french babynames. So
if you feel bored with this US babynames data, feel free to take an
alternate dataset for a spin.

------------------------------------------------------------------------

### Transform

Our goal is to arrive at data that has

#### Step 1

Let us start by computing the total number of births by `name` and
`sex`.

``` r
tbl_names_unisex_1 <- tbl_names |> 
  group_by(name, sex) |> 
  summarize(
    nb_births = sum(nb_births),
    .groups = 'drop'
  )

tbl_names_unisex_1
#> # A tibble: 112,620 × 3
#>    name      sex   nb_births
#>    <chr>     <chr>     <dbl>
#>  1 Aaban     M           120
#>  2 Aabha     F            51
#>  3 Aabid     M            16
#>  4 Aabidah   F             5
#>  5 Aabir     M            10
#>  6 Aabriella F            51
#>  7 Aada      F            13
#>  8 Aadam     M           320
#>  9 Aadan     M           130
#> 10 Aadarsh   M           233
#> # ℹ 112,610 more rows
```

#### Step 2

We can now pivot this data to the wide format so we can have ONE row per
name.

``` r
tbl_names_unisex_2 <- tbl_names_unisex_1 |> 
  pivot_wider(
    names_from = sex, 
    values_from = nb_births,
    names_prefix = 'nb_births_',
    values_fill = 0
  )

tbl_names_unisex_2
#> # A tibble: 101,338 × 3
#>    name      nb_births_M nb_births_F
#>    <chr>           <dbl>       <dbl>
#>  1 Aaban             120           0
#>  2 Aabha               0          51
#>  3 Aabid              16           0
#>  4 Aabidah             0           5
#>  5 Aabir              10           0
#>  6 Aabriella           0          51
#>  7 Aada                0          13
#>  8 Aadam             320           0
#>  9 Aadan             130           0
#> 10 Aadarsh           233           0
#> # ℹ 101,328 more rows
```

#### Step 3

The wide format makes it easier to compute the percentage of males and
percentage of females for each name. Additionally, let us also add a
column for the total number of births across sexes for a given name.

``` r
tbl_names_unisex_3 <- tbl_names_unisex_2 |> 
 mutate(
   nb_births_total = nb_births_M + nb_births_F,
   pct_births_M = nb_births_M / nb_births_total,
   pct_births_F = nb_births_F / nb_births_total
 )

tbl_names_unisex_3
#> # A tibble: 101,338 × 6
#>    name      nb_births_M nb_births_F nb_births_total pct_births_M pct_births_F
#>    <chr>           <dbl>       <dbl>           <dbl>        <dbl>        <dbl>
#>  1 Aaban             120           0             120            1            0
#>  2 Aabha               0          51              51            0            1
#>  3 Aabid              16           0              16            1            0
#>  4 Aabidah             0           5               5            0            1
#>  5 Aabir              10           0              10            1            0
#>  6 Aabriella           0          51              51            0            1
#>  7 Aada                0          13              13            0            1
#>  8 Aadam             320           0             320            1            0
#>  9 Aadan             130           0             130            1            0
#> 10 Aadarsh           233           0             233            1            0
#> # ℹ 101,328 more rows
```

#### Step 4

We defined a unisex name as one where the percentage of males and
percentage of females are both \>= 33%. We also add an additional
threshold for total number of births, so that we don’t pick up
low-volume idiosyncratic names.

``` r
tbl_names_unisex_4 <- tbl_names_unisex_3 |> 
  filter(
    pct_births_M > 0.3,
    pct_births_F > 0.3,
    nb_births_total > 50000
  ) |> 
  arrange(desc(nb_births_total))

tbl_names_unisex_4
#> # A tibble: 23 × 6
#>    name    nb_births_M nb_births_F nb_births_total pct_births_M pct_births_F
#>    <chr>         <dbl>       <dbl>           <dbl>        <dbl>        <dbl>
#>  1 Jessie       110714      168626          279340        0.396        0.604
#>  2 Riley         98494      123172          221666        0.444        0.556
#>  3 Casey        112422       77093          189515        0.593        0.407
#>  4 Jackie        78684       90928          169612        0.464        0.536
#>  5 Johnnie      101816       49043          150859        0.675        0.325
#>  6 Peyton        50509       80495          131004        0.386        0.614
#>  7 Jaime         69610       49914          119524        0.582        0.418
#>  8 Kerry         49770       48610           98380        0.506        0.494
#>  9 Kendall       34648       62542           97190        0.356        0.644
#> 10 Jody          31383       55775           87158        0.360        0.640
#> # ℹ 13 more rows
```

#### Step 5

Finally, we want to group by `name` and `nb_births` and `nest` the
percentages into a single column. This will make it easier to visualize
the data.

``` r
tbl_names_unisex_5 <- tbl_names_unisex_4 |> 
  select(name, nb_births_total, pct_births_M, pct_births_F) |> 
  group_by(name, nb_births_total) |> 
  nest() |> 
  ungroup()

tbl_names_unisex_5
#> # A tibble: 23 × 3
#>    name    nb_births_total data            
#>    <chr>             <dbl> <list>          
#>  1 Jessie           279340 <tibble [1 × 2]>
#>  2 Riley            221666 <tibble [1 × 2]>
#>  3 Casey            189515 <tibble [1 × 2]>
#>  4 Jackie           169612 <tibble [1 × 2]>
#>  5 Johnnie          150859 <tibble [1 × 2]>
#>  6 Peyton           131004 <tibble [1 × 2]>
#>  7 Jaime            119524 <tibble [1 × 2]>
#>  8 Kerry             98380 <tibble [1 × 2]>
#>  9 Kendall           97190 <tibble [1 × 2]>
#> 10 Jody              87158 <tibble [1 × 2]>
#> # ℹ 13 more rows
```

``` r
tbl_names_unisex_5$data[[1]]
#> # A tibble: 1 × 2
#>   pct_births_M pct_births_F
#>          <dbl>        <dbl>
#> 1        0.396        0.604
```

While we have broken down the transformations into multiple pieces so we
could focus on each piece separately, it is often better to write the
transformations as a single pipeline as it makes it easier to add,
remove, and update steps without having to go back and forth.

``` r
tbl_names_unisex <- tbl_names |> 
  # Aggregate births across `name` and `sex`
  group_by(name, sex) |> 
  summarize(
    nb_births = sum(nb_births),
    .groups = 'drop'
  ) |>
  # Pivot the table wider
  pivot_wider(
    names_from = sex, 
    names_prefix = 'nb_births_',
    values_from = nb_births, 
    values_fill = 0
  ) |> 
  # Add columns for total births and percentage male and female
  mutate(
    nb_births_total = nb_births_M + nb_births_F,
    pct_births_M = nb_births_M / nb_births_total,
    pct_births_F = nb_births_F / nb_births_total
  ) |> 
  # Filter for popular unisex names 
  # [At least 33% males and females, > 50000 total births]
  filter(
    pct_births_M > 0.33,
    pct_births_F > 0.33,
    nb_births_total > 50000
  ) |> 
  arrange(desc(nb_births_total)) |> 
  select(name, nb_births_total, pct_births_M, pct_births_F) |> 
  group_by(name, nb_births_total) |> 
  nest() |> 
  ungroup()
```

### Visualize

We are all set to visualize the data! We can use `ggplot2` to create
some lovely plots from this data. But, we are going to use another R
package named `gt` and its companion package `gtExtras` to visualize
this data as a table. The `gt` package implements a **grammar of
tables** and you will see how it can create amazing looking tables that
sometimes look better than plots.

Let us visualize this data as an html table with a stacked bar chart
that summarizes information about unisex names, and can help identify
popular names that are used relatively equally for both men and women.

``` r
tbl_names_unisex |>
  # Create an HTML table using the `gt` package
  gt::gt() |> 
  # Label columns with descriptive names
  gt::cols_label(
    name = "Name",
    nb_births_total = "Number of People"
  ) |> 
  # Format the values in `nb_births_total` to display as whole numbers
  fmt_number(nb_births_total, decimals = 0) |> 
  # Add a table column with a stacked horizontal bar plot
  gtExtras::gt_plt_bar_stack(
    data,
    width = 65,
    labels = c("MALE", "FEMALE"),
    palette= c("#2596be", "#f4ba19"),
    fmt_fn = scales::label_percent()
  ) |> 
  # Add useful title and subtitle in the table header
  gt::tab_header(
    title = md("**The Most Common Unisex Names**"),
    subtitle = "Names for which at least one-third the names were male, and
    at least one-third were female, through 2021"
  ) |> 
  # Theme the plot using 538's theme
  gtExtras::gt_theme_538()
```

<img src="https://i.imgur.com/KxQBNaU.png" width="100%" />

A detailed explanation of the code is provided below. Note that you can
always use the `?` in R to learn more about a specific function.

- `tbl_names_unisex` is a data frame that contains information about
  unisex names.
- `gt::gt()` is a function that creates a data table from the data
  frame. The resulting table will include columns for the variables in
  the data frame, and will have various formatting options applied based
  on the other functions in the code.
- `gtExtras::gt_plt_bar_stack()` is a function that adds a stacked bar
  chart to the table. The chart shows the percentage of births by sex
  for each name, and the bars are colored using the specified palette.
  The `fmt_fn` argument is used to format the y-axis labels as
  percentages.
  - `data` is the data frame to use for the chart.
  - `width` specifies the width of the chart.
  - `labels` is a vector of length 2 that specifies the labels for the
    two bars (male and female).
  - `palette` is a vector of length 2 that specifies the colors for the
    two bars.
  - `fmt_fn` is a function that is used to format the y-axis labels.
- `fmt_number()` is a function that formats one or more columns in the
  data table as numbers with a specified number of decimal places.
  - `columns` specifies the columns to format.
  - `decimals` specifies the number of decimal places to include.
- `gt::tab_header()` is a function that sets the title and subtitle for
  the table.
  - `title` is the title of the table, formatted using Markdown syntax.
  - `subtitle` is the subtitle of the table.
- `gtExtras::gt_theme_538()` is a function that applies a specific theme
  to the table, which includes various formatting options for fonts,
  colors, and layout.

## Unisex Names Trends

What if we wanted to do one better than the 538 blog post? Well, in
addition to showing the most popular unisex names, we could also display
trends in the percentage over time.

### Transform

Transforming Data is a lot like cooking. Everyone uses the same tools,
but depending on the recipe you follow, you could end up making dishes
that taste very different. Our first step here is to get a table of
unisex names just like we did before. However, this time, we are going
to use a different recipe.

#### Step 1

Begin by grouping the data by `name` and `sex` and computing the total
number of births for each `name` and `sex` combination.

``` r
tbl_names_unisex_v2_1 <- tbl_names |> 
  # Group by name and sex
  group_by(name, sex) |> 
  # Summarize the total number of births, drop the grouping
  summarize(nb_births = sum(nb_births), .groups = 'drop')
  
tbl_names_unisex_v2_1
#> # A tibble: 112,620 × 3
#>    name      sex   nb_births
#>    <chr>     <chr>     <dbl>
#>  1 Aaban     M           120
#>  2 Aabha     F            51
#>  3 Aabid     M            16
#>  4 Aabidah   F             5
#>  5 Aabir     M            10
#>  6 Aabriella F            51
#>  7 Aada      F            13
#>  8 Aadam     M           320
#>  9 Aadan     M           130
#> 10 Aadarsh   M           233
#> # ℹ 112,610 more rows
```

#### Step 2

Next, let us group the data by `name`, and compute the total number of
births for each `name`, and the percentage of births for each `sex`.

``` r
tbl_names_unisex_v2_2 <- tbl_names_unisex_v2_1 |> 
  # Group by name
  group_by(name) |> 
  # For each name, add NEW columns with number and pct of births
  mutate(
    nb_births_total = sum(nb_births),
    pct_births = nb_births / nb_births_total
  ) |> 
  # Remove the grouping
  ungroup()

tbl_names_unisex_v2_2
#> # A tibble: 112,620 × 5
#>    name      sex   nb_births nb_births_total pct_births
#>    <chr>     <chr>     <dbl>           <dbl>      <dbl>
#>  1 Aaban     M           120             120          1
#>  2 Aabha     F            51              51          1
#>  3 Aabid     M            16              16          1
#>  4 Aabidah   F             5               5          1
#>  5 Aabir     M            10              10          1
#>  6 Aabriella F            51              51          1
#>  7 Aada      F            13              13          1
#>  8 Aadam     M           320             320          1
#>  9 Aadan     M           130             130          1
#> 10 Aadarsh   M           233             233          1
#> # ℹ 112,610 more rows
```

**Understanding the Difference between Mutate and Summarize**

Note that you can use `mutate()` as well as `summarize()` after a
`group_by()`. The key difference is that `summarize()` will collapse the
data into ONE row per group, whereas `mutate()` will keep the number of
rows unchanged.

Let us understand the impact of using `summarize()` vs using `mutate()`.
We filter the data for a specific name so it is easier to look at the
output and understand its impact.

When we use summarize, the data is collapsed into ONE row. In this
example, we have a new column `nb_births_total` that summarizes the
total number of births having the name “Casey”.

Note that the only columns that survived were the grouping column and
the columns explicitly defined inside the `summarize()`.

``` r
tbl_names_unisex_v2_1 |> 
  filter(name == "Casey") |> 
  # Group by name
  group_by(name) |> 
  # For each name, add NEW columns with number and pct of births
  summarize(
    nb_births_total = sum(nb_births)
  )
#> # A tibble: 1 × 2
#>   name  nb_births_total
#>   <chr>           <dbl>
#> 1 Casey          189515
```

On the other hand, when we use `mutate()`, the all existing rows and
columns are preserved, and `nb_births_total` is added as a new column.

``` r
tbl_names_unisex_v2_1 |> 
  filter(name == "Casey") |> 
  # Group by name
  group_by(name) |> 
  # For each name, add NEW columns with number and pct of births
  mutate(
    nb_births_total = sum(nb_births)
  )
#> # A tibble: 2 × 4
#> # Groups:   name [1]
#>   name  sex   nb_births nb_births_total
#>   <chr> <chr>     <dbl>           <dbl>
#> 1 Casey F         77093          189515
#> 2 Casey M        112422          189515
```

#### Step 3

We filter the data to only keep rows

- where `sex` is `M`
- that have \>= 50,000 births
- where percentage of births is between 0.33 and 0.67 (this is
  equivalent to both M and F having more than 33% share)

``` r
tbl_names_unisex_v2_3 <- tbl_names_unisex_v2_2 |> 
  filter(sex == "F") |> 
  # Keep only names with more than 50,000 births and pct between 0.33 and 0.67
  filter(
    # Filter for pct_births between 0.33 and 0.67
    between(pct_births, 0.33, 0.67),
    # Filter for total births > 50000
    nb_births_total > 50000
  )

tbl_names_unisex_v2_3
#> # A tibble: 18 × 5
#>    name    sex   nb_births nb_births_total pct_births
#>    <chr>   <chr>     <dbl>           <dbl>      <dbl>
#>  1 Casey   F         77093          189515      0.407
#>  2 Emerson F         26304           54625      0.482
#>  3 Emery   F         31289           50366      0.621
#>  4 Frankie F         34954           76330      0.458
#>  5 Harley  F         27687           67464      0.410
#>  6 Jackie  F         90928          169612      0.536
#>  7 Jaime   F         49914          119524      0.418
#>  8 Jessie  F        168626          279340      0.604
#>  9 Jody    F         55775           87158      0.640
#> 10 Kendall F         62542           97190      0.644
#> 11 Kerry   F         48610           98380      0.494
#> 12 Pat     F         40123           66856      0.600
#> 13 Peyton  F         80495          131004      0.614
#> 14 Quinn   F         41171           75474      0.545
#> 15 Riley   F        123172          221666      0.556
#> 16 Rowan   F         17341           50053      0.346
#> 17 Skyler  F         25744           66116      0.389
#> 18 Tommie  F         17539           51859      0.338
```

We can put them together in a single data pipeline.

``` r
tbl_names_unisex_v2 <- tbl_names |> 
  # Group by name and sex
  group_by(name, sex) |> 
  # Summarize the total number of births, drop the grouping
  summarize(nb_births = sum(nb_births), .groups = 'drop') |> 
  # Group by name
  group_by(name) |> 
  # For each name, add NEW columns with number and pct of births
  mutate(
    nb_births_total = sum(nb_births),
    pct_births = nb_births / nb_births_total
  ) |> 
  # Remove the grouping
  ungroup() |> 
  # Keep rows corresponding to Males
  filter(sex == "M") |> 
  # Keep only names with more than 50,000 births and pct between 0.33 and 0.67
  filter(
    # Filter for pct_births between 0.33 and 0.67
    between(pct_births, 0.33, 0.67),
    # Filter for total births > 50000
    nb_births_total > 50000
  )
```

#### Step 4

Let us join `tbl_names` with `tbl_names_unisex` to keep only names that
are considered unisex. Then we group the resulting data by `name` and
`year` and adds new columns for the total number of births and the
percentage of births for each `name` and `year` combination.

``` r
tbl_names_unisex_trends_1 <- tbl_names |> 
  # Semi join with `tbl_names_unisex` by name
  semi_join(tbl_names_unisex, by = "name") |> 
  # Group by `name` and `year`
  group_by(name, year) |> 
  # Add columns for total number of births and pct births
  mutate(
    nb_births_total = sum(nb_births),
    pct_births = nb_births / nb_births_total
  )

tbl_names_unisex_trends_1
#> # A tibble: 3,662 × 6
#> # Groups:   name, year [2,190]
#>     year name    sex   nb_births nb_births_total pct_births
#>    <dbl> <chr>   <chr>     <dbl>           <dbl>      <dbl>
#>  1  1880 Jessie  F           635             789      0.805
#>  2  1880 Frankie F            17              17      1    
#>  3  1880 Tommie  F            10              25      0.4  
#>  4  1880 Jessie  M           154             789      0.195
#>  5  1880 Harley  M            70              70      1    
#>  6  1880 Emery   M            52              52      1    
#>  7  1880 Riley   M            41              41      1    
#>  8  1880 Emerson M            25              25      1    
#>  9  1880 Tommie  M            15              25      0.6  
#> 10  1880 Pat     M            12              12      1    
#> # ℹ 3,652 more rows
```

You can filter the data for a particular name and arrange it by year to
see what the transformations are doing.

``` r
tbl_names_unisex_trends_1 |> 
  filter(name == "Casey") |> 
  arrange(year)
#> # A tibble: 207 × 6
#> # Groups:   name, year [128]
#>     year name  sex   nb_births nb_births_total pct_births
#>    <dbl> <chr> <chr>     <dbl>           <dbl>      <dbl>
#>  1  1888 Casey M             6               6          1
#>  2  1890 Casey M             5               5          1
#>  3  1892 Casey M             7               7          1
#>  4  1894 Casey M             9               9          1
#>  5  1895 Casey M             5               5          1
#>  6  1897 Casey M             5               5          1
#>  7  1898 Casey M             6               6          1
#>  8  1900 Casey M            13              13          1
#>  9  1901 Casey M             7               7          1
#> 10  1903 Casey M            10              10          1
#> # ℹ 197 more rows
```

#### Step 5

We want to summarize the trends in percentage of males for a given
unisex name over the years. We can do this by filtering the data for
Males, grouping by `name`, and adding a list column of `pct_births`
across the years. Additionally, we add a few more useful summaries
including total number of births, percentage of male births and
percentage of female births for each name.

``` r
tbl_names_unisex_trends_2 <- tbl_names_unisex_trends_1 |> 
  # Keep only rows for Males
  filter(sex == "M") |> 
  # Group by name
  group_by(name) |> 
  # Summarize for each name
  summarize(
    # Total number of births
    nb_births_total = sum(nb_births_total),
    # List of pct_births across years
    pct_births_by_year = list(pct_births),
    # Percentage of Males
    pct_births_M = sum(nb_births) / sum(nb_births_total),
    # Percentage of Females
    pct_births_F = 1 - pct_births_M,
    .groups = 'drop'
  ) 

tbl_names_unisex_trends_2
#> # A tibble: 18 × 5
#>    name    nb_births_total pct_births_by_year pct_births_M pct_births_F
#>    <chr>             <dbl> <list>                    <dbl>        <dbl>
#>  1 Casey            189515 <dbl [128]>               0.593        0.407
#>  2 Emerson           54625 <dbl [142]>               0.518        0.482
#>  3 Emery             50366 <dbl [142]>               0.379        0.621
#>  4 Frankie           75000 <dbl [120]>               0.552        0.448
#>  5 Harley            67464 <dbl [142]>               0.590        0.410
#>  6 Jackie           169496 <dbl [114]>               0.464        0.536
#>  7 Jaime            119524 <dbl [106]>               0.582        0.418
#>  8 Jessie           279340 <dbl [142]>               0.396        0.604
#>  9 Jody              87158 <dbl [104]>               0.360        0.640
#> 10 Kendall           97190 <dbl [115]>               0.356        0.644
#> 11 Kerry             98375 <dbl [101]>               0.506        0.494
#> 12 Pat               66856 <dbl [125]>               0.400        0.600
#> 13 Peyton           131004 <dbl [121]>               0.386        0.614
#> 14 Quinn             75474 <dbl [107]>               0.455        0.545
#> 15 Riley            221666 <dbl [142]>               0.444        0.556
#> 16 Rowan             50053 <dbl [100]>               0.654        0.346
#> 17 Skyler            66116 <dbl [65]>                0.611        0.389
#> 18 Tommie            51859 <dbl [142]>               0.662        0.338
```

#### Step 6

Finally, let us group the data by `name`, `nb_births_total`, and
`pct_births_by_year`, and nest the columns `pct_births_M` and
`pct_births_F` into a single column names `pct_births`.

As a last step, we can ungroup this data, arrange it in descending order
of total births and select only the columns we need.

``` r
tbl_names_unisex_trends_3 <- tbl_names_unisex_trends_2 |> 
  # Group by name, total births and pct_births_by_year
  group_by(name, nb_births_total, pct_births_by_year) |> 
  # Nest pct_births_M and pct_births_F into a single column
  nest(pct_births = c(pct_births_M, pct_births_F)) |> 
  # Ungroup the data
  ungroup() |> 
  # Arrange in descending order of total births
  arrange(desc(nb_births_total)) |> 
  # Select the relevant columns (`name`, `nb_births_total`, percentages)
  select(name, nb_births_total, pct_births, pct_births_by_year)

tbl_names_unisex_trends_3
#> # A tibble: 18 × 4
#>    name    nb_births_total pct_births       pct_births_by_year
#>    <chr>             <dbl> <list>           <list>            
#>  1 Jessie           279340 <tibble [1 × 2]> <dbl [142]>       
#>  2 Riley            221666 <tibble [1 × 2]> <dbl [142]>       
#>  3 Casey            189515 <tibble [1 × 2]> <dbl [128]>       
#>  4 Jackie           169496 <tibble [1 × 2]> <dbl [114]>       
#>  5 Peyton           131004 <tibble [1 × 2]> <dbl [121]>       
#>  6 Jaime            119524 <tibble [1 × 2]> <dbl [106]>       
#>  7 Kerry             98375 <tibble [1 × 2]> <dbl [101]>       
#>  8 Kendall           97190 <tibble [1 × 2]> <dbl [115]>       
#>  9 Jody              87158 <tibble [1 × 2]> <dbl [104]>       
#> 10 Quinn             75474 <tibble [1 × 2]> <dbl [107]>       
#> 11 Frankie           75000 <tibble [1 × 2]> <dbl [120]>       
#> 12 Harley            67464 <tibble [1 × 2]> <dbl [142]>       
#> 13 Pat               66856 <tibble [1 × 2]> <dbl [125]>       
#> 14 Skyler            66116 <tibble [1 × 2]> <dbl [65]>        
#> 15 Emerson           54625 <tibble [1 × 2]> <dbl [142]>       
#> 16 Tommie            51859 <tibble [1 × 2]> <dbl [142]>       
#> 17 Emery             50366 <tibble [1 × 2]> <dbl [142]>       
#> 18 Rowan             50053 <tibble [1 × 2]> <dbl [100]>
```

We can throw all the steps together into a single data pipeline.

``` r
tbl_names_unisex_trends <- tbl_names |> 
  # Semi join with `tbl_names_unisex` by name
  semi_join(tbl_names_unisex, by = "name") |> 
  # Group by `name` and `year`
  group_by(name, year) |> 
  # Add columns for total number of births and pct births
  mutate(
    nb_births_total = sum(nb_births),
    pct_births = nb_births / nb_births_total
  ) |> 
  # Keep only rows for Males
  filter(sex == "M") |> 
  # Group by name
  group_by(name) |> 
  # Summarize for each name
  summarize(
    # Total number of births
    nb_births_total = sum(nb_births_total),
    # List of pct_births across years
    pct_births_by_year = list(pct_births),
    # Percentage of Males
    pct_births_M = sum(nb_births) / sum(nb_births_total),
    # Percentage of Females
    pct_births_F = 1 - pct_births_M,
    .groups = 'drop'
  ) |> 
  # Group by name, total births and pct_births_by_year
  group_by(name, nb_births_total, pct_births_by_year) |> 
  # Nest pct_births_M and pct_births_F into a single column
  nest(pct_births = c(pct_births_M, pct_births_F)) |> 
  # Ungroup the data
  ungroup() |> 
  # Arrange in descending order of total births
  arrange(desc(nb_births_total)) |> 
  # Select the relevant columns (`name`, `nb_births_total`, percentages)
  select(name, nb_births_total, pct_births, pct_births_by_year)
```

### Visualize

We can use the `gt` and `gtExtras` package just like we did before. In
addition to hte stacked bar plot column, we can also add a column of
sparklines that show trends in the percentage of males with a given
unisex name across the years. This lets us see some fascinating
patterns.

``` r
tbl_names_unisex_trends |> 
  # Create an HTML table using the `gt` package
  gt::gt() |> 
  # Label columns with descriptive names
  gt::cols_label(
    name = "Name",
    nb_births_total = "Number of People",
    pct_births_by_year = "Percent Males by Year"
  ) |> 
  # Format the values in `nb_births_total` to display as whole numebrs
  fmt_number(nb_births_total, decimals = 0) |> 
  # Add a table column with a stacked horizontal bar plot
  gtExtras::gt_plt_bar_stack(
    pct_births,
    width = 65,
    labels = c("MALE", "FEMALE"),
    palette= c("#2596be", "#f4ba19"),
    fmt_fn = scales::label_percent()
  ) |> 
  # Add a column with a sparkline of trends
  gtExtras::gt_plt_sparkline(pct_births_by_year) |> 
  # Add useful title and subtitle in the table header
  gt::tab_header(
    title = md("**The Most Common Unisex Names**"),
    subtitle = "Names for which at least one-third the names were male, and
    at least one-third were female, through 2021"
  ) |> 
  # Theme the plot using 538's theme
  gtExtras::gt_theme_538()
```

<img src="https://i.imgur.com/0rIcZ24.png" width="100%" />
