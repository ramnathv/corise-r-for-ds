
## Reshaping Data

**Reshaping** data is a fundamental task in data analysis, and the
`tidyverse` ecosystem provides several powerful tools for this purpose.
The `tidyr` package, which is part of the `tidyverse`, offers a wide
range of functions for transforming data between different shapes. In
this lesson, we will explore different reshaping operations.

<img src="https://i.imgur.com/gjk7geY.png" width="100%" />

``` r
# Load packages and common utility functions
library(tidyverse)
source(here::here("_common.R"))
```

### Pivot

Pivoting data is a common task in data analysis where data is
transformed from one shape to another to facilitate analysis. In
general, this involves changing the layout of the data from a **long**
format, where each observation is represented in a separate row, to a
**wide** format, where each observation is represented in a separate
column. Alternatively, it may involve changing from a wide format to a
long format.

The `tidyr` package in the `tidyverse` provides several functions for
pivoting data, including `pivot_wider()` and `pivot_longer()`, which can
be used to transform data between wide and long formats.

We will use the `billboard` data that ships with `tidyr` to explore
these functions. This dataset is in the **wide** format and provides the
weekly rankings of the top 100 tracks.

``` r
head(billboard)
#> # A tibble: 6 × 79
#>   artist      track date.entered   wk1   wk2   wk3   wk4   wk5   wk6   wk7   wk8
#>   <chr>       <chr> <date>       <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 2 Pac       Baby… 2000-02-26      87    82    72    77    87    94    99    NA
#> 2 2Ge+her     The … 2000-09-02      91    87    92    NA    NA    NA    NA    NA
#> 3 3 Doors Do… Kryp… 2000-04-08      81    70    68    67    66    57    54    53
#> 4 3 Doors Do… Loser 2000-10-21      76    76    72    69    67    65    55    59
#> 5 504 Boyz    Wobb… 2000-04-15      57    34    25    17    17    31    36    49
#> 6 98^0        Give… 2000-08-19      51    39    34    26    26    19     2     2
#> # ℹ 68 more variables: wk9 <dbl>, wk10 <dbl>, wk11 <dbl>, wk12 <dbl>,
#> #   wk13 <dbl>, wk14 <dbl>, wk15 <dbl>, wk16 <dbl>, wk17 <dbl>, wk18 <dbl>,
#> #   wk19 <dbl>, wk20 <dbl>, wk21 <dbl>, wk22 <dbl>, wk23 <dbl>, wk24 <dbl>,
#> #   wk25 <dbl>, wk26 <dbl>, wk27 <dbl>, wk28 <dbl>, wk29 <dbl>, wk30 <dbl>,
#> #   wk31 <dbl>, wk32 <dbl>, wk33 <dbl>, wk34 <dbl>, wk35 <dbl>, wk36 <dbl>,
#> #   wk37 <dbl>, wk38 <dbl>, wk39 <dbl>, wk40 <dbl>, wk41 <dbl>, wk42 <dbl>,
#> #   wk43 <dbl>, wk44 <dbl>, wk45 <dbl>, wk46 <dbl>, wk47 <dbl>, wk48 <dbl>, …
```

#### `pivot_longer()`: Pivot data from wide to long

Let us start by reshaping this data to the long form. Note that the long
form is usually a lot easier to analyze and visualize and is preferred
by most data scientists using the `tidyverse`.

