
<figure>
<img src="https://img.shields.io/badge/License-Apache-blue.svg"
alt="License" />
<figcaption aria-hidden="true">License</figcaption>
</figure>

# uaparserjs

Parses HTTP user agent strings and returns user agent, device and OS
information.  
This is a ‘V8’-backed package that uses the UA, device and OS
definitions from the ‘ua-parser’ project <https://github.com/ua-parser>.

## Functions

The following functions are implemented:

- `ua_parse`: Parse a vector of user agents into a data frame

## Installation

``` r
#install.packages("uaparserjs")
```

## Example Usage

``` r
library(uaparserjs)

# current version
packageVersion("uaparserjs")
```

    ## [1] '0.4.1'

``` r
dplyr::glimpse(ua_parse("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 Chrome/15.0.874.106 Safari/535.2"))
```

    ## Rows: 1
    ## Columns: 9
    ## $ userAgent     <chr> "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTM…
    ## $ ua.family     <chr> "Chromium"
    ## $ ua.major      <chr> "15"
    ## $ ua.minor      <chr> "0"
    ## $ ua.patch      <chr> "874"
    ## $ os.family     <chr> "Ubuntu"
    ## $ os.major      <chr> "11"
    ## $ os.minor      <chr> "10"
    ## $ device.family <chr> "Other"

``` r
agents <- readLines(system.file("extdat", "agents.txt", package = "uaparserjs"))

dplyr::glimpse(ua_parse(agents))
```

    ## Rows: 1,091
    ## Columns: 13
    ## $ userAgent     <chr> "Mozilla/5.0 (Windows; U; en-US) AppleWebKit/531.9 (KHTM…
    ## $ ua.family     <chr> "AdobeAIR", "Amazon Silk", "Amazon Silk", "Amazon Silk",…
    ## $ ua.major      <chr> "2", "1", "2", "2", "2", "3", "2", "2", "2", "2", "3", "…
    ## $ ua.minor      <chr> "5", "1", "0", "1", "2", "25", "2", "3", "3", "3", "0", …
    ## $ ua.patch      <chr> "1", "0-80", NA, NA, NA, NA, "2", "3", "4", "5", "1", "3…
    ## $ os.family     <chr> "Windows", "Android", "Android", "Android", "Android", "…
    ## $ device.family <chr> "Other", "Kindle", "Kindle Fire HD", "Kindle Fire", "Kin…
    ## $ device.brand  <chr> NA, "Amazon", "Amazon", "Amazon", "Amazon", "Amazon", "H…
    ## $ device.model  <chr> NA, "Kindle", "Kindle Fire HD 7\"", "Kindle Fire", "Kind…
    ## $ os.major      <chr> NA, NA, NA, NA, NA, "4", "2", "2", "2", "2", "3", "4", "…
    ## $ os.minor      <chr> NA, NA, NA, NA, NA, "0", "2", "3", "3", "3", "0", "0", "…
    ## $ os.patch      <chr> NA, NA, NA, NA, NA, "3", "2", "3", "4", "5", "1", "3", "…
    ## $ os.patchMinor <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …

## Performance

This release uses an env as a cache instead of a list. Retrieval of
values is noticeably faster with an environment than with a list but
storage is slower.  
As is always the case with caching, the ratio of retrieval to storage
determines the how (and whether) the store/retrieve cost trade-offs pay
off.

### Time for parsing small numbers of UA strings with useNA defaulting to FALSE and list cache

``` r
uaparserjs:::cache_reset(list())

microbenchmark::microbenchmark(
  ua_parse(agents)
)
```

    ## Unit: milliseconds
    ##              expr      min       lq     mean   median       uq      max neval
    ##  ua_parse(agents) 286.0651 312.7861 334.4441 329.1934 339.3808 1153.523   100

### Time for parsing small numbers of UA strings with useNA defaulting to FALSE and an env type cache

``` r
uaparserjs:::cache_reset(new.env())

microbenchmark::microbenchmark(
  ua_parse(agents)
)
```

    ## Unit: milliseconds
    ##              expr      min       lq     mean   median       uq      max neval
    ##  ua_parse(agents) 291.1911 311.9968 333.8409 326.0195 336.7081 1099.453   100

