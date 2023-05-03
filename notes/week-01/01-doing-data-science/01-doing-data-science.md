
### What is Data Science?

Data Science is an interdisciplinary field that involves the use of
scientific methods, processes, algorithms, and systems to extract
knowledge and insights from structured and unstructured data. It
involves combining knowledge and techniques from statistics,
mathematics, computer science, and domain-specific knowledge to analyze
and understand complex phenomena and solve problems.

Data Science encompasses a wide range of activities, including data
collection, cleaning, integration, analysis, modeling, and
visualization, as well as the communication of findings and insights to
stakeholders. It involves the use of various tools, techniques, and
technologies, including statistical software, machine learning
algorithms, data visualization tools, and big data platforms.

Data Science has numerous applications across industries, including
finance, healthcare, marketing, social media, and many others. The
insights and predictions derived from data analysis can be used to drive
business decisions, inform policy, and improve the lives of individuals
and communities.

### How to do Data Science?

![](https://imgur.com/jiBlLaM.png)

The first step almost always is to **import** data. Data comes in
different forms and shapes: files, databases, APIs etc. Before you can
start analyzing data, you need to bring it into the environment you are
working with.

Raw data is almost always NEVER clean. Hence, the next step in a typical
data science workflow is to **tidy** it. Tidying data often involves
cleaning

Now that you have clean data, the third step is to **transform** it. In
this step, you often manipulate individual variables, add new variables,
select observations of interest, aggregate values across specific groups
etc.

The real fun starts after you have transformed your data. The next step
in the journey is to **visualize** it. Visualizations let you explore
the data and gain insights.

An equally important part of the workflow is to **model** the data. This
involves analyzing hypotheses on the data as well as building
predictions.

The **transform** \> **visualize** \> **model** cycle is usually a
highly iterative one and one will find themselves tweaking each step
repeatedly till you find the optimal solution.

The last step in the workflow is to **communicate** the data. This is
done by turning your analysis into reports, dashboards, web apps and
other artifacts that can be shared across a broad range of stakeholders.

Our focus in this course will largely be on the **transform** and
**visualize** steps.

### Why R & Tidyverse?

<!-- Why R? -->

One of the biggest strengths of R is its extensive ecosystem of
**packages**. An R package is a suite of functions along with data and
documentation, that extends the functionality of base R.

<!-- Why Tidyverse -->

The Tidyverse is a highly opinionated set of packages that share a
common underlying grammar and philosophy and are designed to work
together to execute the data science workflow.

Rather than talk about the beauty of the `tidyverse`, I want you to
experience it for yourself by working through the next lesson that uses
the tidyverse to turn a dataset of US baby names into a beautiful
animated bar chart.

Shown below is a slightly more detailed roadmap of the data science
workflow. We will cover this in more detail in later lessons.

![data-science-workflow-detailed](https://i.imgur.com/dAuyiLz.png)
