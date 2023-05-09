
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
    names_prefix = 'nb_births_',
    values_from = nb_births, 
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
    pct_births_M > 0.33,
    pct_births_F > 0.33,
    nb_births_total > 50000
  ) |> 
  arrange(desc(nb_births_total))

tbl_names_unisex_4
#> # A tibble: 18 × 6
#>    name    nb_births_M nb_births_F nb_births_total pct_births_M pct_births_F
#>    <chr>         <dbl>       <dbl>           <dbl>        <dbl>        <dbl>
#>  1 Jessie       110714      168626          279340        0.396        0.604
#>  2 Riley         98494      123172          221666        0.444        0.556
#>  3 Casey        112422       77093          189515        0.593        0.407
#>  4 Jackie        78684       90928          169612        0.464        0.536
#>  5 Peyton        50509       80495          131004        0.386        0.614
#>  6 Jaime         69610       49914          119524        0.582        0.418
#>  7 Kerry         49770       48610           98380        0.506        0.494
#>  8 Kendall       34648       62542           97190        0.356        0.644
#>  9 Jody          31383       55775           87158        0.360        0.640
#> 10 Frankie       41376       34954           76330        0.542        0.458
#> 11 Quinn         34303       41171           75474        0.455        0.545
#> 12 Harley        39777       27687           67464        0.590        0.410
#> 13 Pat           26733       40123           66856        0.400        0.600
#> 14 Skyler        40372       25744           66116        0.611        0.389
#> 15 Emerson       28321       26304           54625        0.518        0.482
#> 16 Tommie        34320       17539           51859        0.662        0.338
#> 17 Emery         19077       31289           50366        0.379        0.621
#> 18 Rowan         32712       17341           50053        0.654        0.346
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
#> # A tibble: 18 × 3
#>    name    nb_births_total data            
#>    <chr>             <dbl> <list>          
#>  1 Jessie           279340 <tibble [1 × 2]>
#>  2 Riley            221666 <tibble [1 × 2]>
#>  3 Casey            189515 <tibble [1 × 2]>
#>  4 Jackie           169612 <tibble [1 × 2]>
#>  5 Peyton           131004 <tibble [1 × 2]>
#>  6 Jaime            119524 <tibble [1 × 2]>
#>  7 Kerry             98380 <tibble [1 × 2]>
#>  8 Kendall           97190 <tibble [1 × 2]>
#>  9 Jody              87158 <tibble [1 × 2]>
#> 10 Frankie           76330 <tibble [1 × 2]>
#> 11 Quinn             75474 <tibble [1 × 2]>
#> 12 Harley            67464 <tibble [1 × 2]>
#> 13 Pat               66856 <tibble [1 × 2]>
#> 14 Skyler            66116 <tibble [1 × 2]>
#> 15 Emerson           54625 <tibble [1 × 2]>
#> 16 Tommie            51859 <tibble [1 × 2]>
#> 17 Emery             50366 <tibble [1 × 2]>
#> 18 Rowan             50053 <tibble [1 × 2]>
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

<div id="pzveloiefp" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>@import url("https://fonts.googleapis.com/css2?family=Chivo:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
#pzveloiefp table {
  font-family: Chivo, system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#pzveloiefp thead, #pzveloiefp tbody, #pzveloiefp tfoot, #pzveloiefp tr, #pzveloiefp td, #pzveloiefp th {
  border-style: none;
}

#pzveloiefp p {
  margin: 0;
  padding: 0;
}

#pzveloiefp .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: 300;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: none;
  border-top-width: 3px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#pzveloiefp .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#pzveloiefp .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#pzveloiefp .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#pzveloiefp .gt_heading {
  background-color: #FFFFFF;
  text-align: left;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#pzveloiefp .gt_bottom_border {
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#pzveloiefp .gt_col_headings {
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #000000;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#pzveloiefp .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 80%;
  font-weight: normal;
  text-transform: uppercase;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#pzveloiefp .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 80%;
  font-weight: normal;
  text-transform: uppercase;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#pzveloiefp .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#pzveloiefp .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#pzveloiefp .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #000000;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#pzveloiefp .gt_spanner_row {
  border-bottom-style: hidden;
}

#pzveloiefp .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 80%;
  font-weight: bolder;
  text-transform: uppercase;
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #000000;
  border-bottom-style: solid;
  border-bottom-width: 1px;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#pzveloiefp .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 80%;
  font-weight: bolder;
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #000000;
  border-bottom-style: solid;
  border-bottom-width: 1px;
  border-bottom-color: #FFFFFF;
  vertical-align: middle;
}

#pzveloiefp .gt_from_md > :first-child {
  margin-top: 0;
}

#pzveloiefp .gt_from_md > :last-child {
  margin-bottom: 0;
}

#pzveloiefp .gt_row {
  padding-top: 3px;
  padding-bottom: 3px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#pzveloiefp .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 80%;
  font-weight: bolder;
  text-transform: uppercase;
  border-right-style: solid;
  border-right-width: 0px;
  border-right-color: #FFFFFF;
  padding-left: 5px;
  padding-right: 5px;
}

#pzveloiefp .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#pzveloiefp .gt_row_group_first td {
  border-top-width: 2px;
}

#pzveloiefp .gt_row_group_first th {
  border-top-width: 2px;
}

#pzveloiefp .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#pzveloiefp .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#pzveloiefp .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#pzveloiefp .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#pzveloiefp .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#pzveloiefp .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#pzveloiefp .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#pzveloiefp .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#pzveloiefp .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#pzveloiefp .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#pzveloiefp .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#pzveloiefp .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#pzveloiefp .gt_sourcenote {
  font-size: 12px;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#pzveloiefp .gt_left {
  text-align: left;
}

#pzveloiefp .gt_center {
  text-align: center;
}

#pzveloiefp .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#pzveloiefp .gt_font_normal {
  font-weight: normal;
}

#pzveloiefp .gt_font_bold {
  font-weight: bold;
}

#pzveloiefp .gt_font_italic {
  font-style: italic;
}

#pzveloiefp .gt_super {
  font-size: 65%;
}

#pzveloiefp .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#pzveloiefp .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#pzveloiefp .gt_indent_1 {
  text-indent: 5px;
}

#pzveloiefp .gt_indent_2 {
  text-indent: 10px;
}

#pzveloiefp .gt_indent_3 {
  text-indent: 15px;
}

#pzveloiefp .gt_indent_4 {
  text-indent: 20px;
}

#pzveloiefp .gt_indent_5 {
  text-indent: 25px;
}