``` r
billboard_long <- billboard |> 
  pivot_longer(
    cols = starts_with('wk'),
    names_to = 'week',
    values_to = 'rank'
  )

billboard_long
#> # A tibble: 24,092 × 5
#>    artist track                   date.entered week   rank
#>    <chr>  <chr>                   <date>       <chr> <dbl>
#>  1 2 Pac  Baby Don't Cry (Keep... 2000-02-26   wk1      87
#>  2 2 Pac  Baby Don't Cry (Keep... 2000-02-26   wk2      82
#>  3 2 Pac  Baby Don't Cry (Keep... 2000-02-26   wk3      72
#>  4 2 Pac  Baby Don't Cry (Keep... 2000-02-26   wk4      77
#>  5 2 Pac  Baby Don't Cry (Keep... 2000-02-26   wk5      87
#>  6 2 Pac  Baby Don't Cry (Keep... 2000-02-26   wk6      94
#>  7 2 Pac  Baby Don't Cry (Keep... 2000-02-26   wk7      99
#>  8 2 Pac  Baby Don't Cry (Keep... 2000-02-26   wk8      NA
#>  9 2 Pac  Baby Don't Cry (Keep... 2000-02-26   wk9      NA
#> 10 2 Pac  Baby Don't Cry (Keep... 2000-02-26   wk10     NA
#> # ℹ 24,082 more rows
```

`pivot_longer()` takes as input a dataset and a set of arguments that
specify the columns to pivot and the new column names to create. In this
case, the `cols` argument is set to `starts_with('wk')`, which specifies
that any columns that start with the string “wk” should be pivoted.
These columns correspond to the weekly ranking of songs on the Billboard
charts.

The `names_to` argument specifies the name of the new column that will
contain the column names that were pivoted. In this case, it is set to
`'week'`, which will create a new column called “week” that contains the
week number for each observation.

The `values_to` argument specifies the name of the new column that will
contain the values that were pivoted. In this case, it is set to
`'rank'`, which will create a new column called “rank” that contains the
ranking of each song for each week.

#### `pivot_wider()`: Pivot data from long to wide

Let us reshape `billboard_long` back to the wide format using the
`pivot_wider()` function.

``` r
billboard_long |> 
  pivot_wider(
    names_from = week,
    values_from = rank
  )
#> # A tibble: 317 × 79
#>    artist     track date.entered   wk1   wk2   wk3   wk4   wk5   wk6   wk7   wk8
#>    <chr>      <chr> <date>       <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1 2 Pac      Baby… 2000-02-26      87    82    72    77    87    94    99    NA
#>  2 2Ge+her    The … 2000-09-02      91    87    92    NA    NA    NA    NA    NA
#>  3 3 Doors D… Kryp… 2000-04-08      81    70    68    67    66    57    54    53
#>  4 3 Doors D… Loser 2000-10-21      76    76    72    69    67    65    55    59
#>  5 504 Boyz   Wobb… 2000-04-15      57    34    25    17    17    31    36    49
#>  6 98^0       Give… 2000-08-19      51    39    34    26    26    19     2     2
#>  7 A*Teens    Danc… 2000-07-08      97    97    96    95   100    NA    NA    NA
#>  8 Aaliyah    I Do… 2000-01-29      84    62    51    41    38    35    35    38
#>  9 Aaliyah    Try … 2000-03-18      59    53    38    28    21    18    16    14
#> 10 Adams, Yo… Open… 2000-08-26      76    76    74    69    68    67    61    58
#> # ℹ 307 more rows
#> # ℹ 68 more variables: wk9 <dbl>, wk10 <dbl>, wk11 <dbl>, wk12 <dbl>,
#> #   wk13 <dbl>, wk14 <dbl>, wk15 <dbl>, wk16 <dbl>, wk17 <dbl>, wk18 <dbl>,
#> #   wk19 <dbl>, wk20 <dbl>, wk21 <dbl>, wk22 <dbl>, wk23 <dbl>, wk24 <dbl>,
#> #   wk25 <dbl>, wk26 <dbl>, wk27 <dbl>, wk28 <dbl>, wk29 <dbl>, wk30 <dbl>,
#> #   wk31 <dbl>, wk32 <dbl>, wk33 <dbl>, wk34 <dbl>, wk35 <dbl>, wk36 <dbl>,
#> #   wk37 <dbl>, wk38 <dbl>, wk39 <dbl>, wk40 <dbl>, wk41 <dbl>, wk42 <dbl>, …
```

