
## Manipulating Data

``` r
library(tidyverse)
knitr::opts_chunk$set(comment = "#>")
set.seed(1234)
```

Recall how data manipulation operations work on rows and columns of a
table, while leaving its shape largely intact. It is useful to group
these operations based on whether they manipulate rows or columns.

![manipulate-data](https://imgur.com/xd7PCyy.png)

We will use a handy dataset named `starwars` that ships with the `dplyr`
package, to illustrate the basic idea behind these data manipulation
operations. While the data is largely self explanatory, as always, you
can type `? starwars` to get more details on the data.

``` r
starwars
```

    #> # A tibble: 87 × 14
    #>    name     height  mass hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>     <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Luke Sk…    172    77 blond      fair       blue            19   male  mascu…
    #>  2 C-3PO       167    75 <NA>       gold       yellow         112   none  mascu…
    #>  3 R2-D2        96    32 <NA>       white, bl… red             33   none  mascu…
    #>  4 Darth V…    202   136 none       white      yellow          41.9 male  mascu…
    #>  5 Leia Or…    150    49 brown      light      brown           19   fema… femin…
    #>  6 Owen La…    178   120 brown, gr… light      blue            52   male  mascu…
    #>  7 Beru Wh…    165    75 brown      light      blue            47   fema… femin…
    #>  8 R5-D4        97    32 <NA>       white, red red             NA   none  mascu…
    #>  9 Biggs D…    183    84 black      light      brown           24   male  mascu…
    #> 10 Obi-Wan…    182    77 auburn, w… fair       blue-gray       57   male  mascu…
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

### Manipulating Rows

These functions operate on the rows of a table and allow us to subset a
table based on

#### `filter`: Keep rows that match a condition

The `filter()` functions allows you to subset rows of a table based on a
set of one or more matching conditions. You can combine one or more
criteria to keep only the rows that you want to keep.

Run these examples one at a time to understand what they accomplish. In
order to get the most out of it, have a hypothesis in place before you
run the line of code, so you can corroborate your understanding with the
results. Finally, don’t limit yourself to these examples. Come up with
your own criteria and explore.

``` r
# One criterion, One expression
filter(starwars, species == "Human")
```

    #> # A tibble: 35 × 14
    #>    name     height  mass hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>     <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Luke Sk…    172    77 blond      fair       blue            19   male  mascu…
    #>  2 Darth V…    202   136 none       white      yellow          41.9 male  mascu…
    #>  3 Leia Or…    150    49 brown      light      brown           19   fema… femin…
    #>  4 Owen La…    178   120 brown, gr… light      blue            52   male  mascu…
    #>  5 Beru Wh…    165    75 brown      light      blue            47   fema… femin…
    #>  6 Biggs D…    183    84 black      light      brown           24   male  mascu…
    #>  7 Obi-Wan…    182    77 auburn, w… fair       blue-gray       57   male  mascu…
    #>  8 Anakin …    188    84 blond      fair       blue            41.9 male  mascu…
    #>  9 Wilhuff…    180    NA auburn, g… fair       blue            64   male  mascu…
    #> 10 Han Solo    180    80 brown      fair       brown           29   male  mascu…
    #> # ℹ 25 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
filter(starwars, mass > 1000)
```

    #> # A tibble: 1 × 14
    #>   name      height  mass hair_color skin_color eye_color birth_year sex   gender
    #>   <chr>      <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #> 1 Jabba De…    175  1358 <NA>       green-tan… orange           600 herm… mascu…
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Multiple criterion, One expression
filter(starwars, hair_color == "none" & eye_color == "black")
```

    #> # A tibble: 9 × 14
    #>   name      height  mass hair_color skin_color eye_color birth_year sex   gender
    #>   <chr>      <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #> 1 Nien Nunb    160    68 none       grey       black             NA male  mascu…
    #> 2 Gasgano      122    NA none       white, bl… black             NA male  mascu…
    #> 3 Kit Fisto    196    87 none       green      black             NA male  mascu…
    #> 4 Plo Koon     188    80 none       orange     black             22 male  mascu…
    #> 5 Lama Su      229    88 none       grey       black             NA male  mascu…
    #> 6 Taun We      213    NA none       grey       black             NA fema… femin…
    #> 7 Shaak Ti     178    57 none       red, blue… black             NA fema… femin…
    #> 8 Tion Med…    206    80 none       grey       black             NA male  mascu…
    #> 9 BB8           NA    NA none       none       black             NA none  mascu…
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
filter(starwars, hair_color == "none" | eye_color == "black")
```

    #> # A tibble: 38 × 14
    #>    name     height  mass hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>     <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Darth V…    202   136 none       white      yellow          41.9 male  mascu…
    #>  2 Greedo      173    74 <NA>       green      black           44   male  mascu…
    #>  3 IG-88       200   140 none       metal      red             15   none  mascu…
    #>  4 Bossk       190   113 none       green      red             53   male  mascu…
    #>  5 Lobot       175    79 none       light      blue            37   male  mascu…
    #>  6 Ackbar      180    83 none       brown mot… orange          41   male  mascu…
    #>  7 Nien Nu…    160    68 none       grey       black           NA   male  mascu…
    #>  8 Nute Gu…    191    90 none       mottled g… red             NA   male  mascu…
    #>  9 Jar Jar…    196    66 none       orange     orange          52   male  mascu…
    #> 10 Roos Ta…    224    82 none       grey       orange          NA   male  mascu…
    #> # ℹ 28 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Multiple criterion, Multiple expressions
filter(starwars, hair_color == "none", eye_color == "black")
```

    #> # A tibble: 9 × 14
    #>   name      height  mass hair_color skin_color eye_color birth_year sex   gender
    #>   <chr>      <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #> 1 Nien Nunb    160    68 none       grey       black             NA male  mascu…
    #> 2 Gasgano      122    NA none       white, bl… black             NA male  mascu…
    #> 3 Kit Fisto    196    87 none       green      black             NA male  mascu…
    #> 4 Plo Koon     188    80 none       orange     black             22 male  mascu…
    #> 5 Lama Su      229    88 none       grey       black             NA male  mascu…
    #> 6 Taun We      213    NA none       grey       black             NA fema… femin…
    #> 7 Shaak Ti     178    57 none       red, blue… black             NA fema… femin…
    #> 8 Tion Med…    206    80 none       grey       black             NA male  mascu…
    #> 9 BB8           NA    NA none       none       black             NA none  mascu…
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

#### `arrange`: Order rows using column values

The `arrange()` function lets you sort a table based on the values of
one or more columns. You can use the modifier function, `desc()`, to
indicate that you want to sort a column in the descending order.

``` r
# Single Column > Ascending
arrange(starwars, name)
```

    #> # A tibble: 87 × 14
    #>    name     height  mass hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>     <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Ackbar      180    83 none       brown mot… orange          41   male  mascu…
    #>  2 Adi Gal…    184    50 none       dark       blue            NA   fema… femin…
    #>  3 Anakin …    188    84 blond      fair       blue            41.9 male  mascu…
    #>  4 Arvel C…     NA    NA brown      fair       brown           NA   male  mascu…
    #>  5 Ayla Se…    178    55 none       blue       hazel           48   fema… femin…
    #>  6 BB8          NA    NA none       none       black           NA   none  mascu…
    #>  7 Bail Pr…    191    NA black      tan        brown           67   male  mascu…
    #>  8 Barriss…    166    50 black      yellow     blue            40   fema… femin…
    #>  9 Ben Qua…    163    65 none       grey, gre… orange          NA   male  mascu…
    #> 10 Beru Wh…    165    75 brown      light      blue            47   fema… femin…
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
arrange(starwars, mass)
```

    #> # A tibble: 87 × 14
    #>    name     height  mass hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>     <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Ratts T…     79    15 none       grey, blue unknown           NA male  mascu…
    #>  2 Yoda         66    17 white      green      brown            896 male  mascu…
    #>  3 Wicket …     88    20 brown      brown      brown              8 male  mascu…
    #>  4 R2-D2        96    32 <NA>       white, bl… red               33 none  mascu…
    #>  5 R5-D4        97    32 <NA>       white, red red               NA none  mascu…
    #>  6 Sebulba     112    40 none       grey, red  orange            NA male  mascu…
    #>  7 Dud Bolt     94    45 none       blue, grey yellow            NA male  mascu…
    #>  8 Padmé A…    165    45 brown      light      brown             46 fema… femin…
    #>  9 Wat Tam…    193    48 none       green, gr… unknown           NA male  mascu…
    #> 10 Sly Moo…    178    48 none       pale       white             NA <NA>  <NA>  
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Single Column > Descending
arrange(starwars, desc(mass))
```

    #> # A tibble: 87 × 14
    #>    name     height  mass hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>     <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Jabba D…    175  1358 <NA>       green-tan… orange         600   herm… mascu…
    #>  2 Grievous    216   159 none       brown, wh… green, y…       NA   male  mascu…
    #>  3 IG-88       200   140 none       metal      red             15   none  mascu…
    #>  4 Darth V…    202   136 none       white      yellow          41.9 male  mascu…
    #>  5 Tarfful     234   136 brown      brown      blue            NA   male  mascu…
    #>  6 Owen La…    178   120 brown, gr… light      blue            52   male  mascu…
    #>  7 Bossk       190   113 none       green      red             53   male  mascu…
    #>  8 Chewbac…    228   112 brown      unknown    blue           200   male  mascu…
    #>  9 Jek Ton…    180   110 brown      fair       blue            NA   male  mascu…
    #> 10 Dexter …    198   102 none       brown      yellow          NA   male  mascu…
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Multiple Columns
arrange(starwars, name, desc(mass))
```

    #> # A tibble: 87 × 14
    #>    name     height  mass hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>     <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Ackbar      180    83 none       brown mot… orange          41   male  mascu…
    #>  2 Adi Gal…    184    50 none       dark       blue            NA   fema… femin…
    #>  3 Anakin …    188    84 blond      fair       blue            41.9 male  mascu…
    #>  4 Arvel C…     NA    NA brown      fair       brown           NA   male  mascu…
    #>  5 Ayla Se…    178    55 none       blue       hazel           48   fema… femin…
    #>  6 BB8          NA    NA none       none       black           NA   none  mascu…
    #>  7 Bail Pr…    191    NA black      tan        brown           67   male  mascu…
    #>  8 Barriss…    166    50 black      yellow     blue            40   fema… femin…
    #>  9 Ben Qua…    163    65 none       grey, gre… orange          NA   male  mascu…
    #> 10 Beru Wh…    165    75 brown      light      blue            47   fema… femin…
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

#### `distinct`: Keep distinct/unique rows

The `distinct()` function allows you to keep rows with distinct
combinations of column values.

``` r
# Single Column
distinct(starwars, sex)
```

    #> # A tibble: 5 × 1
    #>   sex           
    #>   <chr>         
    #> 1 male          
    #> 2 none          
    #> 3 female        
    #> 4 hermaphroditic
    #> 5 <NA>

``` r
# Multiple Columns
distinct(starwars, sex, skin_color)
```

    #> # A tibble: 41 × 2
    #>    sex            skin_color      
    #>    <chr>          <chr>           
    #>  1 male           fair            
    #>  2 none           gold            
    #>  3 none           white, blue     
    #>  4 male           white           
    #>  5 female         light           
    #>  6 male           light           
    #>  7 none           white, red      
    #>  8 male           unknown         
    #>  9 male           green           
    #> 10 hermaphroditic green-tan, brown
    #> # ℹ 31 more rows

#### `slice`: Subset rows using their positions

The `slice_` family of functions let you subset rows based on their
position. It ships with several variations that let you pick rows by
their absolute position (`slice_head` and `slice_tail`), by their
relative position based on a column value (`slice_min` and `slice_max`),
or at random (`slice_sample`).

``` r
# Rows 1-5
slice(starwars, 1:5)
```

    #> # A tibble: 5 × 14
    #>   name      height  mass hair_color skin_color eye_color birth_year sex   gender
    #>   <chr>      <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #> 1 Luke Sky…    172    77 blond      fair       blue            19   male  mascu…
    #> 2 C-3PO        167    75 <NA>       gold       yellow         112   none  mascu…
    #> 3 R2-D2         96    32 <NA>       white, bl… red             33   none  mascu…
    #> 4 Darth Va…    202   136 none       white      yellow          41.9 male  mascu…
    #> 5 Leia Org…    150    49 brown      light      brown           19   fema… femin…
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# First 5 Rows
slice_head(starwars, n = 5)
```

    #> # A tibble: 5 × 14
    #>   name      height  mass hair_color skin_color eye_color birth_year sex   gender
    #>   <chr>      <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #> 1 Luke Sky…    172    77 blond      fair       blue            19   male  mascu…
    #> 2 C-3PO        167    75 <NA>       gold       yellow         112   none  mascu…
    #> 3 R2-D2         96    32 <NA>       white, bl… red             33   none  mascu…
    #> 4 Darth Va…    202   136 none       white      yellow          41.9 male  mascu…
    #> 5 Leia Org…    150    49 brown      light      brown           19   fema… femin…
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Last 5 Rows
slice_tail(starwars, n = 5)
```

    #> # A tibble: 5 × 14
    #>   name      height  mass hair_color skin_color eye_color birth_year sex   gender
    #>   <chr>      <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #> 1 Rey           NA    NA brown      light      hazel             NA fema… femin…
    #> 2 Poe Dame…     NA    NA brown      light      brown             NA male  mascu…
    #> 3 BB8           NA    NA none       none       black             NA none  mascu…
    #> 4 Captain …     NA    NA unknown    unknown    unknown           NA <NA>  <NA>  
    #> 5 Padmé Am…    165    45 brown      light      brown             46 fema… femin…
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# First 5 Rows arranged by height
slice_min(starwars, height, n = 5)
```

    #> # A tibble: 6 × 14
    #>   name      height  mass hair_color skin_color eye_color birth_year sex   gender
    #>   <chr>      <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #> 1 Yoda          66    17 white      green      brown            896 male  mascu…
    #> 2 Ratts Ty…     79    15 none       grey, blue unknown           NA male  mascu…
    #> 3 Wicket S…     88    20 brown      brown      brown              8 male  mascu…
    #> 4 Dud Bolt      94    45 none       blue, grey yellow            NA male  mascu…
    #> 5 R2-D2         96    32 <NA>       white, bl… red               33 none  mascu…
    #> 6 R4-P17        96    NA none       silver, r… red, blue         NA none  femin…
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# First 5 Rows arranged by descending height
slice_max(starwars, height, n = 5)
```

    #> # A tibble: 5 × 14
    #>   name      height  mass hair_color skin_color eye_color birth_year sex   gender
    #>   <chr>      <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #> 1 Yarael P…    264    NA none       white      yellow            NA male  mascu…
    #> 2 Tarfful      234   136 brown      brown      blue              NA male  mascu…
    #> 3 Lama Su      229    88 none       grey       black             NA male  mascu…
    #> 4 Chewbacca    228   112 brown      unknown    blue             200 male  mascu…
    #> 5 Roos Tar…    224    82 none       grey       orange            NA male  mascu…
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Random 5 Rows
slice_sample(starwars, n = 5)
```

    #> # A tibble: 5 × 14
    #>   name      height  mass hair_color skin_color eye_color birth_year sex   gender
    #>   <chr>      <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #> 1 Arvel Cr…     NA    NA brown      fair       brown             NA male  mascu…
    #> 2 Sly Moore    178    48 none       pale       white             NA <NA>  <NA>  
    #> 3 IG-88        200   140 none       metal      red               15 none  mascu…
    #> 4 Biggs Da…    183    84 black      light      brown             24 male  mascu…
    #> 5 Leia Org…    150    49 brown      light      brown             19 fema… femin…
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Random 20% Rows
slice_sample(starwars, prop = 0.20)
```

    #> # A tibble: 17 × 14
    #>    name    height   mass hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>    <int>  <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Watto      137   NA   black      blue, grey yellow          NA   male  mascu…
    #>  2 Jabba …    175 1358   <NA>       green-tan… orange         600   herm… mascu…
    #>  3 Darth …    202  136   none       white      yellow          41.9 male  mascu…
    #>  4 Taun We    213   NA   none       grey       black           NA   fema… femin…
    #>  5 Raymus…    188   79   brown      light      brown           NA   male  mascu…
    #>  6 Tarfful    234  136   brown      brown      blue            NA   male  mascu…
    #>  7 Han So…    180   80   brown      fair       brown           29   male  mascu…
    #>  8 Mas Am…    196   NA   none       blue       blue            NA   male  mascu…
    #>  9 Barris…    166   50   black      yellow     blue            40   fema… femin…
    #> 10 BB8         NA   NA   none       none       black           NA   none  mascu…
    #> 11 Finn        NA   NA   black      dark       dark            NA   male  mascu…
    #> 12 Boba F…    183   78.2 black      fair       brown           31.5 male  mascu…
    #> 13 Quarsh…    183   NA   black      dark       brown           62   <NA>  <NA>  
    #> 14 Sly Mo…    178   48   none       pale       white           NA   <NA>  <NA>  
    #> 15 Zam We…    168   55   blonde     fair, gre… yellow          NA   fema… femin…
    #> 16 Leia O…    150   49   brown      light      brown           19   fema… femin…
    #> 17 Jango …    183   79   black      tan        brown           66   male  mascu…
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

### Manipulating Columns

#### `select`: Keep or drop columns (1 / 2)

The `select` function lets you keep or drop columns in a dataset. You
can use unquoted column names, ranges, and even boolean operators to
define your selection.

``` r
# Keep columns name and mass
select(starwars, name, mass)
```

    #> # A tibble: 87 × 2
    #>    name                mass
    #>    <chr>              <dbl>
    #>  1 Luke Skywalker        77
    #>  2 C-3PO                 75
    #>  3 R2-D2                 32
    #>  4 Darth Vader          136
    #>  5 Leia Organa           49
    #>  6 Owen Lars            120
    #>  7 Beru Whitesun lars    75
    #>  8 R5-D4                 32
    #>  9 Biggs Darklighter     84
    #> 10 Obi-Wan Kenobi        77
    #> # ℹ 77 more rows

``` r
# Keep columns from name to skin_color, and species
select(starwars, name:skin_color, species)
```

    #> # A tibble: 87 × 6
    #>    name               height  mass hair_color    skin_color  species
    #>    <chr>               <int> <dbl> <chr>         <chr>       <chr>  
    #>  1 Luke Skywalker        172    77 blond         fair        Human  
    #>  2 C-3PO                 167    75 <NA>          gold        Droid  
    #>  3 R2-D2                  96    32 <NA>          white, blue Droid  
    #>  4 Darth Vader           202   136 none          white       Human  
    #>  5 Leia Organa           150    49 brown         light       Human  
    #>  6 Owen Lars             178   120 brown, grey   light       Human  
    #>  7 Beru Whitesun lars    165    75 brown         light       Human  
    #>  8 R5-D4                  97    32 <NA>          white, red  Droid  
    #>  9 Biggs Darklighter     183    84 black         light       Human  
    #> 10 Obi-Wan Kenobi        182    77 auburn, white fair        Human  
    #> # ℹ 77 more rows

``` r
# Drop columns mass and height
select(starwars, -mass, -height)
```

    #> # A tibble: 87 × 12
    #>    name        hair_color skin_color eye_color birth_year sex   gender homeworld
    #>    <chr>       <chr>      <chr>      <chr>          <dbl> <chr> <chr>  <chr>    
    #>  1 Luke Skywa… blond      fair       blue            19   male  mascu… Tatooine 
    #>  2 C-3PO       <NA>       gold       yellow         112   none  mascu… Tatooine 
    #>  3 R2-D2       <NA>       white, bl… red             33   none  mascu… Naboo    
    #>  4 Darth Vader none       white      yellow          41.9 male  mascu… Tatooine 
    #>  5 Leia Organa brown      light      brown           19   fema… femin… Alderaan 
    #>  6 Owen Lars   brown, gr… light      blue            52   male  mascu… Tatooine 
    #>  7 Beru White… brown      light      blue            47   fema… femin… Tatooine 
    #>  8 R5-D4       <NA>       white, red red             NA   none  mascu… Tatooine 
    #>  9 Biggs Dark… black      light      brown           24   male  mascu… Tatooine 
    #> 10 Obi-Wan Ke… auburn, w… fair       blue-gray       57   male  mascu… Stewjon  
    #> # ℹ 77 more rows
    #> # ℹ 4 more variables: species <chr>, films <list>, vehicles <list>,
    #> #   starships <list>

``` r
# Drop columns from mass to skin_color
select(starwars, !(mass:skin_color))
```

    #> # A tibble: 87 × 11
    #>    name         height eye_color birth_year sex   gender homeworld species films
    #>    <chr>         <int> <chr>          <dbl> <chr> <chr>  <chr>     <chr>   <lis>
    #>  1 Luke Skywal…    172 blue            19   male  mascu… Tatooine  Human   <chr>
    #>  2 C-3PO           167 yellow         112   none  mascu… Tatooine  Droid   <chr>
    #>  3 R2-D2            96 red             33   none  mascu… Naboo     Droid   <chr>
    #>  4 Darth Vader     202 yellow          41.9 male  mascu… Tatooine  Human   <chr>
    #>  5 Leia Organa     150 brown           19   fema… femin… Alderaan  Human   <chr>
    #>  6 Owen Lars       178 blue            52   male  mascu… Tatooine  Human   <chr>
    #>  7 Beru Whites…    165 blue            47   fema… femin… Tatooine  Human   <chr>
    #>  8 R5-D4            97 red             NA   none  mascu… Tatooine  Droid   <chr>
    #>  9 Biggs Darkl…    183 brown           24   male  mascu… Tatooine  Human   <chr>
    #> 10 Obi-Wan Ken…    182 blue-gray       57   male  mascu… Stewjon   Human   <chr>
    #> # ℹ 77 more rows
    #> # ℹ 2 more variables: vehicles <list>, starships <list>

#### `select`: Keep or drop columns (2 / 2)

The `dplyr` package also provides a handy set of modifiers (`contains`,
`ends_with`, `where` etc) that let you select columns based on a pattern
of names. This is very handy especially when you want to pick multiple
columns, but don’t want to type each column name separately.

To get the most out of this, please run each example separately. Also,
look up the examples in the package by typing `? dplyr::select` in your
R console. These functions are the basic building blocks of data
manipulation and provide you with a very wide toolkit. The more you are
able to hold these in your muscle memory, the more adept you will become
with data manipulation.

``` r
# Keep columns containing the word "color"
select(starwars, contains("color"))
```

    #> # A tibble: 87 × 3
    #>    hair_color    skin_color  eye_color
    #>    <chr>         <chr>       <chr>    
    #>  1 blond         fair        blue     
    #>  2 <NA>          gold        yellow   
    #>  3 <NA>          white, blue red      
    #>  4 none          white       yellow   
    #>  5 brown         light       brown    
    #>  6 brown, grey   light       blue     
    #>  7 brown         light       blue     
    #>  8 <NA>          white, red  red      
    #>  9 black         light       brown    
    #> 10 auburn, white fair        blue-gray
    #> # ℹ 77 more rows

``` r
# Keep columns ending with the word "color"
select(starwars, ends_with("color"))
```

    #> # A tibble: 87 × 3
    #>    hair_color    skin_color  eye_color
    #>    <chr>         <chr>       <chr>    
    #>  1 blond         fair        blue     
    #>  2 <NA>          gold        yellow   
    #>  3 <NA>          white, blue red      
    #>  4 none          white       yellow   
    #>  5 brown         light       brown    
    #>  6 brown, grey   light       blue     
    #>  7 brown         light       blue     
    #>  8 <NA>          white, red  red      
    #>  9 black         light       brown    
    #> 10 auburn, white fair        blue-gray
    #> # ℹ 77 more rows

``` r
# Keep columns which are numeric
select(starwars, where(is.numeric))
```

    #> # A tibble: 87 × 3
    #>    height  mass birth_year
    #>     <int> <dbl>      <dbl>
    #>  1    172    77       19  
    #>  2    167    75      112  
    #>  3     96    32       33  
    #>  4    202   136       41.9
    #>  5    150    49       19  
    #>  6    178   120       52  
    #>  7    165    75       47  
    #>  8     97    32       NA  
    #>  9    183    84       24  
    #> 10    182    77       57  
    #> # ℹ 77 more rows

``` r
# Keep columns which are lists
select(starwars, where(is.list))
```

    #> # A tibble: 87 × 3
    #>    films     vehicles  starships
    #>    <list>    <list>    <list>   
    #>  1 <chr [5]> <chr [2]> <chr [2]>
    #>  2 <chr [6]> <chr [0]> <chr [0]>
    #>  3 <chr [7]> <chr [0]> <chr [0]>
    #>  4 <chr [4]> <chr [0]> <chr [1]>
    #>  5 <chr [5]> <chr [1]> <chr [0]>
    #>  6 <chr [3]> <chr [0]> <chr [0]>
    #>  7 <chr [3]> <chr [0]> <chr [0]>
    #>  8 <chr [1]> <chr [0]> <chr [0]>
    #>  9 <chr [1]> <chr [0]> <chr [1]>
    #> 10 <chr [6]> <chr [1]> <chr [5]>
    #> # ℹ 77 more rows

#### `mutate`: Create, modify, and delete columns

``` r
# Create column mass_lbs
mutate(starwars, mass_lbs = mass * 2.2)
```

    #> # A tibble: 87 × 15
    #>    name     height  mass hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>     <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Luke Sk…    172    77 blond      fair       blue            19   male  mascu…
    #>  2 C-3PO       167    75 <NA>       gold       yellow         112   none  mascu…
    #>  3 R2-D2        96    32 <NA>       white, bl… red             33   none  mascu…
    #>  4 Darth V…    202   136 none       white      yellow          41.9 male  mascu…
    #>  5 Leia Or…    150    49 brown      light      brown           19   fema… femin…
    #>  6 Owen La…    178   120 brown, gr… light      blue            52   male  mascu…
    #>  7 Beru Wh…    165    75 brown      light      blue            47   fema… femin…
    #>  8 R5-D4        97    32 <NA>       white, red red             NA   none  mascu…
    #>  9 Biggs D…    183    84 black      light      brown           24   male  mascu…
    #> 10 Obi-Wan…    182    77 auburn, w… fair       blue-gray       57   male  mascu…
    #> # ℹ 77 more rows
    #> # ℹ 6 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>, mass_lbs <dbl>

``` r
# Modify column height
mutate(starwars, height = height * 0.0328084)
```

    #> # A tibble: 87 × 14
    #>    name     height  mass hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>     <dbl> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Luke Sk…   5.64    77 blond      fair       blue            19   male  mascu…
    #>  2 C-3PO      5.48    75 <NA>       gold       yellow         112   none  mascu…
    #>  3 R2-D2      3.15    32 <NA>       white, bl… red             33   none  mascu…
    #>  4 Darth V…   6.63   136 none       white      yellow          41.9 male  mascu…
    #>  5 Leia Or…   4.92    49 brown      light      brown           19   fema… femin…
    #>  6 Owen La…   5.84   120 brown, gr… light      blue            52   male  mascu…
    #>  7 Beru Wh…   5.41    75 brown      light      blue            47   fema… femin…
    #>  8 R5-D4      3.18    32 <NA>       white, red red             NA   none  mascu…
    #>  9 Biggs D…   6.00    84 black      light      brown           24   male  mascu…
    #> 10 Obi-Wan…   5.97    77 auburn, w… fair       blue-gray       57   male  mascu…
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Remove column: 
mutate(starwars, mass = NULL)
```

    #> # A tibble: 87 × 13
    #>    name           height hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>           <int> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Luke Skywalker    172 blond      fair       blue            19   male  mascu…
    #>  2 C-3PO             167 <NA>       gold       yellow         112   none  mascu…
    #>  3 R2-D2              96 <NA>       white, bl… red             33   none  mascu…
    #>  4 Darth Vader       202 none       white      yellow          41.9 male  mascu…
    #>  5 Leia Organa       150 brown      light      brown           19   fema… femin…
    #>  6 Owen Lars         178 brown, gr… light      blue            52   male  mascu…
    #>  7 Beru Whitesun…    165 brown      light      blue            47   fema… femin…
    #>  8 R5-D4              97 <NA>       white, red red             NA   none  mascu…
    #>  9 Biggs Darklig…    183 black      light      brown           24   male  mascu…
    #> 10 Obi-Wan Kenobi    182 auburn, w… fair       blue-gray       57   male  mascu…
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Do it all at once
mutate(starwars, mass_lbs = mass * 2.2, mass = NULL)
```

    #> # A tibble: 87 × 14
    #>    name           height hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>           <int> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Luke Skywalker    172 blond      fair       blue            19   male  mascu…
    #>  2 C-3PO             167 <NA>       gold       yellow         112   none  mascu…
    #>  3 R2-D2              96 <NA>       white, bl… red             33   none  mascu…
    #>  4 Darth Vader       202 none       white      yellow          41.9 male  mascu…
    #>  5 Leia Organa       150 brown      light      brown           19   fema… femin…
    #>  6 Owen Lars         178 brown, gr… light      blue            52   male  mascu…
    #>  7 Beru Whitesun…    165 brown      light      blue            47   fema… femin…
    #>  8 R5-D4              97 <NA>       white, red red             NA   none  mascu…
    #>  9 Biggs Darklig…    183 black      light      brown           24   male  mascu…
    #> 10 Obi-Wan Kenobi    182 auburn, w… fair       blue-gray       57   male  mascu…
    #> # ℹ 77 more rows
    #> # ℹ 6 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>, mass_lbs <dbl>

#### `rename`: Rename columns

``` r
# Rename
rename(starwars, mass_kgs = mass)
```

    #> # A tibble: 87 × 14
    #>    name  height mass_kgs hair_color skin_color eye_color birth_year sex   gender
    #>    <chr>  <int>    <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Luke…    172       77 blond      fair       blue            19   male  mascu…
    #>  2 C-3PO    167       75 <NA>       gold       yellow         112   none  mascu…
    #>  3 R2-D2     96       32 <NA>       white, bl… red             33   none  mascu…
    #>  4 Dart…    202      136 none       white      yellow          41.9 male  mascu…
    #>  5 Leia…    150       49 brown      light      brown           19   fema… femin…
    #>  6 Owen…    178      120 brown, gr… light      blue            52   male  mascu…
    #>  7 Beru…    165       75 brown      light      blue            47   fema… femin…
    #>  8 R5-D4     97       32 <NA>       white, red red             NA   none  mascu…
    #>  9 Bigg…    183       84 black      light      brown           24   male  mascu…
    #> 10 Obi-…    182       77 auburn, w… fair       blue-gray       57   male  mascu…
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Rename ALL columns to uppercase
rename_with(starwars, toupper)
```

    #> # A tibble: 87 × 14
    #>    NAME     HEIGHT  MASS HAIR_COLOR SKIN_COLOR EYE_COLOR BIRTH_YEAR SEX   GENDER
    #>    <chr>     <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Luke Sk…    172    77 blond      fair       blue            19   male  mascu…
    #>  2 C-3PO       167    75 <NA>       gold       yellow         112   none  mascu…
    #>  3 R2-D2        96    32 <NA>       white, bl… red             33   none  mascu…
    #>  4 Darth V…    202   136 none       white      yellow          41.9 male  mascu…
    #>  5 Leia Or…    150    49 brown      light      brown           19   fema… femin…
    #>  6 Owen La…    178   120 brown, gr… light      blue            52   male  mascu…
    #>  7 Beru Wh…    165    75 brown      light      blue            47   fema… femin…
    #>  8 R5-D4        97    32 <NA>       white, red red             NA   none  mascu…
    #>  9 Biggs D…    183    84 black      light      brown           24   male  mascu…
    #> 10 Obi-Wan…    182    77 auburn, w… fair       blue-gray       57   male  mascu…
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: HOMEWORLD <chr>, SPECIES <chr>, FILMS <list>,
    #> #   VEHICLES <list>, STARSHIPS <list>

``` r
# Rename “color” columns to uppercase
rename_with(starwars, toupper, ends_with("color"))
```

    #> # A tibble: 87 × 14
    #>    name     height  mass HAIR_COLOR SKIN_COLOR EYE_COLOR birth_year sex   gender
    #>    <chr>     <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
    #>  1 Luke Sk…    172    77 blond      fair       blue            19   male  mascu…
    #>  2 C-3PO       167    75 <NA>       gold       yellow         112   none  mascu…
    #>  3 R2-D2        96    32 <NA>       white, bl… red             33   none  mascu…
    #>  4 Darth V…    202   136 none       white      yellow          41.9 male  mascu…
    #>  5 Leia Or…    150    49 brown      light      brown           19   fema… femin…
    #>  6 Owen La…    178   120 brown, gr… light      blue            52   male  mascu…
    #>  7 Beru Wh…    165    75 brown      light      blue            47   fema… femin…
    #>  8 R5-D4        97    32 <NA>       white, red red             NA   none  mascu…
    #>  9 Biggs D…    183    84 black      light      brown           24   male  mascu…
    #> 10 Obi-Wan…    182    77 auburn, w… fair       blue-gray       57   male  mascu…
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

#### `relocate`: Relocate columns

``` r
# Relocate column AFTER a column
relocate(starwars, sex, .after = name)
```

    #> # A tibble: 87 × 14
    #>    name     sex   height  mass hair_color skin_color eye_color birth_year gender
    #>    <chr>    <chr>  <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> 
    #>  1 Luke Sk… male     172    77 blond      fair       blue            19   mascu…
    #>  2 C-3PO    none     167    75 <NA>       gold       yellow         112   mascu…
    #>  3 R2-D2    none      96    32 <NA>       white, bl… red             33   mascu…
    #>  4 Darth V… male     202   136 none       white      yellow          41.9 mascu…
    #>  5 Leia Or… fema…    150    49 brown      light      brown           19   femin…
    #>  6 Owen La… male     178   120 brown, gr… light      blue            52   mascu…
    #>  7 Beru Wh… fema…    165    75 brown      light      blue            47   femin…
    #>  8 R5-D4    none      97    32 <NA>       white, red red             NA   mascu…
    #>  9 Biggs D… male     183    84 black      light      brown           24   mascu…
    #> 10 Obi-Wan… male     182    77 auburn, w… fair       blue-gray       57   mascu…
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Relocate a column BEFORE a column
relocate(starwars, sex, .before = mass)
```

    #> # A tibble: 87 × 14
    #>    name     height sex    mass hair_color skin_color eye_color birth_year gender
    #>    <chr>     <int> <chr> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> 
    #>  1 Luke Sk…    172 male     77 blond      fair       blue            19   mascu…
    #>  2 C-3PO       167 none     75 <NA>       gold       yellow         112   mascu…
    #>  3 R2-D2        96 none     32 <NA>       white, bl… red             33   mascu…
    #>  4 Darth V…    202 male    136 none       white      yellow          41.9 mascu…
    #>  5 Leia Or…    150 fema…    49 brown      light      brown           19   femin…
    #>  6 Owen La…    178 male    120 brown, gr… light      blue            52   mascu…
    #>  7 Beru Wh…    165 fema…    75 brown      light      blue            47   femin…
    #>  8 R5-D4        97 none     32 <NA>       white, red red             NA   mascu…
    #>  9 Biggs D…    183 male     84 black      light      brown           24   mascu…
    #> 10 Obi-Wan…    182 male     77 auburn, w… fair       blue-gray       57   mascu…
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: homeworld <chr>, species <chr>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Relocate ALL character columns to the front
relocate(starwars, where(is.character))
```

    #> # A tibble: 87 × 14
    #>    name    hair_color skin_color eye_color sex   gender homeworld species height
    #>    <chr>   <chr>      <chr>      <chr>     <chr> <chr>  <chr>     <chr>    <int>
    #>  1 Luke S… blond      fair       blue      male  mascu… Tatooine  Human      172
    #>  2 C-3PO   <NA>       gold       yellow    none  mascu… Tatooine  Droid      167
    #>  3 R2-D2   <NA>       white, bl… red       none  mascu… Naboo     Droid       96
    #>  4 Darth … none       white      yellow    male  mascu… Tatooine  Human      202
    #>  5 Leia O… brown      light      brown     fema… femin… Alderaan  Human      150
    #>  6 Owen L… brown, gr… light      blue      male  mascu… Tatooine  Human      178
    #>  7 Beru W… brown      light      blue      fema… femin… Tatooine  Human      165
    #>  8 R5-D4   <NA>       white, red red       none  mascu… Tatooine  Droid       97
    #>  9 Biggs … black      light      brown     male  mascu… Tatooine  Human      183
    #> 10 Obi-Wa… auburn, w… fair       blue-gray male  mascu… Stewjon   Human      182
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: mass <dbl>, birth_year <dbl>, films <list>,
    #> #   vehicles <list>, starships <list>

``` r
# Relocate all NUMERIC columns AFTER all CHARACTER columns
relocate(starwars, where(is.numeric), .after = where(is.character))
```

    #> # A tibble: 87 × 14
    #>    name    hair_color skin_color eye_color sex   gender homeworld species height
    #>    <chr>   <chr>      <chr>      <chr>     <chr> <chr>  <chr>     <chr>    <int>
    #>  1 Luke S… blond      fair       blue      male  mascu… Tatooine  Human      172
    #>  2 C-3PO   <NA>       gold       yellow    none  mascu… Tatooine  Droid      167
    #>  3 R2-D2   <NA>       white, bl… red       none  mascu… Naboo     Droid       96
    #>  4 Darth … none       white      yellow    male  mascu… Tatooine  Human      202
    #>  5 Leia O… brown      light      brown     fema… femin… Alderaan  Human      150
    #>  6 Owen L… brown, gr… light      blue      male  mascu… Tatooine  Human      178
    #>  7 Beru W… brown      light      blue      fema… femin… Tatooine  Human      165
    #>  8 R5-D4   <NA>       white, red red       none  mascu… Tatooine  Droid       97
    #>  9 Biggs … black      light      brown     male  mascu… Tatooine  Human      183
    #> 10 Obi-Wa… auburn, w… fair       blue-gray male  mascu… Stewjon   Human      182
    #> # ℹ 77 more rows
    #> # ℹ 5 more variables: mass <dbl>, birth_year <dbl>, films <list>,
    #> #   vehicles <list>, starships <list>