### Time for parsing small numbers of UA strings with useNA=TRUE and list cache

``` r
uaparserjs:::cache_reset(list())

microbenchmark::microbenchmark(
  ua_parse(agents, useNA=TRUE)
)
```

    ## Unit: milliseconds
    ##                            expr      min       lq     mean   median       uq
    ##  ua_parse(agents, useNA = TRUE) 30.37149 31.90046 39.17526 33.82008 35.04215
    ##       max neval
    ##  532.2606   100

### Time for parsing small numbers of UA strings with environment cache and useNA=TRUE

``` r
uaparserjs:::cache_reset(new.env())

microbenchmark::microbenchmark(
  ua_parse(agents, useNA=TRUE)
)
```

    ## Unit: milliseconds
    ##                            expr      min       lq     mean   median       uq
    ##  ua_parse(agents, useNA = TRUE) 27.33492 29.76366 36.18781 31.30677 32.97265
    ##       max neval
    ##  505.8763   100

### The effect of the useNA plumbing changes and number of UAs

This addresses relative performance with and without the useNA flag by
repeatedly checking copies of the same URL (using the default
environment type cache).  
This exercises unpacking the parameter list and structuring of of the
results (the code is faster with useNA=TRUE than with useNA=FALSE,
probably from rationalising the conversion of results to a data frame).
This test minimises the effect of caching by using the same UA string
over and over. Because of caching, this test does not call the
underlying Javascript parser repeatedly.

``` r
options(scipen=999)
unloadNamespace("usparserjs") # clear cache

workingUA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 Chrome/15.0.874.106 Safari/535.2"
counts = c(10, 50, 100, 500, 1000, 5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000)

naFlags = c(TRUE, FALSE)

results = c()

for(f in naFlags)
{
  for(i in counts)
  {
    bmResult = microbenchmark::microbenchmark(uaparserjs::ua_parse(rep(workingUA, i), useNA = f), times = 1)
    bmResult$UAcount = i
    bmResult$useNA = f
    results = c(results, list(bmResult))
  }  
}

results2 = do.call("rbind", results)

results2$timesec = results2$time/1000000000

library(ggplot2) 

ggplot(results2, aes(UAcount)) + 
 aes(x=UAcount, y=timesec, colour=useNA) + 
 geom_line() +
 labs(
    title = "Elapsed Time, result always cached",
    subtitle = "varying numbers of user agent strings parsed and cached",
    x = "Number of User Agent Strings Parsed and Cached",
    y = "Elapsed Time (seconds)",
    color = "useNA parameter values"
  )
```

![](man/figures/README-unnamed-chunk-7-1.png)<!-- -->

#### Raw data