The `pivot_wider()` function takes as input a dataset and a set of
arguments that specify the columns to pivot and the new column names to
create. In this case, the `names_from` argument is set to `week`, which
specifies that the new column names should be based on the values in the
“week” column of the `billboard_long` dataset. The `values_from`
argument is set to `rank`, which specifies that the values in the “rank”
column of the `billboard_long` dataset should be used as the values in
the new columns.

**Nesting** and **Unnesting** are two useful data transformation
techniques that allow us to group and ungroup data in various ways and
are supported by the `tidyr` package of the tidyverse. We will use the
baby names dataset to illustrate these operations.

``` r
# Read tbl_names from `data/names.csv.gz`
tbl_names <- readr::read_csv(
  file = here::here("data/names.csv.gz"),
  show_col_types = FALSE
)
```

### Nest

#### `nest()`: Nest rows into a list-column of data frames

**Nesting** involves taking a set of variables and collapsing them into
a single column that contains a nested data structure, such as a list or
a data frame. This can be useful when we want to perform operations on
subsets of our data, or when we have data with a hierarchical structure
that we want to preserve.

``` r
# Nest the year and nb_births columns into a list-column named nb_births_by_year
tbl_names_nested <- tbl_names |> 
  group_by(sex, name) |> 
  nest(nb_births_by_year = c(year, nb_births))

head(tbl_names_nested)
#> # A tibble: 6 × 3
#> # Groups:   sex, name [6]
#>   name      sex   nb_births_by_year 
#>   <chr>     <chr> <list>            
#> 1 Mary      F     <tibble [142 × 2]>
#> 2 Anna      F     <tibble [142 × 2]>
#> 3 Emma      F     <tibble [142 × 2]>
#> 4 Elizabeth F     <tibble [142 × 2]>
#> 5 Minnie    F     <tibble [142 × 2]>
#> 6 Margaret  F     <tibble [142 × 2]>
```

The column `nb_births_by_year` is a list column, where each element of
the list is a data frame with columns `nb_births` and `year`. We can
print the first six rows of `nb_births_by_year` for the first row of
this nested data frame.

``` r
head(tbl_names_nested$nb_births_by_year[[1]])
#> # A tibble: 6 × 2
#>    year nb_births
#>   <dbl>     <dbl>
#> 1  1880      7065
#> 2  1881      6919
#> 3  1882      8148
#> 4  1883      8012
#> 5  1884      9217
#> 6  1885      9128
```

#### `unnest()`: Unnest a list-column of data frames

**Unnesting**, on the other hand, involves taking data that is nested in
a column and spreading it out into separate columns. This can be useful
when we want to perform analyses on individual components of our data
that are currently grouped together.

``` r
tbl_names_nested |> 
  unnest(nb_births_by_year)
#> # A tibble: 2,052,781 × 4
#> # Groups:   sex, name [112,620]
#>    name  sex    year nb_births
#>    <chr> <chr> <dbl>     <dbl>
#>  1 Mary  F      1880      7065
#>  2 Mary  F      1881      6919
#>  3 Mary  F      1882      8148
#>  4 Mary  F      1883      8012
#>  5 Mary  F      1884      9217
#>  6 Mary  F      1885      9128
#>  7 Mary  F      1886      9889
#>  8 Mary  F      1887      9888
#>  9 Mary  F      1888     11754
#> 10 Mary  F      1889     11648
#> # ℹ 2,052,771 more rows
```

#### `unnest_longer()`: Unnest a list-column into rows

There are three other `unnesting` functions supported by the `tidyr`
package. To illustrate their usage, let us take the `starwars` data and
focus on the `name` and `films` columns.

``` r
starwars_name_films <- starwars |> 
  select(name, films)

head(starwars_name_films)
#> # A tibble: 6 × 2
#>   name           films    
#>   <chr>          <list>   
#> 1 Luke Skywalker <chr [5]>
#> 2 C-3PO          <chr [6]>
#> 3 R2-D2          <chr [7]>
#> 4 Darth Vader    <chr [4]>
#> 5 Leia Organa    <chr [5]>
#> 6 Owen Lars      <chr [3]>
```

Note how the `films` column is a list of vectors, where each item is a
vector of films that included the character.

