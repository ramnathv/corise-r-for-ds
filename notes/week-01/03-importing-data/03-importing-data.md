
## Importing Data

Importing data refers to the process of reading data from an external
file or data source into an R session or environment. This is an
important step in many data science projects, as it allows you to work
with real-world data in R.

<img src="https://i.imgur.com/Up3eaUJ.png" width="100%" />

In R, there are several functions and packages that can be used to
import data. Some of the most commonly used ones are:

- `read.table()`, `read.csv()`, and `read.delim()`: These are base R
  functions for reading in tabular data from text files with different
  formats.

- `readr::read_csv()` and `readr::read_tsv()`: These are functions from
  the `readr` package, which provides fast and efficient reading of
  tabular data with more flexible options for handling missing values,
  column types, and so on.

- `haven::read_sas()`, `haven::read_dta()`, `haven::read_spss()`: These
  are functions from the `haven` package, which can be used to read in
  data from SAS, Stata, and SPSS files respectively.

- `readxl::read_excel()`: This is a function from the `readxl` package,
  which can be used to read in data from Excel files.

- `httr::GET()`: This function can be used to retrieve data from a web
  API or a remote data source over the internet.

### Download Zip File

In this course, we will be working with a very interesting dataset of
100+ years of US baby names from the Social Security Administration
(SSA). The raw data is available on the SSA website as a zip file, and
we will start our data import by downloading this zip file.

``` r
NAMES_URL <- "https://www.ssa.gov/oact/babynames/names.zip"
DOWNLOAD_DIR <- here::here("data")
NAMES_ZIP <- file.path(DOWNLOAD_DIR, basename(NAMES_URL))

# Download `NAMES_ZIP` from `NAMES_URL` if it does not already exist
if (!file.exists(NAMES_ZIP)) {
  download.file(NAMES_URL, NAMES_ZIP)
}
```

The `download.file()` function is used to download the zip file from the
URL specified in `NAMES_URL` and save it to the location specified in
`NAMES_ZIP`. Note that we first check if the file to be downloaded
already exists and download it ONLY if it has not been downloaded
already.

After running this code, the zip file containing baby names data from
the SSA website will be downloaded and saved to the specified
`DOWNLOAD_DIR` directory with the file name specified in `NAMES_ZIP`.

------------------------------------------------------------------------

To become a good data scientist, you need to focus on three things:

1.  Identify WHAT needs to be done?
2.  Identify the STEPS to accomplish the task.
3.  Write code to execute the steps.

The first two areas are typically language agnostic and require one to
focus on the ability to define a problem and break it down into steps.
The last area is language specific, and knowing the language and its
ecosystem well will allow you to write highly performant, concise code.

------------------------------------------------------------------------

### Explore Zip File

Before we can import the data into R, we need to explore the contents of
the zip file. Let us list the files contained within the zip file,
without actually unzipping them.

``` r
files <- unzip(NAMES_ZIP, list = TRUE)
head(files)
#>          Name Length                Date
#> 1 yob1880.txt  24933 2022-04-14 18:23:00
#> 2 yob1881.txt  24052 2022-04-14 18:23:00
#> 3 yob1882.txt  26559 2022-04-14 18:23:00
#> 4 yob1883.txt  26002 2022-04-14 18:23:00
#> 5 yob1884.txt  28670 2022-04-14 18:23:00
#> 6 yob1885.txt  28625 2022-04-14 18:23:00
```

The `unzip()` function is used to extract information about the contents
of the zip file, with the `list = TRUE` argument specified to only list
the files within the zip file, rather than extracting them.

The `head()` function is used to display the first 6 rows (by default)
of an object. In this case, it will show the first 6 rows of the `files`
object. If you wanted to see the first 10 rows instead, you could add a
second argument to the `head()` function, e.g., `head(file, n = 10)`.

Looking at the `files` object, it seems like the data is stored as
multiple text files, one for each year.

------------------------------------------------------------------------

Learning a programming language is very similar to how you would learn a
new language. You need to start with the **letters** of the alphabet,
put them together to form **words**, put words into **sentences**,
sentences into **paragraphs**, and paragraphs into **documents**.

Becoming a good data scientist requires you to build a strong vocabulary
of functionality. The area where the `tidyverse` shines bright is that
it provides you with a highly consistent vocabulary of small building
blocks that can be strung together to accomplish complex tasks.

One learning tip I can give you is that every time you encounter a new
function, write it down with an example and fill in your own
description. Periodically refer to this so you internalize this in your
mind.

------------------------------------------------------------------------

### Explore Text File

Let us read the first 5 lines of the text file `yob1880.txt` located
within the zip file downloaded. We can do this using the `unz()`
function to create a connection to the zip file `yob1880.txt`, and read
the first 5 lines of this text file.

When dealing with text files, it is really important to take the time to
read the first few lines of data so you can understand how it is
formatted, and what would be the appropriate function to use to import
it as a data frame.

``` r
file_con <- unz(NAMES_ZIP, 'yob1880.txt')
readLines(file_con, n = 5)
#> [1] "Mary,F,7065"      "Anna,F,2604"      "Emma,F,2003"      "Elizabeth,F,1939"
#> [5] "Minnie,F,1746"
```

