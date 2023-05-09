
## Questions from Week 01 \> Lecture 01

🙏 Thanks for all the wonderful questions you asked during Lecture 01.
Asking questions constantly is the best way to learn. So, please keep
them coming and we will try and do our best to answer them.

### Assignment Operators in R

> What are the differences between different assignment operators `=`,
> `<-`, `->`, `<<-`, `-->` and what should we use?

**TLDR; Use the `<-` operator for assignment.**

For a more detailed explanation, please read along!

R has three different assignment operators, two of which have leftwards
and rightwards forms

1.  `=`,
2.  Local Assignment: `<-`, and `->`
3.  Global Assignment: `<<-`, and `-->`

#### `<-` vs. `=`

For all practical purposes, you can use the `=` operator for assignment
in place of `<-`. However, the `=` operator can also be used inside a
function to pass values to arguments. As a result, the `<-` is the
preferred assignment operator as it makes it amply clear that you are
assigning the value of the RHS to the name on the LHS.

Let us illustrate this difference with an example. Consider the function
`baz()`. It accepts an argument named `z` and returns it.

``` r
baz <- function(z) {
  z
}
```

We use the `=` operator to pass values to the arguments of a function.
Hence, if we try to access the variable `z` outside the function, you
will get an error.

``` r
print(baz(z = 10))
#> [1] 10
print(z)
#> Error in eval(expr, envir, enclos): object 'z' not found
```

If you use the `<-` operator instead of the `=` operator to pass values
to the arguments of a function, you are essentially assigning a new
variable, which is accessible outside the function as well.

``` r
print(baz(z <- 10))
#> [1] 10
print(z)
#> [1] 10
```

In order to keep this disinction clear, we use the `<-` for assignment,
and the `=` to pass values to arguments of a function.

#### `<-` vs. `->`

The `->` is the right assignment operator, and just reverses the
positions of the LHS and RHS. In other words `x <- 3` and `3 -> x` are
equivalent. The right assignment operator is rarely used in R. The one
passably valid use case is when you want to pipe the output of a
pipeline to a variable.

``` r
state.name |> 
  substr(1, 1) |> 
  table() -> letter_counts

letter_counts
#> 
#> A C D F G H I K L M N O P R S T U V W 
#> 4 3 1 1 1 1 4 2 1 8 8 3 1 1 2 2 1 2 4
```

In spite of `->` being syntactically valid and having a passable use
case, I would NOT recommend using it in practice.

#### `<-` vs. `<<-`

The `<<-` operator is the global assignment operator and is mainly used
inside a function to assign values to the global environment. You can
understand it better by considering the following two functions `foo()`
and `bar()`.

Both functions assign a value to `x`. However, printing `x` after
running `foo()` returns an error, since `x` has only been assigned
locally inside the function and as a result is NOT defined in the
environment outside.

``` r
foo <- function() {
  x <- 10
}
foo()
print(x)
#> Error in eval(expr, envir, enclos): object 'x' not found
```

On the other hand, the `bar()` function uses the global assignment
operator, `<<-` and hence R is able to find it in the environment
external to the function.

``` r
bar <- function() {
  x <<- 10
}
bar()
print(x)
#> [1] 10
```

R favors a functional programming style, and pure functions should have
ZERO side effects. Global assignment violates this principle and can be
the source of a lot of bugs. Hence, I would strongly recommend NOT using
the `<<-` operator unless you absolutely have to, and know exactly what
you are doing.

### Double Colon Operator

If you type <code>?`::`</code> in your R console, you will see the
following documentation.

> For a package `pkg`, `pkg::name` returns the value of the exported
> variable name in namespace `pkg`, whereas `pkg:::name` returns the
> value of the **internal** variable name. The package namespace will be
> loaded if it was not loaded before the call, but the package will not
> be attached to the search path.

### Pipe Operators

> What is the difference between the `|>` and `%>%` operators in R?

The `|>` operator is the native pipe operator introduced in R 4.1 as a
part of the base language, while the `%>%` is the magrittr pipe operator
that was introduced in the `magrittr` package and was widely adopted by
the R community prior to the introduction of `|>`.

While on the surface, they appear to do the same thing, there are
several differences between the two operators. The native pipe operator
is preferred for performance reasons, and will be the only pipe operator
used in this course.