``` r
starwars_name_films$films[[1]]
#> [1] "The Empire Strikes Back" "Revenge of the Sith"    
#> [3] "Return of the Jedi"      "A New Hope"             
#> [5] "The Force Awakens"
```

We can use `unnest_longer()` to unnest this column along the length of
the data frame such that every film gets its own row.

``` r
starwars |> 
  select(name, films) |> 
  unnest_longer(films)
#> # A tibble: 173 × 2
#>    name           films                  
#>    <chr>          <chr>                  
#>  1 Luke Skywalker The Empire Strikes Back
#>  2 Luke Skywalker Revenge of the Sith    
#>  3 Luke Skywalker Return of the Jedi     
#>  4 Luke Skywalker A New Hope             
#>  5 Luke Skywalker The Force Awakens      
#>  6 C-3PO          The Empire Strikes Back
#>  7 C-3PO          Attack of the Clones   
#>  8 C-3PO          The Phantom Menace     
#>  9 C-3PO          Revenge of the Sith    
#> 10 C-3PO          Return of the Jedi     
#> # ℹ 163 more rows
```

#### `unnest_wider()`: Unnest a list-column into columns

Alternately, we could also unnest it wider so that each `name` still has
only one `row`, but each film gets its own column.

``` r
starwars |> 
  select(name, films) |> 
  unnest_wider(films, names_sep = "_")
#> # A tibble: 87 × 8
#>    name               films_1    films_2 films_3 films_4 films_5 films_6 films_7
#>    <chr>              <chr>      <chr>   <chr>   <chr>   <chr>   <chr>   <chr>  
#>  1 Luke Skywalker     The Empir… Reveng… Return… A New … The Fo… <NA>    <NA>   
#>  2 C-3PO              The Empir… Attack… The Ph… Reveng… Return… A New … <NA>   
#>  3 R2-D2              The Empir… Attack… The Ph… Reveng… Return… A New … The Fo…
#>  4 Darth Vader        The Empir… Reveng… Return… A New … <NA>    <NA>    <NA>   
#>  5 Leia Organa        The Empir… Reveng… Return… A New … The Fo… <NA>    <NA>   
#>  6 Owen Lars          Attack of… Reveng… A New … <NA>    <NA>    <NA>    <NA>   
#>  7 Beru Whitesun lars Attack of… Reveng… A New … <NA>    <NA>    <NA>    <NA>   
#>  8 R5-D4              A New Hope <NA>    <NA>    <NA>    <NA>    <NA>    <NA>   
#>  9 Biggs Darklighter  A New Hope <NA>    <NA>    <NA>    <NA>    <NA>    <NA>   
#> 10 Obi-Wan Kenobi     The Empir… Attack… The Ph… Reveng… Return… A New … <NA>   
#> # ℹ 77 more rows
```

Note that the length of `films` for each `name` is not equal and so
there are NAs in the data.

#### `unnest_auto()`: Unnest a list-column automatically

Finally, we have the `unnest_auto()` function which automatically uses
`unnest_longer()` or `unnest_wider()` based on which one is more
appropriate. It displays a message on which function it chose and some
reasoning behind it.

``` r
starwars |> 
  select(name, films) |> 
  unnest_auto(films)
#> Using `unnest_longer(films, indices_include = FALSE)`; no element has names
#> # A tibble: 173 × 2
#>    name           films                  
#>    <chr>          <chr>                  
#>  1 Luke Skywalker The Empire Strikes Back
#>  2 Luke Skywalker Revenge of the Sith    
#>  3 Luke Skywalker Return of the Jedi     
#>  4 Luke Skywalker A New Hope             
#>  5 Luke Skywalker The Force Awakens      
#>  6 C-3PO          The Empire Strikes Back
#>  7 C-3PO          Attack of the Clones   
#>  8 C-3PO          The Phantom Menace     
#>  9 C-3PO          Revenge of the Sith    
#> 10 C-3PO          Return of the Jedi     
#> # ℹ 163 more rows
```