It seems like each line of this file holds comma separated values. This
is the most common type of text data you will find, and we can read it
as a data frame into R using the `read_csv()` function from `readr`.

Another important point to note is that this text file does NOT contain
a row with the column headers. Hence, we will need to specify it
explicitly when we read the data into R.

### Read CSV File

Let us now read the text file `yob1880.txt`, into a data frame using the
`read_csv()` function from the `readr` package. We will use the
connection object `file_con` that we created previously.

``` r
tbl_names <- readr::read_csv(
  file = file_con, 
  col_names = c('name', 'sex', 'nb_births'),
  show_col_types = FALSE
)

tbl_names
#> # A tibble: 2,000 × 3
#>    name      sex   nb_births
#>    <chr>     <chr>     <dbl>
#>  1 Mary      F          7065
#>  2 Anna      F          2604
#>  3 Emma      F          2003
#>  4 Elizabeth F          1939
#>  5 Minnie    F          1746
#>  6 Margaret  F          1578
#>  7 Ida       F          1472
#>  8 Alice     F          1414
#>  9 Bertha    F          1320
#> 10 Sarah     F          1288
#> # ℹ 1,990 more rows
```

1.  The `file` argument specifies the connection to the text file to be
    read.
2.  The `col_names` argument specifies the column names to be assigned
    to the resulting data frame, with the first column being named
    ‘name’, the second column being named ‘sex’, and the third column
    being named ‘nb_births’.
3.  The `show_col_types` argument is set to `FALSE`, which means that
    column types will not be displayed as the data is read in.

The resulting `tbl_names` object is a data frame containing the baby
names data, with one row per name and columns for name, sex, and the
number of births for that name.

### Unzip Zip File

We are now ready to read data from all the text files in the zip file.
In order to do this, we should first unzip the contents of the zip file
`NAMES_ZIP` to a temporary directory `NAMES_DIR`, and then get the paths
to all the text files as the variable `NAMES_TXT_FILES`.

``` r
NAMES_DIR <- tempdir()
unzip(NAMES_ZIP, exdir = NAMES_DIR)
NAMES_TXT_FILES <- fs::dir_ls(NAMES_DIR, glob = "*.txt")
head(NAMES_TXT_FILES)
#> /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpRpZfa9/yob1880.txt
#> /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpRpZfa9/yob1881.txt
#> /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpRpZfa9/yob1882.txt
#> /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpRpZfa9/yob1883.txt
#> /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpRpZfa9/yob1884.txt
#> /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpRpZfa9/yob1885.txt
```

### Read CSV Files

We can now use the `read_csv` function from the `readr` package to read
all the text files into a data frame. It is important to understand the
arguments to this function, as it is one of the most commonly used
import functions.

1.  The `file` argument specifies the file to read in, and in this case,
    it is `NAMES_TXT_FILES`, which is a character vector containing the
    paths to all the text files in the directory.

2.  The `col_names` argument specifies the names of the columns in the
    CSV file. In this case, the file has three columns: `name`, `sex`,
    and `nb_births`.

3.  The `show_col_types` argument is set to `FALSE`, which means that
    the function will not print the types of the columns.

4.  The `id = 'year'` argument specifies that the path to the file
    should be added as an extra column named `year`. This is required in
    order to add the `year` information to the data frame, since it is
    not already present.

``` r
tbl_names <- readr::read_csv(
  file = NAMES_TXT_FILES,
  col_names = c('name', 'sex', 'nb_births'),
  show_col_types = FALSE,
  id = 'year'
)

tbl_names
#> # A tibble: 2,052,781 × 4
#>    year                                                    name  sex   nb_births
#>    <chr>                                                   <chr> <chr>     <dbl>
#>  1 /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpR… Mary  F          7065
#>  2 /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpR… Anna  F          2604
#>  3 /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpR… Emma  F          2003
#>  4 /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpR… Eliz… F          1939
#>  5 /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpR… Minn… F          1746
#>  6 /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpR… Marg… F          1578
#>  7 /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpR… Ida   F          1472
#>  8 /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpR… Alice F          1414
#>  9 /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpR… Bert… F          1320
#> 10 /var/folders/8_/dp4gxnx554g5064bqc49b6rw0000gn/T/RtmpR… Sarah F          1288
#> # ℹ 2,052,771 more rows
```

Note that the `year` column contains the full path to the text file and
hence we will need to extract just the numerical portion of the file
name. We can use the `mutate()` function from the `dplyr` package to
modify the `year` column and replace its values by the parsed numerical
value of year.

``` r
tbl_names <- tbl_names |> 
  dplyr::mutate(year = readr::parse_number(basename(year))) 

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

### Write CSV File

The final step is to write the imported and tidied data to a compressed
csv file, using the `write_csv()` function from the `readr` package.
Note that it is best to save csv files with compression in order to keep
the file size small.

``` r
NAMES_CSV_GZ <- file.path(here::here("data"), 'names.csv.gz')
readr::write_csv(tbl_names, gzfile(NAMES_CSV_GZ))
```

You will be using this babynames data for your first project.
