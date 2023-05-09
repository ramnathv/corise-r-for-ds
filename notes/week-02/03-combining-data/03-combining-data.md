
## Combining Data

**Combining** data spread across multiple tables is a common task. This
is where the `join` and `bind` functions in `dplyr` comes into play.

<img src="https://i.imgur.com/qfpUdFQ.png" width="100%" />

``` r
# Load packages and common utility functions
library(tidyverse)
source(here::here("_common.R"))
```

### Join

**Joining** tables means combining the rows of one table with the rows
of another based on common columns. In `dplyr`, you can use the
`inner_join()`, `left_join()`, `right_join()`, and `full_join()`
functions to perform different types of joins.

Let us take two datasets `band_instruments` and `band_members` which
contain information on the instruments that different members play and
the bands that they belong to. Note that not everyone plays an
instrument, and not everyone is in a band.

``` r
band_instruments
#> # A tibble: 3 × 2
#>   name  plays 
#>   <chr> <chr> 
#> 1 John  guitar
#> 2 Paul  bass  
#> 3 Keith guitar
```

``` r
band_members
#> # A tibble: 3 × 2
#>   name  band   
#>   <chr> <chr>  
#> 1 Mick  Stones 
#> 2 John  Beatles
#> 3 Paul  Beatles
```

#### `inner_join()`: Keep only matching rows in both tables

The `inner_join()` function returns only the rows that have matching
values in both tables. In this case, we get a table with only those
members who play an instrument and belong to a band.

``` r
inner_join(band_instruments, band_members, by = "name")
#> # A tibble: 2 × 3
#>   name  plays  band   
#>   <chr> <chr>  <chr>  
#> 1 John  guitar Beatles
#> 2 Paul  bass   Beatles
```

#### `left_join()`: Keep all rows in the left table

The `left_join()` function returns all the rows from the left table and
the matching rows from the right table. Hence, we have all members who
play an instrument, even if they did not belong to a band.

``` r
left_join(band_instruments, band_members, by = "name")
#> # A tibble: 3 × 3
#>   name  plays  band   
#>   <chr> <chr>  <chr>  
#> 1 John  guitar Beatles
#> 2 Paul  bass   Beatles
#> 3 Keith guitar <NA>
```

#### `right_join()`: Keep all rows in the right table

The `right_join()` function returns all the rows from the right table
and the matching rows from the left table. Hence, we have all members
who belong to a band, even if they did not play an instrument.

``` r
right_join(band_instruments, band_members, by = "name")
#> # A tibble: 3 × 3
#>   name  plays  band   
#>   <chr> <chr>  <chr>  
#> 1 John  guitar Beatles
#> 2 Paul  bass   Beatles
#> 3 Mick  <NA>   Stones
```

#### `full_join()`: Keep all rows in both tables

The `full_join()` function returns all rows from both tables, filling in
`NA` for missing values. Here, we get all members whether or not they
play an instrument or belong to a band.

``` r
full_join(band_instruments, band_members, by = "name")
#> # A tibble: 4 × 3
#>   name  plays  band   
#>   <chr> <chr>  <chr>  
#> 1 John  guitar Beatles
#> 2 Paul  bass   Beatles
#> 3 Keith guitar <NA>   
#> 4 Mick  <NA>   Stones
```

#### `cross_join()`: Cartesian join of both tables

The `cross_join()` function is a cartesian join that matches every row
in one table with every row in another table WITHOUT consideration for
any matching columns. As a result, we end up with a table with number of
rows equaling the product of number of rows of the two tables.

``` r
cross_join(band_instruments, band_members)
#> # A tibble: 9 × 4
#>   name.x plays  name.y band   
#>   <chr>  <chr>  <chr>  <chr>  
#> 1 John   guitar Mick   Stones 
#> 2 John   guitar John   Beatles
#> 3 John   guitar Paul   Beatles
#> 4 Paul   bass   Mick   Stones 
#> 5 Paul   bass   John   Beatles
#> 6 Paul   bass   Paul   Beatles
#> 7 Keith  guitar Mick   Stones 
#> 8 Keith  guitar John   Beatles
#> 9 Keith  guitar Paul   Beatles
```

#### `semi_join()`: Keep columns with matching rows in the right table

The `semi_join()` function returns all rows from the left table with a
match in the right table. It is very similar to the `inner_join()`, but
differs in that it ONLY returns the columns in the left table.

``` r
semi_join(band_instruments, band_members, by = "name")
#> # A tibble: 2 × 2
#>   name  plays 
#>   <chr> <chr> 
#> 1 John  guitar
#> 2 Paul  bass
inner_join(band_instruments, band_members, by = "name")
#> # A tibble: 2 × 3
#>   name  plays  band   
#>   <chr> <chr>  <chr>  
#> 1 John  guitar Beatles
#> 2 Paul  bass   Beatles
```

#### `anti_join()`: Keep columns with non-matching rows in the right table

The `anti_join()` function returns all rows from the left table that
DONT have a match in the right table. You can think of it as the
opposite of `semi_join()`.

``` r
anti_join(band_instruments, band_members, by = "name")
#> # A tibble: 1 × 2
#>   name  plays 
#>   <chr> <chr> 
#> 1 Keith guitar
```

### Bind

While the `join` functions combine two tables by matching rows, the
`bind` functions combine them by stacking them along rows or columns.

#### `bind_rows()`: Bind multiple data frames by row

``` r
df1 <- tibble(x = 1:2, y = letters[1:2])
df2 <- tibble(x = 4:5, z = 1:2)
bind_rows(df1, df2)
#> # A tibble: 4 × 3
#>       x y         z
#>   <int> <chr> <int>
#> 1     1 a        NA
#> 2     2 b        NA
#> 3     4 <NA>      1
#> 4     5 <NA>      2
```

#### `bind_cols()`: Bind multiple data frames by column

``` r
df1 <- tibble(x = 1:3)
df2 <- tibble(y = 3:1)
bind_cols(df1, df2)
#> # A tibble: 3 × 2
#>       x     y
#>   <int> <int>
#> 1     1     3
#> 2     2     2
#> 3     3     1
```