### Expand

#### `expand()`: Expand to include all combinations of values

The `expand()` function can be used to generate all combinations of
variables in a data frame. For example, take this data frame of fruits.

``` r
fruits <- tibble(
  type = c("apple", "orange", "apple", "orange", "orange", "orange"),
  year = c(2010, 2010, 2012, 2010, 2011, 2012),
  size = factor(
    c("XS", "S", "M", "S", "S", "M"),
    levels = c("XS", "S", "M", "L")
  ),
  weights = rnorm(6, as.numeric(size) + 2)
)
fruits
#> # A tibble: 6 × 4
#>   type    year size  weights
#>   <chr>  <dbl> <fct>   <dbl>
#> 1 apple   2010 XS       1.79
#> 2 orange  2010 S        4.28
#> 3 apple   2012 M        6.08
#> 4 orange  2010 S        1.65
#> 5 orange  2011 S        4.43
#> 6 orange  2012 M        5.51
```

We can use `expand()` to generate all combinations of `type` and `size`.

``` r
fruits |> 
  expand(type, size)
#> # A tibble: 8 × 2
#>   type   size 
#>   <chr>  <fct>
#> 1 apple  XS   
#> 2 apple  S    
#> 3 apple  M    
#> 4 apple  L    
#> 5 orange XS   
#> 6 orange S    
#> 7 orange M    
#> 8 orange L
```

#### `complete()`: Complete with missing combinations

The `complete()` function extends what the `expand()` function does and
also adds the remaining columns of the data, and fills them with NAs
where the values are missing.

``` r
fruits |> 
  complete(type, size)
#> # A tibble: 10 × 4
#>    type   size   year weights
#>    <chr>  <fct> <dbl>   <dbl>
#>  1 apple  XS     2010    1.79
#>  2 apple  S        NA   NA   
#>  3 apple  M      2012    6.08
#>  4 apple  L        NA   NA   
#>  5 orange XS       NA   NA   
#>  6 orange S      2010    4.28
#>  7 orange S      2010    1.65
#>  8 orange S      2011    4.43
#>  9 orange M      2012    5.51
#> 10 orange L        NA   NA
```

#### `separate_rows()`: Separate a collapsed column into multiple rows

Let us go back to the `starwars` data and look at the `skin_color`
column. Note values like `white, blue` which are essentially the result
of collapsing the vector `c("white", "blue")` into a single comma
separated string.

``` r
starwars |> 
  filter(str_detect(skin_color, ",")) |> 
  select(name, skin_color)
#> # A tibble: 14 × 2
#>    name                  skin_color         
#>    <chr>                 <chr>              
#>  1 R2-D2                 white, blue        
#>  2 R5-D4                 white, red         
#>  3 Jabba Desilijic Tiure green-tan, brown   
#>  4 Watto                 blue, grey         
#>  5 Sebulba               grey, red          
#>  6 Dud Bolt              blue, grey         
#>  7 Gasgano               white, blue        
#>  8 Ben Quadinaros        grey, green, yellow
#>  9 Zam Wesell            fair, green, yellow
#> 10 Ratts Tyerell         grey, blue         
#> 11 R4-P17                silver, red        
#> 12 Wat Tambor            green, grey        
#> 13 Shaak Ti              red, blue, white   
#> 14 Grievous              brown, white
```

We can use the `separate_rows()` function to separate this collapsed
column into multiple rows.

``` r
starwars |> 
  select(name, skin_color) |> 
  separate_rows(skin_color)
#> # A tibble: 107 × 2
#>    name               skin_color
#>    <chr>              <chr>     
#>  1 Luke Skywalker     fair      
#>  2 C-3PO              gold      
#>  3 R2-D2              white     
#>  4 R2-D2              blue      
#>  5 Darth Vader        white     
#>  6 Leia Organa        light     
#>  7 Owen Lars          light     
#>  8 Beru Whitesun lars light     
#>  9 R5-D4              white     
#> 10 R5-D4              red       
#> # ℹ 97 more rows
```