If you are interested to understand the nuances in more detail, I would
strongly recommend this
[article](https://www.tidyverse.org/blog/2023/04/base-vs-magrittr-pipe/)
by Hadley Wickham. You can also learn more by typing
`?`\|\>`` and `?magrittr::`%>% `` in your R console.

### Function Help

There are several questions around what specific functions in R do
(e.g. `c()`, `rnorm()`, `substr()`). Let me answer them at a high level
to start with.

The `c()` function combines values into a vector or a list.

``` r
x <- c(2, 3, 4)
x
#> [1] 2 3 4
y <- c(c(1, 2), c(3, 4))
y
#> [1] 1 2 3 4
```

The `rnorm()` function generates a vector of [random normal
variables](https://en.wikipedia.org/wiki/Normal_distribution).

``` r
rnorm(5)
#> [1]  0.3093004 -0.4670386  0.2340759  0.8361838 -0.8549110
```

The `substr()` function extracts a substring from a string.

``` r
x <- "I love R"
substr(x, 1, 1)
#> [1] "I"
substr(x, 1, 3)
#> [1] "I l"
```

However, any example I provide you will almost always only scratch the
surface of what that function is capable of. So, how do you go about
learning more about the function? Thankfully, R and most of its packages
are wonderfully documented, and they are only a question-mark away. If
you type `? function` in your R console, you will get detailed
documentation on the function along with several examples. RStudio even
lets you run all the examples with a single click. The examples will
always teach you way more than can be covered in a course.

TLDR; If you have a question about a function, use the `?` to access
documentation and examples.

### Copy on Modify

> When you create a new column in a data frame in R, does it modify the
> original data frame?

**TLDR; NO. It creates a new data frame. However, the original columns
are still shared between the two data frames.**

For those of you coming from other languages, you would be familiar with
the **copy by value** vs. **copy_by_reference** paradigm. The key
difference is that under the copy by value paradigm, `x = y` implies
that you are copying the value of `y` into `x`. As a result, if you
modify the object `y`, it does NOT modify the object `x`. However, under
copy by reference, `x = y` is tying `x` to `y` at the hip and from then
on, whatever you do with one affects the other.

R has evolved over time trying to strike a careful balance between these
two paradigms. The best way to described R’s approach to this problem is
that it copies on modify. Let us try to understand this with a few
examples.

Consider a data frame `df` with two columns `x` and `y`. We can use the
`ref()` function from the `lobstr()` package to print the memory
addresses of the objects.

``` r
df1 <- data.frame(x = 1:10, y = 1:10)
lobstr::ref(df1)
#> █ [1:0x139a09e08] <df[,2]> 
#> ├─x = [2:0x1505625a0] <int> 
#> └─y = [3:0x150562488] <int>
```

Suppose, we assign `df2 <- df1`. Let us print out the memory addresses
for `df1` and `df2`

``` r
df2 <- df1
lobstr::ref(df2)
#> █ [1:0x139a09e08] <df[,2]> 
#> ├─x = [2:0x1505625a0] <int> 
#> └─y = [3:0x150562488] <int>
```

Notice that `df1` and `df2` are pointing to the exact same memory
address and so do their columns `x` and `y`. In other words, it seems
like R follows **copy by reference**.

Now suppose, I add a third column `z` to `df1`. Let us print out the
memory addresses for `df1` and `df2` again.

``` r
df1$z <- 1:10
lobstr::ref(df1)
#> █ [1:0x11ad47758] <df[,3]> 
#> ├─x = [2:0x1505625a0] <int> 
#> ├─y = [3:0x150562488] <int> 
#> └─z = [4:0x11ad6d8a8] <int>
lobstr::ref(df2)
#> █ [1:0x139a09e08] <df[,2]> 
#> ├─x = [2:0x1505625a0] <int> 
#> └─y = [3:0x150562488] <int>
```

Notice how `df1` and `df2` now point to different memory addresses. In
other words R has made a copy of the object, when it was modified.
However, note that `x` and `y` columns are still shared between `df1`
and `df2` because they have not been modified.

**Copy on Modify** semantics allow R to follow a strong functional
programming paradigm while at the same time optimizing performance where
necessary.

### R Programming and Projects

> Do we need to refer to documents for R programming to learn different
> functions to complete projects or will everything taught in the
> lecture be enough?

The basic functionality required for the projects will be covered in the
lecture. However, it is strongly recommended to refer to documentation
whenever something is not clear, or you would like to learn more about
it.

> Can I copy the notebook, so that I work on the copied notebook
> instead?

YES! In fact, it is the preferred way to work on the course, since it
would allow you to sync contents from the parent github repository to
bring in any changes made to the content after you forked the
repository.

> Is R Studio necessary to be installed for this course or is the
> browser-based IDE enough?

We will be using RStudio in the cloud through Gitpod. So, you will NOT
need to install anything on your desktop for this course.

> Will we need to learn any new functions from outside the course
> materials to finish the project?

NO. Everything required to finish the project will be covered in the
course materials.

> Would an Introduction to Statistics course be helpful for learning R?

If you are planning to do statistics with R, then absolutely yes.
However, for this course, where we are mainly dealing with data
transformation and visualization, you do NOT need it as a prerequisite.

### Course Content

> Does the expression “filter(sex == ‘F’)” in R select only those rows
> where the sex column has the value “F”?

Yes!

> Can you explain how to use ggplot to create a plot in R?

This is covered in the course material for Week 1, and you can access it
on
[Corise](https://corise.com/course/r-for-data-science/v2/module/visualizing-data)
or
[Github](https://github.com/ramnathv/corise-r-for-ds/blob/main/notes/week-01/04-visualizing-data/04-visualizing-data.Rmd).

> How can you change the default color scheme in ggplot?

We won’t cover this in the course, but I would recommend looking it up
in one of the following two online books on `ggplot2`.

1.  [https://r-graphics.org/](R%20Graphics%20Cookbook)
2.  [ggplot2: Elegant Graphics for Data Analysis
    (3e)](https://ggplot2-book.org/)

### R Resources

> Do you have any resources or recommendations for someone new to R?

There is an excellent list of learning resources on RStudio’s education
site. They even categorize it based on your level of expertise. I would
strongly recommend using one of these resources.

1.  [Beginners](https://education.rstudio.com/learn/beginner/)
2.  [Intermediates](https://education.rstudio.com/learn/intermediate/)
3.  [Experts](https://education.rstudio.com/learn/expert/)

### Miscellanous

> Is there a resource that can help translate between mathematical
> concepts and their corresponding R functions?

Here is an [excellent
article](https://towardsdatascience.com/overview-of-40-mathematical-functions-in-r-4b4e138685ff)
that explains 40 different mathematical functions and their R
equivalents.

> What are the differences between `tidyverse` and `shiny`?

The `tidyverse` package is a collection of packages focused on
importing, tidying, visualizing, and modeling data. The `shiny` package
on the other hand allows you to build web applications entirely with R.
Together, they are a formidable combination and give you superpowers as
a data scientist.

> Is it possible to change the speed of dynamic visualization in R?

If you are referring to the animated plot we created during the first
lecture, then the answer is yes. We can use the `fps` argument to
`gganimate::animate()` to slow down or speed up the animation.