``` r
class(results2) = "data.frame"
results2
```

    ##                                                                                    expr
    ## 1                                    uaparserjs::ua_parse(rep(workingUA, i), useNA = f)
    ## 2         uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 2031206, 50, TRUE)
    ## 3        uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 3371444, 100, TRUE)
    ## 4       uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 11532579, 500, TRUE)
    ## 5      uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 22723446, 1000, TRUE)
    ## 6     uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 122816065, 5000, TRUE)
    ## 7    uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 299110944, 10000, TRUE)
    ## 8    uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 368028699, 15000, TRUE)
    ## 9    uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 503995104, 20000, TRUE)
    ## 10   uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 628256462, 25000, TRUE)
    ## 11   uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 780175659, 30000, TRUE)
    ## 12   uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 891129271, 35000, TRUE)
    ## 13  uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1049337750, 40000, TRUE)
    ## 14  uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1197549630, 45000, TRUE)
    ## 15  uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1288802404, 50000, TRUE)
    ## 16       uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 2559195, 10, FALSE)
    ## 17       uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 3969100, 50, FALSE)
    ## 18      uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 7263871, 100, FALSE)
    ## 19     uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 37692507, 500, FALSE)
    ## 20    uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 77255538, 1000, FALSE)
    ## 21   uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 412946493, 5000, FALSE)
    ## 22  uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 802051579, 10000, FALSE)
    ## 23 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1195821039, 15000, FALSE)
    ## 24 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1521754679, 20000, FALSE)
    ## 25 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1935462944, 25000, FALSE)
    ## 26 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 2361476534, 30000, FALSE)
    ## 27 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 2721711172, 35000, FALSE)
    ## 28 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 3118872173, 40000, FALSE)
    ## 29 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 3533696610, 45000, FALSE)
    ## 30 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 3882980571, 50000, FALSE)
    ##          time UAcount useNA     timesec
    ## 1     2359701      10  TRUE 0.002359701
    ## 2     2031206      50  TRUE 0.002031206
    ## 3     3371444     100  TRUE 0.003371444
    ## 4    11532579     500  TRUE 0.011532579
    ## 5    22723446    1000  TRUE 0.022723446
    ## 6   122816065    5000  TRUE 0.122816065
    ## 7   299110944   10000  TRUE 0.299110944
    ## 8   368028699   15000  TRUE 0.368028699
    ## 9   503995104   20000  TRUE 0.503995104
    ## 10  628256462   25000  TRUE 0.628256462
    ## 11  780175659   30000  TRUE 0.780175659
    ## 12  891129271   35000  TRUE 0.891129271
    ## 13 1049337750   40000  TRUE 1.049337750
    ## 14 1197549630   45000  TRUE 1.197549630
    ## 15 1288802404   50000  TRUE 1.288802404
    ## 16    2559195      10 FALSE 0.002559195
    ## 17    3969100      50 FALSE 0.003969100
    ## 18    7263871     100 FALSE 0.007263871
    ## 19   37692507     500 FALSE 0.037692507
    ## 20   77255538    1000 FALSE 0.077255538
    ## 21  412946493    5000 FALSE 0.412946493
    ## 22  802051579   10000 FALSE 0.802051579
    ## 23 1195821039   15000 FALSE 1.195821039
    ## 24 1521754679   20000 FALSE 1.521754679
    ## 25 1935462944   25000 FALSE 1.935462944
    ## 26 2361476534   30000 FALSE 2.361476534
    ## 27 2721711172   35000 FALSE 2.721711172
    ## 28 3118872173   40000 FALSE 3.118872173
    ## 29 3533696610   45000 FALSE 3.533696610
    ## 30 3882980571   50000 FALSE 3.882980571

### Effect of cache misses with large cache sizes

This examines the worst-case effect of cache misses with various cache
sizes. The cache is populated with a number of unique strings, the
number matching the test case size.  
In the list cache case, every measured call experiences that number of
cache misses before finding its value in the cache, for example with
1000 User Agent strings passed in 1000 unique cache entries are created
before the test and the test finds the last-created cache entry.

``` r
results = c()

for(f in naFlags)
{
  for(i in counts)
  {
    uaparserjs:::cache_reset(list())

    for(j in 1:i)
    {
      # fake the right number of UA strings for this request cycle
      uaparserjs::ua_parse(paste(j, workingUA),useNA = TRUE)
    }
    bmResult = microbenchmark::microbenchmark(uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)), useNA = f), times = 1)
    bmResult$UAcount = i
    bmResult$useNA = f
    bmResult$cacheType = "list"
    results = c(results, list(bmResult))
  }  
}

for(f in naFlags)
{
  for(i in counts)
  {
    uaparserjs:::cache_reset(new.env())

    for(j in 1:i)
    {
      # fake the right number of UA strings for this request cycle
      uaparserjs::ua_parse(paste(j, workingUA), useNA = TRUE)
    }
    bmResult = microbenchmark::microbenchmark(uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)), useNA = f), times = 1)
    bmResult$UAcount = i
    bmResult$useNA = f
    bmResult$cacheType = "env"
    results = c(results, list(bmResult))
  }  
}

results2 = do.call("rbind", results)

results2$timesec = results2$time/1000000000

library(ggplot2) 

ggplot(results2, aes(UAcount)) + 
 aes(x=UAcount, y=timesec, colour=useNA, linetype=cacheType) + 
 geom_line() +
 labs(
    title = "Elapsed Time, 1000 UA strings, result never cached",
    subtitle = "100% cache misses, 1000 UA strings per request",
    x = "Number of User Agent Strings in Cache",
    y = "Elapsed Time (seconds)",
    color = "useNA parameter values",
    linetype = "cache type"
  )
```