tbody tr:last-child {
  border-bottom: 2px solid #ffffff00;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_heading">
      <td colspan="3" class="gt_heading gt_title gt_font_normal" style><strong>The Most Common Unisex Names</strong></td>
    </tr>
    <tr class="gt_heading">
      <td colspan="3" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style>Names for which at least one-third the names were male, and
    at least one-third were female, through 2021</td>
    </tr>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="border-top-width: 0px; border-top-style: solid; border-top-color: black;" scope="col" id="Name">Name</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="border-top-width: 0px; border-top-style: solid; border-top-color: black;" scope="col" id="Number of People">Number of People</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-top-width: 0px; border-top-style: solid; border-top-color: black;" scope="col" id="&lt;span style='color:#2596be'&gt;&lt;b&gt;MALE&lt;/b&gt;&lt;/span&gt;||&lt;span style='color:#f4ba19'&gt;&lt;b&gt;FEMALE&lt;/b&gt;&lt;/span&gt;"><span style='color:#2596be'><b>MALE</b></span>||<span style='color:#f4ba19'><b>FEMALE</b></span></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="name" class="gt_row gt_left">Jessie</td>
<td headers="nb_births_total" class="gt_row gt_right">279,340</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='73.03' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='73.03' y='0.0000000000000018' width='111.23' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='36.51' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>40%</text><text x='128.64' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>60%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Riley</td>
<td headers="nb_births_total" class="gt_row gt_right">221,666</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='81.87' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='81.87' y='0.0000000000000018' width='102.38' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='40.93' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>44%</text><text x='133.06' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>56%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Casey</td>
<td headers="nb_births_total" class="gt_row gt_right">189,515</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='109.30' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='109.30' y='0.0000000000000018' width='74.95' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='54.65' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>59%</text><text x='146.78' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>41%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Jackie</td>
<td headers="nb_births_total" class="gt_row gt_right">169,612</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='85.48' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='85.48' y='0.0000000000000018' width='98.78' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='42.74' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>46.4%</text><text x='134.86' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>53.6%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Peyton</td>
<td headers="nb_births_total" class="gt_row gt_right">131,004</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='71.04' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='71.04' y='0.0000000000000018' width='113.21' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='35.52' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>39%</text><text x='127.65' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>61%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Jaime</td>
<td headers="nb_births_total" class="gt_row gt_right">119,524</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='107.31' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='107.31' y='0.0000000000000018' width='76.94' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='53.65' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>58%</text><text x='145.78' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>42%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Kerry</td>
<td headers="nb_births_total" class="gt_row gt_right">98,380</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='93.21' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='93.21' y='0.0000000000000018' width='91.04' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='46.61' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>50.6%</text><text x='138.73' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>49.4%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Kendall</td>
<td headers="nb_births_total" class="gt_row gt_right">97,190</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='65.69' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='65.69' y='0.0000000000000018' width='118.57' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='32.84' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>36%</text><text x='124.97' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>64%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Jody</td>
<td headers="nb_births_total" class="gt_row gt_right">87,158</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='66.34' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='66.34' y='0.0000000000000018' width='117.91' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='33.17' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>36%</text><text x='125.30' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>64%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Frankie</td>
<td headers="nb_births_total" class="gt_row gt_right">76,330</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='99.88' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='99.88' y='0.0000000000000018' width='84.37' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='49.94' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>54.2%</text><text x='142.06' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>45.8%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Quinn</td>
<td headers="nb_births_total" class="gt_row gt_right">75,474</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='83.74' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='83.74' y='0.0000000000000018' width='100.51' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='41.87' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>45.5%</text><text x='134.00' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>54.5%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Harley</td>
<td headers="nb_births_total" class="gt_row gt_right">67,464</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='108.64' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='108.64' y='0.0000000000000018' width='75.62' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='54.32' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>59%</text><text x='146.44' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>41%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Pat</td>
<td headers="nb_births_total" class="gt_row gt_right">66,856</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='73.67' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='73.67' y='0.0000000000000018' width='110.58' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='36.84' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>40%</text><text x='128.96' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>60%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Skyler</td>
<td headers="nb_births_total" class="gt_row gt_right">66,116</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='112.51' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='112.51' y='0.0000000000000018' width='71.74' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='56.25' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>61%</text><text x='148.38' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>39%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Emerson</td>
<td headers="nb_births_total" class="gt_row gt_right">54,625</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='95.53' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='95.53' y='0.0000000000000018' width='88.72' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='47.76' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>51.8%</text><text x='139.89' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>48.2%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Tommie</td>
<td headers="nb_births_total" class="gt_row gt_right">51,859</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='121.94' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='121.94' y='0.0000000000000018' width='62.32' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='60.97' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>66%</text><text x='153.09' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>34%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Emery</td>
<td headers="nb_births_total" class="gt_row gt_right">50,366</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='69.79' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='69.79' y='0.0000000000000018' width='114.46' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='34.89' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>38%</text><text x='127.02' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>62%</text></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Rowan</td>
<td headers="nb_births_total" class="gt_row gt_right">50,053</td>
<td headers="data" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='120.42' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='120.42' y='0.0000000000000018' width='63.83' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='60.21' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>65%</text><text x='152.33' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>35%</text></g></svg></td></tr>
  </tbody>
  
  
</table>
</div>

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

#### Step 3

We filter the data to only keep rows

- where `sex` is `M`
- that have \>= 50,000 births
- where percentage of births is between 0.33 and 0.67 (this is
  equivalent to both M and F having more than 33% share)

``` r
tbl_names_unisex_v2_3 <- tbl_names_unisex_v2_2 |> 
  filter(sex == "M") |> 
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
#>  1 Casey   M        112422          189515      0.593
#>  2 Emerson M         28321           54625      0.518
#>  3 Emery   M         19077           50366      0.379
#>  4 Frankie M         41376           76330      0.542
#>  5 Harley  M         39777           67464      0.590
#>  6 Jackie  M         78684          169612      0.464
#>  7 Jaime   M         69610          119524      0.582
#>  8 Jessie  M        110714          279340      0.396
#>  9 Jody    M         31383           87158      0.360
#> 10 Kendall M         34648           97190      0.356
#> 11 Kerry   M         49770           98380      0.506
#> 12 Pat     M         26733           66856      0.400
#> 13 Peyton  M         50509          131004      0.386
#> 14 Quinn   M         34303           75474      0.455
#> 15 Riley   M         98494          221666      0.444
#> 16 Rowan   M         32712           50053      0.654
#> 17 Skyler  M         40372           66116      0.611
#> 18 Tommie  M         34320           51859      0.662
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

<div id="dbgvzfontn" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>@import url("https://fonts.googleapis.com/css2?family=Chivo:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
#dbgvzfontn table {
  font-family: Chivo, system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#dbgvzfontn thead, #dbgvzfontn tbody, #dbgvzfontn tfoot, #dbgvzfontn tr, #dbgvzfontn td, #dbgvzfontn th {
  border-style: none;
}

#dbgvzfontn p {
  margin: 0;
  padding: 0;
}

#dbgvzfontn .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: 300;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: none;
  border-top-width: 3px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#dbgvzfontn .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#dbgvzfontn .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#dbgvzfontn .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#dbgvzfontn .gt_heading {
  background-color: #FFFFFF;
  text-align: left;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#dbgvzfontn .gt_bottom_border {
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#dbgvzfontn .gt_col_headings {
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #000000;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#dbgvzfontn .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 80%;
  font-weight: normal;
  text-transform: uppercase;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#dbgvzfontn .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 80%;
  font-weight: normal;
  text-transform: uppercase;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#dbgvzfontn .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#dbgvzfontn .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#dbgvzfontn .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #000000;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#dbgvzfontn .gt_spanner_row {
  border-bottom-style: hidden;
}

#dbgvzfontn .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 80%;
  font-weight: bolder;
  text-transform: uppercase;
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #000000;
  border-bottom-style: solid;
  border-bottom-width: 1px;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#dbgvzfontn .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 80%;
  font-weight: bolder;
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #000000;
  border-bottom-style: solid;
  border-bottom-width: 1px;
  border-bottom-color: #FFFFFF;
  vertical-align: middle;
}

#dbgvzfontn .gt_from_md > :first-child {
  margin-top: 0;
}

#dbgvzfontn .gt_from_md > :last-child {
  margin-bottom: 0;
}

#dbgvzfontn .gt_row {
  padding-top: 3px;
  padding-bottom: 3px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#dbgvzfontn .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 80%;
  font-weight: bolder;
  text-transform: uppercase;
  border-right-style: solid;
  border-right-width: 0px;
  border-right-color: #FFFFFF;
  padding-left: 5px;
  padding-right: 5px;
}

#dbgvzfontn .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#dbgvzfontn .gt_row_group_first td {
  border-top-width: 2px;
}

#dbgvzfontn .gt_row_group_first th {
  border-top-width: 2px;
}

#dbgvzfontn .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#dbgvzfontn .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#dbgvzfontn .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#dbgvzfontn .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#dbgvzfontn .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#dbgvzfontn .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#dbgvzfontn .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#dbgvzfontn .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#dbgvzfontn .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#dbgvzfontn .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#dbgvzfontn .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#dbgvzfontn .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#dbgvzfontn .gt_sourcenote {
  font-size: 12px;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#dbgvzfontn .gt_left {
  text-align: left;
}

#dbgvzfontn .gt_center {
  text-align: center;
}

#dbgvzfontn .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#dbgvzfontn .gt_font_normal {
  font-weight: normal;
}

#dbgvzfontn .gt_font_bold {
  font-weight: bold;
}

#dbgvzfontn .gt_font_italic {
  font-style: italic;
}

#dbgvzfontn .gt_super {
  font-size: 65%;
}

#dbgvzfontn .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#dbgvzfontn .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#dbgvzfontn .gt_indent_1 {
  text-indent: 5px;
}

#dbgvzfontn .gt_indent_2 {
  text-indent: 10px;
}

#dbgvzfontn .gt_indent_3 {
  text-indent: 15px;
}

#dbgvzfontn .gt_indent_4 {
  text-indent: 20px;
}

#dbgvzfontn .gt_indent_5 {
  text-indent: 25px;
}

tbody tr:last-child {
  border-bottom: 2px solid #ffffff00;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_heading">
      <td colspan="4" class="gt_heading gt_title gt_font_normal" style><strong>The Most Common Unisex Names</strong></td>
    </tr>
    <tr class="gt_heading">
      <td colspan="4" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style>Names for which at least one-third the names were male, and
    at least one-third were female, through 2021</td>
    </tr>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="border-top-width: 0px; border-top-style: solid; border-top-color: black;" scope="col" id="Name">Name</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="border-top-width: 0px; border-top-style: solid; border-top-color: black;" scope="col" id="Number of People">Number of People</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-top-width: 0px; border-top-style: solid; border-top-color: black;" scope="col" id="&lt;span style='color:#2596be'&gt;&lt;b&gt;MALE&lt;/b&gt;&lt;/span&gt;||&lt;span style='color:#f4ba19'&gt;&lt;b&gt;FEMALE&lt;/b&gt;&lt;/span&gt;"><span style='color:#2596be'><b>MALE</b></span>||<span style='color:#f4ba19'><b>FEMALE</b></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-top-width: 0px; border-top-style: solid; border-top-color: black;" scope="col" id="Percent Males by Year">Percent Males by Year</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="name" class="gt_row gt_left">Jessie</td>
<td headers="nb_births_total" class="gt_row gt_right">279,340</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='73.03' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='73.03' y='0.0000000000000018' width='111.23' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='36.51' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>40%</text><text x='128.64' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>60%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.79' y='11.28' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='13.65px' lengthAdjust='spacingAndGlyphs'>0.29</text><polyline points='4.19,10.68 4.63,10.87 5.06,10.71 5.50,11.14 5.94,11.00 6.37,10.90 6.81,11.15 7.25,11.15 7.68,10.91 8.12,11.21 8.55,11.05 8.99,10.97 9.43,10.99 9.86,11.18 10.30,10.79 10.73,11.09 11.17,10.94 11.61,11.02 12.04,10.89 12.48,10.69 12.92,10.42 13.35,10.94 13.79,10.56 14.22,10.75 14.66,10.55 15.10,10.58 15.53,10.57 15.97,10.33 16.40,10.58 16.84,10.12 17.28,10.07 17.71,10.15 18.15,10.06 18.59,10.25 19.02,10.09 19.46,9.86 19.89,9.85 20.33,9.73 20.77,9.73 21.20,9.59 21.64,9.28 22.07,9.31 22.51,9.16 22.95,9.19 23.38,9.35 23.82,9.18 24.26,9.13 24.69,9.11 25.13,8.77 25.56,8.76 26.00,8.68 26.44,8.47 26.87,8.40 27.31,8.72 27.74,8.67 28.18,8.37 28.62,8.55 29.05,8.41 29.49,8.46 29.93,8.09 30.36,8.07 30.80,8.06 31.23,8.22 31.67,7.82 32.11,7.78 32.54,7.78 32.98,7.72 33.41,7.60 33.85,7.27 34.29,7.35 34.72,7.10 35.16,7.20 35.60,6.88 36.03,6.86 36.47,6.60 36.90,6.64 37.34,6.17 37.78,5.94 38.21,5.86 38.65,6.00 39.08,5.72 39.52,5.47 39.96,5.37 40.39,5.20 40.83,5.26 41.27,5.70 41.70,5.63 42.14,5.34 42.57,5.23 43.01,5.08 43.45,5.30 43.88,5.37 44.32,5.08 44.75,5.34 45.19,5.39 45.63,5.54 46.06,5.71 46.50,5.60 46.94,6.44 47.37,6.37 47.81,6.52 48.24,7.24 48.68,6.92 49.12,6.60 49.55,7.06 49.99,7.28 50.42,7.70 50.86,7.47 51.30,7.53 51.73,7.37 52.17,7.01 52.61,7.19 53.04,7.46 53.48,7.40 53.91,8.00 54.35,7.97 54.79,7.65 55.22,7.65 55.66,7.74 56.10,7.99 56.53,8.15 56.97,7.41 57.40,7.43 57.84,7.29 58.28,7.50 58.71,6.92 59.15,7.25 59.58,7.15 60.02,7.36 60.46,7.10 60.89,7.42 61.33,7.90 61.77,8.09 62.20,8.40 62.64,8.90 63.07,9.18 63.51,9.01 63.95,9.28 64.38,9.70 64.82,9.33 65.25,9.70 65.69,9.68 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='9.68' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='8.12' cy='11.21' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='43.01' cy='5.08' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Riley</td>
<td headers="nb_births_total" class="gt_row gt_right">221,666</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='81.87' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='81.87' y='0.0000000000000018' width='102.38' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='40.93' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>44%</text><text x='133.06' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>56%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.79' y='12.05' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.2</text><polyline points='4.19,1.84 4.63,1.84 5.06,1.84 5.50,1.84 5.94,1.84 6.37,1.84 6.81,1.84 7.25,1.84 7.68,1.84 8.12,1.84 8.55,1.84 8.99,1.84 9.43,1.84 9.86,1.84 10.30,1.84 10.73,1.84 11.17,1.84 11.61,1.84 12.04,1.84 12.48,1.84 12.92,1.84 13.35,1.84 13.79,1.84 14.22,1.84 14.66,1.84 15.10,1.84 15.53,1.84 15.97,1.84 16.40,1.84 16.84,1.84 17.28,1.84 17.71,1.84 18.15,1.84 18.59,1.84 19.02,1.84 19.46,1.84 19.89,1.84 20.33,1.84 20.77,1.84 21.20,1.84 21.64,1.84 22.07,1.84 22.51,1.84 22.95,2.14 23.38,1.84 23.82,1.84 24.26,1.84 24.69,1.84 25.13,1.84 25.56,2.23 26.00,2.17 26.44,1.84 26.87,1.84 27.31,1.84 27.74,1.84 28.18,1.84 28.62,1.84 29.05,2.29 29.49,1.84 29.93,1.84 30.36,1.84 30.80,2.14 31.23,2.18 31.67,2.15 32.11,1.84 32.54,1.84 32.98,1.84 33.41,2.18 33.85,1.84 34.29,1.84 34.72,1.84 35.16,2.20 35.60,2.29 36.03,1.84 36.47,1.84 36.90,1.84 37.34,1.84 37.78,2.29 38.21,1.84 38.65,1.84 39.08,1.84 39.52,1.84 39.96,1.84 40.39,1.84 40.83,1.84 41.27,2.67 41.70,1.84 42.14,1.84 42.57,2.39 43.01,1.84 43.45,1.84 43.88,1.84 44.32,1.84 44.75,2.73 45.19,2.78 45.63,2.86 46.06,2.52 46.50,2.78 46.94,2.63 47.37,2.82 47.81,2.92 48.24,3.12 48.68,3.53 49.12,3.39 49.55,2.72 49.99,3.61 50.42,4.00 50.86,3.55 51.30,3.93 51.73,4.04 52.17,4.32 52.61,4.57 53.04,4.96 53.48,4.99 53.91,5.38 54.35,5.53 54.79,5.40 55.22,5.91 55.66,6.06 56.10,6.65 56.53,6.53 56.97,6.83 57.40,7.30 57.84,7.44 58.28,7.86 58.71,7.94 59.15,7.72 59.58,8.07 60.02,8.24 60.46,8.41 60.89,8.47 61.33,8.35 61.77,8.72 62.20,9.08 62.64,9.12 63.07,9.89 63.51,10.69 63.95,10.77 64.38,10.67 64.82,10.70 65.25,10.59 65.69,10.45 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='10.45' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='63.95' cy='10.77' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.19' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.63' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.06' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.50' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.94' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.37' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.25' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.68' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.12' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.55' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.99' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.43' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.86' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.30' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.73' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.17' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.61' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.48' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.92' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.35' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.79' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.22' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.66' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.10' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.53' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.97' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.40' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.84' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.28' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.71' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.15' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.59' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.02' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.89' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.33' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.77' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.64' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.07' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.51' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='23.38' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='23.82' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.26' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.69' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.13' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.44' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.87' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.31' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.74' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.18' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.62' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.49' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.93' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='30.36' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.11' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.54' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.98' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='33.85' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='34.29' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='34.72' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.03' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.47' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.90' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='37.34' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='38.21' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='38.65' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.08' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.52' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.96' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='40.39' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='40.83' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='41.70' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='42.14' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='43.01' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='43.45' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='43.88' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='44.32' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Casey</td>
<td headers="nb_births_total" class="gt_row gt_right">189,515</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='109.30' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='109.30' y='0.0000000000000018' width='74.95' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='54.65' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>59%</text><text x='146.78' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>41%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.79' y='6.37' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.7</text><polyline points='4.23,1.84 4.71,1.84 5.20,1.84 5.68,1.84 6.16,1.84 6.65,1.84 7.13,1.84 7.62,1.84 8.10,1.84 8.58,1.84 9.07,1.84 9.55,1.84 10.04,1.84 10.52,1.84 11.00,1.84 11.49,1.84 11.97,1.84 12.46,1.84 12.94,1.84 13.42,1.84 13.91,1.84 14.39,1.84 14.87,1.84 15.36,1.84 15.84,1.84 16.33,1.84 16.81,1.84 17.29,3.09 17.78,1.84 18.26,1.84 18.75,1.84 19.23,1.84 19.71,1.84 20.20,3.45 20.68,1.84 21.17,1.84 21.65,1.84 22.13,1.84 22.62,1.84 23.10,1.84 23.59,1.84 24.07,1.84 24.55,1.84 25.04,1.84 25.52,1.84 26.01,1.84 26.49,1.84 26.97,1.84 27.46,2.75 27.94,3.24 28.43,3.26 28.91,1.84 29.39,1.84 29.88,1.84 30.36,2.86 30.84,3.53 31.33,3.16 31.81,2.99 32.30,3.32 32.78,3.46 33.26,3.22 33.75,2.97 34.23,3.48 34.72,3.33 35.20,3.42 35.68,3.79 36.17,3.81 36.65,3.41 37.14,3.29 37.62,3.48 38.10,3.43 38.59,3.26 39.07,3.45 39.56,3.86 40.04,4.12 40.52,4.25 41.01,4.17 41.49,4.25 41.98,5.28 42.46,5.43 42.94,5.38 43.43,5.18 43.91,4.87 44.39,4.78 44.88,5.55 45.36,6.11 45.85,6.27 46.33,6.32 46.81,6.45 47.30,6.69 47.78,6.49 48.27,6.40 48.75,7.07 49.23,7.08 49.72,6.65 50.20,6.72 50.69,6.69 51.17,6.54 51.65,6.86 52.14,6.76 52.62,6.99 53.11,7.34 53.59,7.43 54.07,7.46 54.56,7.51 55.04,6.99 55.53,6.83 56.01,6.81 56.49,6.50 56.98,6.68 57.46,6.14 57.95,6.36 58.43,6.44 58.91,6.39 59.40,6.34 59.88,6.32 60.36,6.31 60.85,6.44 61.33,6.12 61.82,6.27 62.30,6.27 62.78,6.23 63.27,6.13 63.75,5.69 64.24,6.05 64.72,5.72 65.20,5.10 65.69,4.77 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='4.77' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='54.56' cy='7.51' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.23' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.71' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.68' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.16' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.65' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.13' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.62' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.10' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.58' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.07' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.55' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.52' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.00' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.49' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.97' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.94' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.42' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.91' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.39' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.87' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.36' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.84' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.33' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.78' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.26' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.75' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.23' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.71' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.68' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.17' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.65' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.13' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.62' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='23.10' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='23.59' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.07' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.55' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.52' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.01' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.49' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.97' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.91' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.39' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.88' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Jackie</td>
<td headers="nb_births_total" class="gt_row gt_right">169,496</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='85.53' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='85.53' y='0.0000000000000018' width='98.72' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='42.77' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>46.4%</text><text x='134.89' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>53.6%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.78' y='9.01' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='13.65px' lengthAdjust='spacingAndGlyphs'>0.49</text><polyline points='4.27,10.63 4.82,10.87 5.36,11.68 5.90,10.32 6.45,10.55 6.99,11.00 7.53,9.66 8.08,11.36 8.62,10.90 9.16,10.98 9.71,10.89 10.25,10.26 10.79,10.49 11.34,10.45 11.88,8.98 12.43,8.54 12.97,8.23 13.51,7.24 14.06,7.11 14.60,7.13 15.14,6.44 15.69,6.19 16.23,6.14 16.77,5.79 17.32,5.55 17.86,5.61 18.40,5.73 18.95,5.11 19.49,5.61 20.03,5.48 20.58,5.72 21.12,5.68 21.66,5.60 22.21,5.77 22.75,6.22 23.29,6.58 23.84,6.59 24.38,6.87 24.92,6.99 25.47,6.84 26.01,6.72 26.56,6.17 27.10,6.22 27.64,6.42 28.19,6.64 28.73,6.97 29.27,7.00 29.82,7.04 30.36,7.51 30.90,8.22 31.45,8.86 31.99,9.01 32.53,9.37 33.08,10.23 33.62,10.16 34.16,9.82 34.71,10.27 35.25,9.91 35.79,9.66 36.34,9.26 36.88,9.39 37.42,8.95 37.97,8.92 38.51,8.68 39.06,8.47 39.60,8.36 40.14,8.52 40.69,8.44 41.23,8.06 41.77,8.47 42.32,8.70 42.86,8.76 43.40,8.41 43.95,8.75 44.49,9.18 45.03,9.22 45.58,9.03 46.12,9.11 46.66,8.94 47.21,9.49 47.75,9.29 48.29,8.99 48.84,8.81 49.38,8.44 49.92,8.74 50.47,8.57 51.01,8.09 51.55,8.37 52.10,8.30 52.64,7.30 53.19,6.94 53.73,7.23 54.27,6.41 54.82,6.58 55.36,7.61 55.90,7.10 56.45,7.95 56.99,7.63 57.53,7.31 58.08,7.87 58.62,8.04 59.16,8.03 59.71,8.28 60.25,8.63 60.79,6.89 61.34,8.49 61.88,8.44 62.42,7.48 62.97,7.52 63.51,7.86 64.05,7.63 64.60,8.01 65.14,8.31 65.69,7.41 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='7.41' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='5.36' cy='11.68' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='18.95' cy='5.11' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Peyton</td>
<td headers="nb_births_total" class="gt_row gt_right">131,004</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='71.04' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='71.04' y='0.0000000000000018' width='113.21' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='35.52' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>39%</text><text x='127.65' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>61%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.78' y='12.34' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.2</text><polyline points='4.25,1.84 4.76,1.84 5.27,1.84 5.79,1.84 6.30,1.84 6.81,1.84 7.32,1.84 7.83,1.84 8.35,1.84 8.86,1.84 9.37,1.84 9.88,1.84 10.39,1.84 10.91,1.84 11.42,1.84 11.93,1.84 12.44,1.84 12.95,1.84 13.46,1.84 13.98,1.84 14.49,1.84 15.00,1.84 15.51,1.84 16.02,1.84 16.54,1.84 17.05,1.84 17.56,1.84 18.07,1.84 18.58,1.84 19.10,1.84 19.61,1.84 20.12,1.84 20.63,1.84 21.14,1.84 21.66,1.84 22.17,1.84 22.68,1.84 23.19,1.84 23.70,1.84 24.22,1.84 24.73,1.84 25.24,1.84 25.75,1.84 26.26,1.84 26.78,1.84 27.29,1.84 27.80,1.84 28.31,1.84 28.82,1.84 29.34,1.84 29.85,1.84 30.36,1.84 30.87,1.84 31.38,1.84 31.90,1.84 32.41,1.84 32.92,3.95 33.43,1.84 33.94,1.84 34.46,1.84 34.97,5.04 35.48,4.04 35.99,4.19 36.50,4.81 37.02,4.28 37.53,8.68 38.04,7.45 38.55,6.06 39.06,5.59 39.58,7.45 40.09,4.21 40.60,6.18 41.11,4.88 41.62,4.86 42.14,5.05 42.65,5.81 43.16,5.22 43.67,4.89 44.18,5.78 44.70,6.39 45.21,5.79 45.72,5.57 46.23,5.03 46.74,5.50 47.26,4.90 47.77,5.12 48.28,4.76 48.79,5.62 49.30,4.55 49.82,5.56 50.33,5.65 50.84,9.32 51.35,9.73 51.86,8.66 52.38,8.05 52.89,8.31 53.40,7.75 53.91,7.27 54.42,7.28 54.94,7.29 55.45,7.02 55.96,7.23 56.47,7.22 56.98,7.23 57.50,6.94 58.01,7.18 58.52,6.80 59.03,8.38 59.54,9.12 60.05,9.01 60.57,9.21 61.08,9.35 61.59,9.67 62.10,9.61 62.61,9.95 63.13,9.95 63.64,10.25 64.15,10.47 64.66,10.69 65.17,10.62 65.69,10.74 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='10.74' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='65.69' cy='10.74' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.25' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.76' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.27' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.79' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.30' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.32' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.83' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.35' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.86' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.37' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.88' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.39' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.91' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.42' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.93' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.44' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.95' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.98' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.49' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.00' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.51' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.02' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.54' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.05' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.56' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.07' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.58' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.10' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.61' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.12' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.63' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.14' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.66' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.17' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.68' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='23.19' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='23.70' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.22' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.73' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.24' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.75' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.26' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.78' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.29' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.80' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.31' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.82' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.34' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.85' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='30.36' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='30.87' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='31.38' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='31.90' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.41' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='33.43' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='33.94' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='34.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Jaime</td>
<td headers="nb_births_total" class="gt_row gt_right">119,524</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='107.31' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='107.31' y='0.0000000000000018' width='76.94' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='53.65' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>58%</text><text x='145.78' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>42%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.78' y='4.66' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.9</text><polyline points='4.30,1.84 4.89,1.84 5.47,1.84 6.06,1.84 6.64,1.84 7.23,1.84 7.81,1.84 8.40,1.84 8.98,1.84 9.56,1.84 10.15,1.84 10.73,1.84 11.32,1.84 11.90,1.84 12.49,1.84 13.07,1.84 13.66,1.84 14.24,1.84 14.83,1.84 15.41,1.84 16.00,1.84 16.58,3.41 17.16,1.84 17.75,1.84 18.33,1.84 18.92,1.84 19.50,1.84 20.09,1.84 20.67,1.84 21.26,2.51 21.84,3.57 22.43,3.11 23.01,2.99 23.59,3.47 24.18,3.52 24.76,3.40 25.35,2.95 25.93,3.16 26.52,3.26 27.10,3.28 27.69,3.68 28.27,3.30 28.86,3.53 29.44,3.70 30.02,3.27 30.61,3.63 31.19,3.54 31.78,3.50 32.36,3.23 32.95,3.38 33.53,3.73 34.12,3.71 34.70,3.51 35.29,3.74 35.87,3.93 36.45,3.59 37.04,3.40 37.62,3.48 38.21,3.94 38.79,6.43 39.38,11.16 39.96,10.77 40.55,10.17 41.13,9.47 41.72,8.91 42.30,8.74 42.89,8.65 43.47,8.35 44.05,8.01 44.64,8.09 45.22,7.35 45.81,7.15 46.39,6.57 46.98,6.04 47.56,6.02 48.15,5.56 48.73,5.40 49.32,5.29 49.90,5.04 50.48,5.32 51.07,4.87 51.65,4.68 52.24,4.60 52.82,4.29 53.41,4.03 53.99,3.83 54.58,3.77 55.16,3.75 55.75,3.77 56.33,3.33 56.91,3.41 57.50,3.26 58.08,3.01 58.67,3.20 59.25,2.88 59.84,3.01 60.42,2.96 61.01,3.11 61.59,3.03 62.18,2.96 62.76,2.73 63.34,2.84 63.93,3.17 64.51,2.77 65.10,2.88 65.68,3.06 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.68' cy='3.06' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='39.38' cy='11.16' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.30' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.89' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.47' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.06' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.64' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.23' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.40' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.98' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.56' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.15' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.73' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.32' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.90' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.49' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.07' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.66' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.24' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.83' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.41' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.00' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.16' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.75' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.33' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.92' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.50' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.09' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.67' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Kerry</td>
<td headers="nb_births_total" class="gt_row gt_right">98,375</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='93.22' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='93.22' y='0.0000000000000018' width='91.03' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='46.61' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>50.6%</text><text x='138.73' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>49.4%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.78' y='6.33' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.7</text><polyline points='4.33,1.84 4.94,1.84 5.55,1.84 6.17,1.84 6.78,5.13 7.39,1.84 8.01,4.73 8.62,1.84 9.23,1.84 9.85,1.84 10.46,1.84 11.07,4.49 11.69,1.84 12.30,3.16 12.92,2.31 13.53,2.85 14.14,3.55 14.76,3.33 15.37,2.97 15.98,3.64 16.60,3.73 17.21,4.45 17.82,5.05 18.44,5.53 19.05,4.98 19.66,4.40 20.28,4.23 20.89,4.77 21.51,5.13 22.12,5.25 22.73,5.06 23.35,5.38 23.96,5.25 24.57,4.69 25.19,4.89 25.80,5.34 26.41,5.33 27.03,5.78 27.64,5.32 28.25,5.18 28.87,5.57 29.48,5.84 30.10,6.27 30.71,6.56 31.32,6.07 31.94,6.83 32.55,7.64 33.16,8.60 33.78,9.04 34.39,9.03 35.00,9.70 35.62,9.78 36.23,9.90 36.84,9.63 37.46,9.77 38.07,9.68 38.68,9.60 39.30,9.68 39.91,9.34 40.53,9.52 41.14,9.45 41.75,9.44 42.37,9.23 42.98,8.30 43.59,8.01 44.21,8.35 44.82,8.66 45.43,8.29 46.05,8.19 46.66,8.22 47.27,7.72 47.89,8.47 48.50,7.97 49.12,8.33 49.73,8.32 50.34,8.60 50.96,8.34 51.57,8.10 52.18,8.12 52.80,8.15 53.41,7.45 54.02,7.56 54.64,7.02 55.25,5.50 55.86,6.23 56.48,6.50 57.09,5.53 57.71,5.17 58.32,5.29 58.93,5.31 59.55,5.84 60.16,5.55 60.77,5.73 61.39,5.94 62.00,5.08 62.61,5.81 63.23,5.63 63.84,4.46 64.45,5.44 65.07,5.98 65.68,4.73 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.68' cy='4.73' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='36.23' cy='9.90' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.33' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.94' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.55' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.17' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.39' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.62' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.23' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.85' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.69' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Kendall</td>
<td headers="nb_births_total" class="gt_row gt_right">97,190</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='65.69' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='65.69' y='0.0000000000000018' width='118.57' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='32.84' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>36%</text><text x='124.97' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>64%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.78' y='12.78' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.2</text><polyline points='4.27,1.84 4.81,1.84 5.35,1.84 5.89,1.84 6.42,1.84 6.96,1.84 7.50,1.84 8.04,1.84 8.58,1.84 9.12,1.84 9.66,1.84 10.20,1.84 10.73,1.84 11.27,1.84 11.81,1.84 12.35,1.84 12.89,1.84 13.43,1.84 13.97,1.84 14.51,1.84 15.04,1.84 15.58,1.84 16.12,2.70 16.66,1.84 17.20,1.84 17.74,1.84 18.28,1.84 18.82,1.84 19.35,1.84 19.89,1.84 20.43,2.75 20.97,1.84 21.51,1.84 22.05,2.31 22.59,2.44 23.13,2.48 23.66,2.93 24.20,2.54 24.74,2.98 25.28,1.84 25.82,3.01 26.36,2.60 26.90,2.52 27.44,2.66 27.97,2.55 28.51,2.54 29.05,2.18 29.59,2.50 30.13,2.39 30.67,2.85 31.21,2.74 31.74,3.51 32.28,3.54 32.82,3.98 33.36,3.37 33.90,3.29 34.44,3.22 34.98,3.84 35.52,4.27 36.05,3.77 36.59,3.84 37.13,3.80 37.67,3.55 38.21,4.11 38.75,5.34 39.29,4.66 39.83,4.48 40.36,4.26 40.90,3.93 41.44,4.09 41.98,4.53 42.52,4.61 43.06,4.20 43.60,5.58 44.14,5.68 44.67,6.60 45.21,6.32 45.75,7.59 46.29,7.22 46.83,7.32 47.37,8.05 47.91,6.92 48.45,7.06 48.98,6.51 49.52,6.69 50.06,7.19 50.60,8.08 51.14,8.81 51.68,9.34 52.22,9.36 52.76,9.41 53.29,9.56 53.83,9.50 54.37,9.45 54.91,9.81 55.45,10.17 55.99,10.80 56.53,10.95 57.07,11.06 57.60,11.07 58.14,10.84 58.68,11.26 59.22,11.15 59.76,11.15 60.30,11.33 60.84,11.47 61.38,11.40 61.91,11.59 62.45,11.51 62.99,11.53 63.53,11.14 64.07,10.96 64.61,11.29 65.15,11.11 65.69,11.18 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='11.18' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='61.91' cy='11.59' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.27' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.35' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.89' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.42' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.96' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.50' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.58' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.12' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.66' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.73' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.27' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.35' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.89' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.43' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.97' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.51' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.58' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.66' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.74' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.28' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.82' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.35' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.89' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.97' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.51' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.28' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Jody</td>
<td headers="nb_births_total" class="gt_row gt_right">87,158</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='66.34' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='66.34' y='0.0000000000000018' width='117.91' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='33.17' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>36%</text><text x='125.30' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>64%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.78' y='7.00' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='13.65px' lengthAdjust='spacingAndGlyphs'>0.68</text><polyline points='4.31,1.84 4.91,1.84 5.50,6.83 6.10,8.25 6.70,1.84 7.29,1.84 7.89,5.27 8.48,7.33 9.08,5.50 9.67,1.84 10.27,6.78 10.87,5.50 11.46,7.88 12.06,9.16 12.65,10.08 13.25,9.26 13.85,9.69 14.44,9.24 15.04,9.24 15.63,8.62 16.23,8.43 16.82,7.33 17.42,9.40 18.02,9.48 18.61,9.08 19.21,9.78 19.80,9.77 20.40,9.83 21.00,9.43 21.59,8.83 22.19,9.22 22.78,9.60 23.38,10.17 23.97,10.44 24.57,10.88 25.17,10.82 25.76,11.13 26.36,11.02 26.95,11.27 27.55,11.13 28.15,10.31 28.74,9.26 29.34,8.97 29.93,9.39 30.53,10.07 31.12,9.55 31.72,9.44 32.32,9.52 32.91,9.54 33.51,8.50 34.10,8.38 34.70,7.91 35.30,8.37 35.89,7.68 36.49,8.00 37.08,8.16 37.68,8.57 38.27,8.90 38.87,8.56 39.47,8.27 40.06,8.22 40.66,8.18 41.25,8.26 41.85,8.43 42.45,8.97 43.04,8.93 43.64,8.78 44.23,8.70 44.83,7.81 45.42,7.68 46.02,7.54 46.62,7.43 47.21,6.98 47.81,6.84 48.40,7.74 49.00,7.53 49.60,6.63 50.19,7.22 50.79,6.76 51.38,6.66 51.98,6.96 52.57,6.56 53.17,6.85 53.77,5.85 54.36,6.19 54.96,5.20 55.55,5.38 56.15,5.41 56.75,4.99 57.34,4.96 57.94,4.83 58.53,5.30 59.13,4.44 59.72,5.57 60.32,5.03 60.92,4.92 61.51,4.86 62.11,4.47 62.70,5.07 63.30,4.83 63.89,4.89 64.49,6.03 65.09,5.50 65.68,5.39 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.68' cy='5.39' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='26.95' cy='11.27' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.31' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.91' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.70' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.29' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.67' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Quinn</td>
<td headers="nb_births_total" class="gt_row gt_right">75,474</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='83.74' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='83.74' y='0.0000000000000018' width='100.51' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='41.87' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>45.5%</text><text x='134.00' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>54.5%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.78' y='12.31' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.2</text><polyline points='4.30,1.84 4.88,1.84 5.46,1.84 6.04,1.84 6.62,1.84 7.20,1.84 7.77,1.84 8.35,1.84 8.93,1.84 9.51,1.84 10.09,1.84 10.67,1.84 11.25,1.84 11.83,1.84 12.41,1.84 12.99,1.84 13.57,1.84 14.14,1.84 14.72,1.84 15.30,1.84 15.88,1.84 16.46,1.84 17.04,1.84 17.62,1.84 18.20,1.84 18.78,1.84 19.36,1.84 19.94,1.84 20.51,1.84 21.09,1.84 21.67,1.84 22.25,1.84 22.83,1.84 23.41,3.87 23.99,1.84 24.57,1.84 25.15,1.84 25.73,1.84 26.31,1.84 26.88,1.84 27.46,1.84 28.04,1.84 28.62,2.72 29.20,1.84 29.78,1.84 30.36,2.88 30.94,3.51 31.52,2.77 32.10,3.74 32.68,2.99 33.25,3.37 33.83,3.81 34.41,3.07 34.99,3.60 35.57,3.67 36.15,3.16 36.73,3.32 37.31,2.86 37.89,1.84 38.47,2.54 39.05,2.88 39.62,3.32 40.20,2.40 40.78,4.99 41.36,6.26 41.94,5.39 42.52,5.57 43.10,6.52 43.68,5.72 44.26,5.80 44.84,5.33 45.42,4.45 45.99,4.40 46.57,4.68 47.15,3.79 47.73,4.14 48.31,3.85 48.89,3.85 49.47,3.95 50.05,4.18 50.63,4.58 51.21,4.00 51.79,3.87 52.36,4.66 52.94,4.61 53.52,4.48 54.10,4.54 54.68,4.79 55.26,4.79 55.84,4.91 56.42,4.84 57.00,5.21 57.58,4.96 58.16,5.46 58.73,5.35 59.31,7.42 59.89,8.43 60.47,9.33 61.05,10.08 61.63,10.02 62.21,10.25 62.79,10.37 63.37,10.62 63.95,10.65 64.53,10.69 65.10,10.85 65.68,10.71 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.68' cy='10.71' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='65.10' cy='10.85' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.30' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.88' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.62' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.77' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.35' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.93' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.51' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.09' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.67' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.25' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.83' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.41' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.99' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.57' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.14' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.72' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.30' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.88' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.62' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.78' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.36' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.94' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.51' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.09' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.67' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.25' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.83' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='23.99' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.57' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.15' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.73' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.31' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.88' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.78' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='37.89' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Frankie</td>
<td headers="nb_births_total" class="gt_row gt_right">75,000</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='101.65' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='101.65' y='0.0000000000000018' width='82.60' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='50.82' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>55%</text><text x='142.95' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>45%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.78' y='11.29' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.3</text><polyline points='4.25,11.68 4.77,11.66 5.29,12.19 5.80,12.16 6.32,12.34 6.83,11.82 7.35,11.94 7.87,11.74 8.38,12.03 8.90,11.99 9.42,11.52 9.93,11.82 10.45,11.68 10.96,11.54 11.48,11.25 12.00,11.45 12.51,11.38 13.03,11.14 13.55,10.70 14.06,10.95 14.58,10.58 15.09,10.38 15.61,10.47 16.13,10.66 16.64,10.29 17.16,9.86 17.68,9.83 18.19,9.31 18.71,9.31 19.22,9.02 19.74,8.99 20.26,9.03 20.77,8.82 21.29,8.98 21.81,8.70 22.32,8.41 22.84,8.29 23.35,8.34 23.87,8.06 24.39,7.78 24.90,7.57 25.42,7.86 25.94,7.46 26.45,6.98 26.97,6.63 27.48,6.93 28.00,6.73 28.52,6.68 29.03,6.24 29.55,6.22 30.07,6.19 30.58,6.15 31.10,5.98 31.61,5.76 32.13,5.57 32.65,5.54 33.16,5.34 33.68,4.81 34.20,4.94 34.71,4.78 35.23,4.93 35.74,4.89 36.26,4.50 36.78,5.05 37.29,4.62 37.81,4.53 38.33,4.60 38.84,4.37 39.36,4.23 39.87,4.34 40.39,4.37 40.91,4.11 41.42,4.23 41.94,4.02 42.46,4.31 42.97,4.32 43.49,4.11 44.00,3.91 44.52,3.97 45.04,3.75 45.55,3.28 46.07,3.64 46.59,3.33 47.10,3.83 47.62,3.88 48.13,3.65 48.65,4.09 49.17,4.52 49.68,4.28 50.20,4.86 50.72,5.54 51.23,5.36 51.75,5.25 52.26,5.06 52.78,5.01 53.30,5.24 53.81,5.17 54.33,5.18 54.85,4.98 55.36,5.01 55.88,5.03 56.39,4.82 56.91,5.16 57.43,4.83 57.94,4.35 58.46,4.86 58.98,4.60 59.49,4.96 60.01,5.06 60.52,5.73 61.04,6.42 61.56,5.78 62.07,7.20 62.59,8.07 63.11,8.25 63.62,8.17 64.14,8.81 64.65,9.05 65.17,9.44 65.69,9.69 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='9.69' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='6.32' cy='12.34' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='45.55' cy='3.28' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Harley</td>
<td headers="nb_births_total" class="gt_row gt_right">67,464</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='108.64' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='108.64' y='0.0000000000000018' width='75.62' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='54.32' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>59%</text><text x='146.44' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>41%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.79' y='12.33' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.2</text><polyline points='4.19,1.84 4.63,1.84 5.06,1.84 5.50,1.84 5.94,1.84 6.37,1.84 6.81,1.84 7.25,1.84 7.68,1.84 8.12,1.84 8.55,1.84 8.99,1.84 9.43,1.84 9.86,1.84 10.30,1.84 10.73,1.84 11.17,1.84 11.61,1.84 12.04,1.84 12.48,1.84 12.92,1.84 13.35,1.84 13.79,1.84 14.22,1.84 14.66,1.84 15.10,1.84 15.53,1.84 15.97,1.84 16.40,1.84 16.84,1.84 17.28,1.84 17.71,1.84 18.15,1.84 18.59,1.84 19.02,1.84 19.46,1.84 19.89,1.98 20.33,1.84 20.77,1.84 21.20,1.98 21.64,1.84 22.07,1.84 22.51,1.84 22.95,1.84 23.38,2.02 23.82,2.02 24.26,1.84 24.69,1.98 25.13,1.84 25.56,1.84 26.00,1.98 26.44,1.84 26.87,2.05 27.31,2.02 27.74,1.84 28.18,1.84 28.62,1.84 29.05,1.84 29.49,2.05 29.93,2.06 30.36,1.84 30.80,1.84 31.23,1.84 31.67,1.84 32.11,1.84 32.54,1.84 32.98,1.84 33.41,1.84 33.85,1.84 34.29,1.84 34.72,1.84 35.16,1.84 35.60,2.04 36.03,2.05 36.47,1.84 36.90,1.84 37.34,1.84 37.78,1.84 38.21,1.84 38.65,1.84 39.08,1.84 39.52,1.84 39.96,1.84 40.39,1.84 40.83,1.84 41.27,1.84 41.70,1.84 42.14,1.84 42.57,2.27 43.01,1.84 43.45,2.33 43.88,2.23 44.32,2.23 44.75,1.84 45.19,1.84 45.63,2.43 46.06,1.84 46.50,2.23 46.94,2.15 47.37,2.19 47.81,2.21 48.24,2.31 48.68,2.35 49.12,2.43 49.55,2.57 49.99,2.56 50.42,2.69 50.86,2.65 51.30,3.30 51.73,4.38 52.17,5.66 52.61,7.05 53.04,6.78 53.48,7.30 53.91,7.56 54.35,7.72 54.79,7.85 55.22,7.91 55.66,8.48 56.10,8.46 56.53,8.26 56.97,8.52 57.40,8.43 57.84,8.64 58.28,8.55 58.71,8.80 59.15,8.73 59.58,8.60 60.02,8.98 60.46,8.67 60.89,8.60 61.33,9.09 61.77,9.14 62.20,9.38 62.64,9.52 63.07,10.00 63.51,10.53 63.95,10.54 64.38,10.91 64.82,10.76 65.25,10.50 65.69,10.73 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='10.73' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='64.38' cy='10.91' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.19' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.63' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.06' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.50' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.94' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.37' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.25' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.68' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.12' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.55' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.99' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.43' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.86' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.30' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.73' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.17' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.61' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.48' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.92' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.35' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.79' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.22' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.66' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.10' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.53' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.97' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.40' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.84' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.28' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.71' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.15' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.59' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.02' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.33' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.77' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.64' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.07' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.51' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.95' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.26' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.13' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.56' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.44' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.74' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.18' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.62' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.05' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='30.36' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='30.80' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='31.23' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='31.67' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.11' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.54' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.98' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='33.41' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='33.85' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='34.29' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='34.72' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='35.16' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.47' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.90' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='37.34' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='37.78' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='38.21' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='38.65' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.08' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.52' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.96' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='40.39' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='40.83' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='41.27' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='41.70' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='42.14' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='43.01' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='44.75' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='45.19' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='46.06' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Pat</td>
<td headers="nb_births_total" class="gt_row gt_right">66,856</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='73.67' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='73.67' y='0.0000000000000018' width='110.58' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='36.84' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>40%</text><text x='128.96' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>60%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.78' y='3.44' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>1.0</text><polyline points='4.24,1.84 4.73,1.84 5.23,1.84 5.72,1.84 6.22,1.84 6.71,1.84 7.21,1.84 7.71,1.84 8.20,1.84 8.70,1.84 9.19,1.84 9.69,1.84 10.18,1.84 10.68,1.84 11.18,1.84 11.67,1.84 12.17,1.84 12.66,3.32 13.16,4.69 13.65,1.84 14.15,1.84 14.64,1.84 15.14,3.67 15.64,3.98 16.13,3.45 16.63,3.45 17.12,3.67 17.62,4.58 18.11,4.75 18.61,4.73 19.10,4.55 19.60,5.13 20.10,5.05 20.59,4.58 21.09,4.70 21.58,4.22 22.08,4.72 22.57,4.25 23.07,4.54 23.56,5.13 24.06,4.88 24.56,4.60 25.05,5.08 25.55,5.47 26.04,6.20 26.54,6.25 27.03,7.68 27.53,8.28 28.02,7.99 28.52,8.67 29.02,9.12 29.51,9.47 30.01,9.55 30.50,10.10 31.00,9.73 31.49,10.01 31.99,10.21 32.48,10.19 32.98,10.46 33.48,10.50 33.97,10.57 34.47,10.43 34.96,10.34 35.46,10.41 35.95,10.22 36.45,10.14 36.94,10.08 37.44,9.72 37.94,9.28 38.43,8.14 38.93,7.71 39.42,7.42 39.92,7.09 40.41,6.75 40.91,7.12 41.40,7.57 41.90,7.44 42.40,8.03 42.89,7.91 43.39,7.48 43.88,6.56 44.38,6.20 44.87,5.89 45.37,5.10 45.86,4.78 46.36,4.46 46.86,4.09 47.35,3.82 47.85,3.80 48.34,3.52 48.84,3.53 49.33,4.57 49.83,4.29 50.32,4.66 50.82,5.64 51.32,4.23 51.81,4.37 52.31,4.87 52.80,4.95 53.30,5.01 53.79,4.89 54.29,1.84 54.78,4.89 55.28,5.50 55.78,4.58 56.27,4.28 56.77,5.63 57.26,4.37 57.76,1.84 58.25,4.58 58.75,1.84 59.25,3.96 59.74,1.84 60.24,1.84 60.73,1.84 61.23,1.84 61.72,1.84 62.22,1.84 62.71,1.84 63.21,1.84 63.71,1.84 64.20,1.84 64.70,1.84 65.19,1.84 65.69,1.84 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='1.84' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='33.97' cy='10.57' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.24' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.73' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.23' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.72' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.22' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.71' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.21' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.71' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.70' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.19' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.69' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.18' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.68' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.18' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.67' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.17' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.65' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.15' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.64' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='54.29' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='57.76' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='58.75' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='59.74' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='60.24' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='60.73' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='61.23' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='61.72' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='62.22' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='62.71' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='63.21' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='63.71' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='64.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='64.70' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='65.19' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='65.69' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Skyler</td>
<td headers="nb_births_total" class="gt_row gt_right">66,116</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='112.51' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='112.51' y='0.0000000000000018' width='71.74' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='56.25' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>61%</text><text x='148.38' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>39%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.77' y='9.92' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.4</text><polyline points='4.58,1.84 5.54,1.84 6.49,1.84 7.44,1.84 8.40,1.84 9.35,1.84 10.31,1.84 11.26,1.84 12.22,1.84 13.17,1.84 14.13,1.84 15.08,1.84 16.03,1.84 16.99,1.84 17.94,1.84 18.90,1.84 19.85,1.84 20.81,1.84 21.76,3.61 22.72,1.84 23.67,4.34 24.62,3.14 25.58,3.94 26.53,3.39 27.49,2.76 28.44,2.60 29.40,2.55 30.35,2.72 31.31,2.34 32.26,2.87 33.21,3.69 34.17,3.32 35.12,3.13 36.08,4.59 37.03,4.07 37.99,4.28 38.94,4.61 39.90,4.25 40.85,4.57 41.80,4.89 42.76,5.29 43.71,6.51 44.67,6.90 45.62,6.96 46.58,6.58 47.53,6.53 48.48,6.59 49.44,6.46 50.39,6.46 51.35,6.75 52.30,6.33 53.26,5.89 54.21,5.82 55.17,5.42 56.12,5.67 57.07,6.29 58.03,6.64 58.98,7.79 59.94,7.90 60.89,7.80 61.85,7.95 62.80,7.99 63.76,7.96 64.71,8.14 65.66,8.31 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.66' cy='8.31' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='65.66' cy='8.31' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.58' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.54' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.49' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.44' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.40' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.35' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.31' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.26' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.22' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.17' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.13' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.08' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.03' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.99' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.94' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.90' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.85' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.72' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Emerson</td>
<td headers="nb_births_total" class="gt_row gt_right">54,625</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='95.53' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='95.53' y='0.0000000000000018' width='88.72' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='47.76' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>51.8%</text><text x='139.89' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='25.60px' lengthAdjust='spacingAndGlyphs'>48.2%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.79' y='9.88' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.4</text><polyline points='4.19,1.84 4.63,1.84 5.06,1.84 5.50,1.84 5.94,1.84 6.37,1.84 6.81,1.84 7.25,1.84 7.68,1.84 8.12,1.84 8.55,1.84 8.99,1.84 9.43,1.84 9.86,1.84 10.30,1.84 10.73,1.84 11.17,1.84 11.61,1.84 12.04,1.84 12.48,1.84 12.92,1.84 13.35,1.84 13.79,1.84 14.22,1.84 14.66,1.84 15.10,1.84 15.53,1.84 15.97,1.84 16.40,1.84 16.84,1.84 17.28,1.84 17.71,1.84 18.15,1.84 18.59,1.84 19.02,1.84 19.46,1.84 19.89,1.84 20.33,1.84 20.77,1.84 21.20,1.84 21.64,1.84 22.07,1.84 22.51,1.84 22.95,1.84 23.38,1.84 23.82,1.84 24.26,1.84 24.69,1.84 25.13,1.84 25.56,1.84 26.00,1.84 26.44,1.84 26.87,1.84 27.31,1.84 27.74,1.84 28.18,1.84 28.62,1.84 29.05,1.84 29.49,1.84 29.93,1.84 30.36,1.84 30.80,1.84 31.23,1.84 31.67,1.84 32.11,1.84 32.54,1.84 32.98,1.84 33.41,1.84 33.85,1.84 34.29,1.84 34.72,1.84 35.16,1.84 35.60,1.84 36.03,1.84 36.47,1.84 36.90,1.84 37.34,1.84 37.78,1.84 38.21,1.84 38.65,1.84 39.08,1.84 39.52,1.84 39.96,1.84 40.39,1.84 40.83,1.84 41.27,1.84 41.70,1.84 42.14,1.84 42.57,1.84 43.01,1.84 43.45,1.84 43.88,1.84 44.32,1.84 44.75,1.84 45.19,1.84 45.63,1.84 46.06,1.84 46.50,1.84 46.94,1.84 47.37,1.84 47.81,1.84 48.24,1.84 48.68,1.84 49.12,1.84 49.55,1.84 49.99,1.84 50.42,1.84 50.86,1.84 51.30,1.84 51.73,1.84 52.17,1.84 52.61,1.84 53.04,1.84 53.48,2.69 53.91,3.06 54.35,2.97 54.79,3.07 55.22,3.42 55.66,6.96 56.10,6.89 56.53,6.72 56.97,6.77 57.40,7.96 57.84,7.89 58.28,7.34 58.71,8.85 59.15,9.48 59.58,9.18 60.02,9.15 60.46,8.58 60.89,8.58 61.33,8.54 61.77,8.54 62.20,8.53 62.64,8.59 63.07,8.42 63.51,8.60 63.95,8.42 64.38,8.55 64.82,8.23 65.25,8.25 65.69,8.27 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='8.27' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='59.15' cy='9.48' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.19' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.63' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.06' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.50' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.94' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.37' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.25' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.68' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.12' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.55' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.99' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.43' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.86' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.30' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.73' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.17' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.61' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.48' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.92' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.35' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.79' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.22' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.66' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.10' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.53' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.97' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.40' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.84' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.28' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.71' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.15' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.59' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.02' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.89' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.33' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.77' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.64' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.07' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.51' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.95' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='23.38' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='23.82' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.26' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.69' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.13' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.56' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.00' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.44' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.87' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.31' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.74' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.18' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.62' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.05' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.49' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.93' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='30.36' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='30.80' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='31.23' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='31.67' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.11' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.54' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.98' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='33.41' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='33.85' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='34.29' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='34.72' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='35.16' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='35.60' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.03' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.47' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.90' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='37.34' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='37.78' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='38.21' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='38.65' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.08' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.52' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.96' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='40.39' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='40.83' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='41.27' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='41.70' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='42.14' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='42.57' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='43.01' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='43.45' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='43.88' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='44.32' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='44.75' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='45.19' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='45.63' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='46.06' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='46.50' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='46.94' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='47.37' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='47.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='48.24' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='48.68' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='49.12' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='49.55' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='49.99' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='50.42' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='50.86' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='51.30' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='51.73' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='52.17' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='52.61' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='53.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Tommie</td>
<td headers="nb_births_total" class="gt_row gt_right">51,859</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='121.94' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='121.94' y='0.0000000000000018' width='62.32' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='60.97' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>66%</text><text x='153.09' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>34%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.79' y='9.72' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.4</text><polyline points='4.19,6.23 4.63,6.46 5.06,7.33 5.50,9.28 5.94,5.62 6.37,8.95 6.81,6.46 7.25,7.76 7.68,7.20 8.12,7.06 8.55,7.99 8.99,7.02 9.43,8.85 9.86,7.62 10.30,7.15 10.73,7.33 11.17,6.40 11.61,6.53 12.04,8.10 12.48,8.24 12.92,6.38 13.35,6.84 13.79,6.48 14.22,6.10 14.66,7.24 15.10,7.79 15.53,7.33 15.97,5.98 16.40,6.02 16.84,5.89 17.28,6.14 17.71,5.60 18.15,6.04 18.59,6.09 19.02,5.69 19.46,6.13 19.89,5.77 20.33,5.89 20.77,5.98 21.20,5.80 21.64,5.81 22.07,6.03 22.51,6.26 22.95,5.64 23.38,6.53 23.82,6.17 24.26,6.42 24.69,6.36 25.13,6.51 25.56,6.15 26.00,6.09 26.44,5.73 26.87,6.42 27.31,6.00 27.74,6.37 28.18,6.36 28.62,5.86 29.05,6.11 29.49,5.93 29.93,5.92 30.36,5.49 30.80,5.41 31.23,6.00 31.67,6.24 32.11,6.04 32.54,5.51 32.98,5.44 33.41,5.40 33.85,5.09 34.29,5.37 34.72,5.15 35.16,5.18 35.60,5.07 36.03,4.82 36.47,4.75 36.90,4.97 37.34,4.84 37.78,4.81 38.21,4.62 38.65,4.82 39.08,4.55 39.52,4.83 39.96,4.56 40.39,4.94 40.83,4.46 41.27,4.62 41.70,4.86 42.14,4.91 42.57,4.40 43.01,4.97 43.45,4.83 43.88,4.95 44.32,4.47 44.75,5.02 45.19,4.57 45.63,4.73 46.06,5.22 46.50,5.45 46.94,4.87 47.37,4.52 47.81,4.62 48.24,4.55 48.68,4.02 49.12,4.06 49.55,4.40 49.99,4.05 50.42,4.72 50.86,4.04 51.30,4.09 51.73,4.22 52.17,3.80 52.61,4.15 53.04,3.77 53.48,3.50 53.91,4.48 54.35,4.63 54.79,4.93 55.22,4.84 55.66,4.82 56.10,4.96 56.53,5.28 56.97,5.25 57.40,4.70 57.84,4.65 58.28,5.26 58.71,5.53 59.15,5.55 59.58,4.62 60.02,4.48 60.46,4.58 60.89,3.59 61.33,4.30 61.77,5.38 62.20,5.44 62.64,3.32 63.07,5.98 63.51,6.36 63.95,7.07 64.38,7.61 64.82,6.71 65.25,8.20 65.69,8.12 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='8.12' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='5.50' cy='9.28' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='62.64' cy='3.32' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Emery</td>
<td headers="nb_births_total" class="gt_row gt_right">50,366</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='69.79' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='69.79' y='0.0000000000000018' width='114.46' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='34.89' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>38%</text><text x='127.02' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>62%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.79' y='13.33' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.1</text><polyline points='4.19,1.84 4.63,1.84 5.06,1.84 5.50,1.84 5.94,1.84 6.37,1.84 6.81,1.84 7.25,1.84 7.68,1.84 8.12,1.84 8.55,1.84 8.99,1.84 9.43,1.84 9.86,1.84 10.30,1.84 10.73,1.84 11.17,1.84 11.61,1.84 12.04,1.84 12.48,1.84 12.92,1.84 13.35,1.84 13.79,1.84 14.22,1.84 14.66,1.84 15.10,1.84 15.53,3.25 15.97,1.84 16.40,1.84 16.84,1.84 17.28,1.84 17.71,1.84 18.15,1.84 18.59,1.84 19.02,1.84 19.46,1.84 19.89,1.84 20.33,2.03 20.77,2.07 21.20,1.84 21.64,2.03 22.07,1.84 22.51,2.07 22.95,2.14 23.38,1.84 23.82,2.05 24.26,2.12 24.69,2.13 25.13,2.07 25.56,2.15 26.00,1.84 26.44,1.84 26.87,1.84 27.31,1.84 27.74,1.84 28.18,1.84 28.62,1.84 29.05,1.84 29.49,2.24 29.93,2.23 30.36,1.84 30.80,1.84 31.23,2.17 31.67,1.84 32.11,1.84 32.54,1.84 32.98,1.84 33.41,1.84 33.85,1.84 34.29,2.22 34.72,1.84 35.16,1.84 35.60,1.84 36.03,1.84 36.47,1.84 36.90,1.84 37.34,1.84 37.78,2.56 38.21,1.84 38.65,2.34 39.08,2.34 39.52,1.84 39.96,2.20 40.39,1.84 40.83,1.84 41.27,1.84 41.70,1.84 42.14,1.84 42.57,1.84 43.01,1.84 43.45,1.84 43.88,1.84 44.32,2.55 44.75,1.84 45.19,3.82 45.63,2.64 46.06,1.84 46.50,3.06 46.94,3.45 47.37,3.02 47.81,3.03 48.24,3.14 48.68,3.24 49.12,4.13 49.55,4.06 49.99,4.04 50.42,4.17 50.86,3.91 51.30,3.82 51.73,4.58 52.17,4.93 52.61,4.64 53.04,5.50 53.48,5.63 53.91,5.24 54.35,5.90 54.79,7.56 55.22,7.01 55.66,7.69 56.10,8.21 56.53,7.89 56.97,7.84 57.40,8.22 57.84,7.99 58.28,8.82 58.71,9.01 59.15,9.11 59.58,9.73 60.02,9.45 60.46,10.29 60.89,10.27 61.33,10.46 61.77,10.65 62.20,11.08 62.64,11.16 63.07,11.53 63.51,11.47 63.95,11.72 64.38,11.83 64.82,11.75 65.25,11.74 65.69,11.73 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.69' cy='11.73' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='64.38' cy='11.83' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.19' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.63' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.06' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.50' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.94' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.37' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.25' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.68' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.12' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.55' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.99' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.43' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.86' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.30' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.73' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.17' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.61' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.04' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.48' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.92' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.35' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.79' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.22' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.66' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.10' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.97' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.40' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.84' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.28' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.71' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.15' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.59' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.02' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.89' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.07' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='23.38' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.00' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.44' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.87' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.31' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.74' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.18' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.62' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.05' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='30.36' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='30.80' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='31.67' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.11' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.54' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.98' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='33.41' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='33.85' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='34.72' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='35.16' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='35.60' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.03' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.47' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.90' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='37.34' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='38.21' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.52' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='40.39' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='40.83' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='41.27' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='41.70' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='42.14' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='42.57' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='43.01' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='43.45' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='43.88' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='44.75' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='46.06' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
    <tr><td headers="name" class="gt_row gt_left">Rowan</td>
<td headers="nb_births_total" class="gt_row gt_right">50,053</td>
<td headers="pct_births" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='184.25pt' height='14.17pt' viewBox='0 0 184.25 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw=='>    <rect x='0.00' y='0.00' width='184.25' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHwxODQuMjV8MC4wMHwxNC4xNw==)'><rect x='0.00' y='0.0000000000000018' width='120.42' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #2596BE;' /><rect x='120.42' y='0.0000000000000018' width='63.83' height='14.17' style='stroke-width: 1.07; stroke: #FFFFFF; stroke-linecap: butt; stroke-linejoin: miter; fill: #F4BA19;' /><text x='60.21' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>65%</text><text x='152.33' y='9.49' text-anchor='middle' style='font-size: 8.54px; font-weight: 0;fill: #FFFFFF; font-family: "Nimbus Mono PS";' textLength='15.36px' lengthAdjust='spacingAndGlyphs'>35%</text></g></svg></td>
<td headers="pct_births_by_year" class="gt_row gt_center"><?xml version='1.0' encoding='UTF-8' ?><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='svglite' width='85.04pt' height='14.17pt' viewBox='0 0 85.04 14.17'><defs>  <style type='text/css'><![CDATA[    .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {      fill: none;      stroke: #000000;      stroke-linecap: round;      stroke-linejoin: round;      stroke-miterlimit: 10.00;    }    .svglite text {      white-space: pre;    }  ]]></style></defs><rect width='100%' height='100%' style='stroke: none; fill: none;'/><defs>  <clipPath id='cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3'>    <rect x='0.00' y='0.00' width='85.04' height='14.17' />  </clipPath></defs><g clip-path='url(#cpMC4wMHw4NS4wNHwwLjAwfDE0LjE3)'><text x='68.78' y='6.27' style='font-size: 5.69px; font-weight: 0; font-family: "Nimbus Mono PS";' textLength='10.24px' lengthAdjust='spacingAndGlyphs'>0.7</text><polyline points='4.33,1.84 4.95,1.84 5.57,1.84 6.19,1.84 6.81,1.84 7.43,1.84 8.05,1.84 8.67,1.84 9.29,1.84 9.91,1.84 10.53,1.84 11.15,1.84 11.77,1.84 12.39,1.84 13.01,1.84 13.63,1.84 14.25,1.84 14.87,1.84 15.48,1.84 16.10,1.84 16.72,1.84 17.34,1.84 17.96,8.25 18.58,1.84 19.20,1.84 19.82,1.84 20.44,1.84 21.06,1.84 21.68,1.84 22.30,1.84 22.92,1.84 23.54,1.84 24.16,1.84 24.78,1.84 25.40,1.84 26.02,1.84 26.64,1.84 27.26,1.84 27.88,1.84 28.50,1.84 29.12,1.84 29.74,1.84 30.36,1.84 30.98,1.84 31.60,1.84 32.22,1.84 32.84,1.84 33.46,1.84 34.08,1.84 34.70,1.84 35.32,1.84 35.94,1.84 36.55,1.84 37.17,1.84 37.79,6.23 38.41,1.84 39.03,1.84 39.65,1.84 40.27,6.11 40.89,4.37 41.51,5.91 42.13,7.04 42.75,6.23 43.37,4.04 43.99,5.74 44.61,5.50 45.23,4.66 45.85,5.41 46.47,3.45 47.09,6.62 47.71,6.67 48.33,8.65 48.95,8.84 49.57,8.69 50.19,8.67 50.81,8.49 51.43,8.28 52.05,7.27 52.67,7.39 53.29,6.99 53.91,7.36 54.53,6.54 55.15,6.42 55.77,5.85 56.39,6.25 57.01,6.78 57.63,6.34 58.24,6.14 58.86,6.11 59.48,5.60 60.10,5.94 60.72,5.95 61.34,5.50 61.96,5.71 62.58,6.02 63.20,5.54 63.82,5.40 64.44,5.09 65.06,4.76 65.68,4.66 ' style='stroke-width: 1.07; stroke-linecap: butt;' /><circle cx='65.68' cy='4.66' r='0.89' style='stroke-width: 0.71; fill: #000000;' /><circle cx='48.95' cy='8.84' r='0.89' style='stroke-width: 0.71; stroke: #A020F0; fill: #A020F0;' /><circle cx='4.33' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='4.95' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='5.57' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.19' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='6.81' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='7.43' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.05' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='8.67' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.29' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='9.91' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='10.53' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.15' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='11.77' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='12.39' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.01' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='13.63' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.25' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='14.87' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='15.48' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.10' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='16.72' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='17.34' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='18.58' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.20' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='19.82' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='20.44' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.06' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='21.68' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.30' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='22.92' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='23.54' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.16' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='24.78' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='25.40' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.02' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='26.64' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.26' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='27.88' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='28.50' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.12' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='29.74' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='30.36' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='30.98' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='31.60' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.22' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='32.84' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='33.46' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='34.08' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='34.70' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='35.32' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='35.94' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='36.55' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='37.17' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='38.41' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.03' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /><circle cx='39.65' cy='1.84' r='0.89' style='stroke-width: 0.71; stroke: #00FF00; fill: #00FF00;' /></g></svg></td></tr>
  </tbody>
  
  
</table>
</div>