![](man/figures/README-unnamed-chunk-9-1.png)<!-- -->

#### Raw Data

``` r
class(results2) = "data.frame"
results2
```

    ##                                                                                                                          expr
    ## 1                                             uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f)
    ## 2        uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 621056436, 50, TRUE, "list")
    ## 3       uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 621019263, 100, TRUE, "list")
    ## 4       uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 631677582, 500, TRUE, "list")
    ## 5      uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 660802974, 1000, TRUE, "list")
    ## 6     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1053316468, 5000, TRUE, "list")
    ## 7    uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1884716711, 10000, TRUE, "list")
    ## 8    uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 3004099821, 15000, TRUE, "list")
    ## 9    uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 4081489022, 20000, TRUE, "list")
    ## 10   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 5075107387, 25000, TRUE, "list")
    ## 11   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 6089417641, 30000, TRUE, "list")
    ## 12   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 7124621141, 35000, TRUE, "list")
    ## 13   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 8069825991, 40000, TRUE, "list")
    ## 14   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 9151766994, 45000, TRUE, "list")
    ## 15  uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 10519365850, 50000, TRUE, "list")
    ## 16      uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 984056454, 10, FALSE, "list")
    ## 17     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1018056639, 50, FALSE, "list")
    ## 18     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 978591616, 100, FALSE, "list")
    ## 19    uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1009623169, 500, FALSE, "list")
    ## 20   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1093866967, 1000, FALSE, "list")
    ## 21   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1580656442, 5000, FALSE, "list")
    ## 22  uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 2645265514, 10000, FALSE, "list")
    ## 23  uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 3701779638, 15000, FALSE, "list")
    ## 24  uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 4715808692, 20000, FALSE, "list")
    ## 25  uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 5885682297, 25000, FALSE, "list")
    ## 26  uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 6942344965, 30000, FALSE, "list")
    ## 27  uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 7877776450, 35000, FALSE, "list")
    ## 28  uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 8921522524, 40000, FALSE, "list")
    ## 29  uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 9774548081, 45000, FALSE, "list")
    ## 30 uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 10900086396, 50000, FALSE, "list")
    ## 31        uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 553744825, 10, TRUE, "env")
    ## 32        uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 562765072, 50, TRUE, "env")
    ## 33       uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 555912735, 100, TRUE, "env")
    ## 34       uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 562743576, 500, TRUE, "env")
    ## 35      uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 552916874, 1000, TRUE, "env")
    ## 36      uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 563187269, 5000, TRUE, "env")
    ## 37     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 557852538, 10000, TRUE, "env")
    ## 38     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 568570687, 15000, TRUE, "env")
    ## 39     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 563116628, 20000, TRUE, "env")
    ## 40     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 621873441, 25000, TRUE, "env")
    ## 41     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 605822958, 30000, TRUE, "env")
    ## 42     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 573075960, 35000, TRUE, "env")
    ## 43     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 602794655, 40000, TRUE, "env")
    ## 44     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 650638213, 45000, TRUE, "env")
    ## 45     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 611983146, 50000, TRUE, "env")
    ## 46      uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1069995993, 10, FALSE, "env")
    ## 47       uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 976562508, 50, FALSE, "env")
    ## 48      uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 993689050, 100, FALSE, "env")
    ## 49      uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 995356890, 500, FALSE, "env")
    ## 50     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 960390004, 1000, FALSE, "env")
    ## 51     uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 974307042, 5000, FALSE, "env")
    ## 52    uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 977493712, 10000, FALSE, "env")
    ## 53   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1036015758, 15000, FALSE, "env")
    ## 54   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1049720957, 20000, FALSE, "env")
    ## 55   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1051404521, 25000, FALSE, "env")
    ## 56    uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 984003147, 30000, FALSE, "env")
    ## 57   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1053376474, 35000, FALSE, "env")
    ## 58   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1208410751, 40000, FALSE, "env")
    ## 59   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1036220615, 45000, FALSE, "env")
    ## 60   uaparserjs::ua_parse(paste(rep(workingUA, 1000), seq(1, 1000)),      useNA = f).list(1, 1063299904, 50000, FALSE, "env")
    ##           time UAcount useNA cacheType    timesec
    ## 1    650188278      10  TRUE      list  0.6501883
    ## 2    621056436      50  TRUE      list  0.6210564
    ## 3    621019263     100  TRUE      list  0.6210193
    ## 4    631677582     500  TRUE      list  0.6316776
    ## 5    660802974    1000  TRUE      list  0.6608030
    ## 6   1053316468    5000  TRUE      list  1.0533165
    ## 7   1884716711   10000  TRUE      list  1.8847167
    ## 8   3004099821   15000  TRUE      list  3.0040998
    ## 9   4081489022   20000  TRUE      list  4.0814890
    ## 10  5075107387   25000  TRUE      list  5.0751074
    ## 11  6089417641   30000  TRUE      list  6.0894176
    ## 12  7124621141   35000  TRUE      list  7.1246211
    ## 13  8069825991   40000  TRUE      list  8.0698260
    ## 14  9151766994   45000  TRUE      list  9.1517670
    ## 15 10519365850   50000  TRUE      list 10.5193658
    ## 16   984056454      10 FALSE      list  0.9840565
    ## 17  1018056639      50 FALSE      list  1.0180566
    ## 18   978591616     100 FALSE      list  0.9785916
    ## 19  1009623169     500 FALSE      list  1.0096232
    ## 20  1093866967    1000 FALSE      list  1.0938670
    ## 21  1580656442    5000 FALSE      list  1.5806564
    ## 22  2645265514   10000 FALSE      list  2.6452655
    ## 23  3701779638   15000 FALSE      list  3.7017796
    ## 24  4715808692   20000 FALSE      list  4.7158087
    ## 25  5885682297   25000 FALSE      list  5.8856823
    ## 26  6942344965   30000 FALSE      list  6.9423450
    ## 27  7877776450   35000 FALSE      list  7.8777764
    ## 28  8921522524   40000 FALSE      list  8.9215225
    ## 29  9774548081   45000 FALSE      list  9.7745481
    ## 30 10900086396   50000 FALSE      list 10.9000864
    ## 31   553744825      10  TRUE       env  0.5537448
    ## 32   562765072      50  TRUE       env  0.5627651
    ## 33   555912735     100  TRUE       env  0.5559127
    ## 34   562743576     500  TRUE       env  0.5627436
    ## 35   552916874    1000  TRUE       env  0.5529169
    ## 36   563187269    5000  TRUE       env  0.5631873
    ## 37   557852538   10000  TRUE       env  0.5578525
    ## 38   568570687   15000  TRUE       env  0.5685707
    ## 39   563116628   20000  TRUE       env  0.5631166
    ## 40   621873441   25000  TRUE       env  0.6218734
    ## 41   605822958   30000  TRUE       env  0.6058230
    ## 42   573075960   35000  TRUE       env  0.5730760
    ## 43   602794655   40000  TRUE       env  0.6027947
    ## 44   650638213   45000  TRUE       env  0.6506382
    ## 45   611983146   50000  TRUE       env  0.6119831
    ## 46  1069995993      10 FALSE       env  1.0699960
    ## 47   976562508      50 FALSE       env  0.9765625
    ## 48   993689050     100 FALSE       env  0.9936890
    ## 49   995356890     500 FALSE       env  0.9953569
    ## 50   960390004    1000 FALSE       env  0.9603900
    ## 51   974307042    5000 FALSE       env  0.9743070
    ## 52   977493712   10000 FALSE       env  0.9774937
    ## 53  1036015758   15000 FALSE       env  1.0360158
    ## 54  1049720957   20000 FALSE       env  1.0497210
    ## 55  1051404521   25000 FALSE       env  1.0514045
    ## 56   984003147   30000 FALSE       env  0.9840031
    ## 57  1053376474   35000 FALSE       env  1.0533765
    ## 58  1208410751   40000 FALSE       env  1.2084108
    ## 59  1036220615   45000 FALSE       env  1.0362206
    ## 60  1063299904   50000 FALSE       env  1.0632999
