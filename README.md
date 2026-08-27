
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
    ##  ua_parse(agents) 289.7389 315.7295 336.6979 329.0645 340.5325 1170.832   100

### Time for parsing small numbers of UA strings with useNA defaulting to FALSE and an env type cache

``` r
uaparserjs:::cache_reset(new.env())

microbenchmark::microbenchmark(
  ua_parse(agents)
)
```

    ## Unit: milliseconds
    ##              expr      min       lq     mean   median       uq      max neval
    ##  ua_parse(agents) 283.9208 305.3295 331.2778 324.2801 336.7438 1082.024   100

### Time for parsing small numbers of UA strings with useNA=TRUE and list cache

``` r
uaparserjs:::cache_reset(list())

microbenchmark::microbenchmark(
  ua_parse(agents, useNA=TRUE)
)
```

    ## Unit: milliseconds
    ##                            expr      min       lq     mean   median       uq
    ##  ua_parse(agents, useNA = TRUE) 29.59558 31.70604 38.52025 32.97509 34.55482
    ##       max neval
    ##  519.7421   100

### Time for parsing small numbers of UA strings with environment cache and useNA=TRUE

``` r
uaparserjs:::cache_reset(new.env())

microbenchmark::microbenchmark(
  ua_parse(agents, useNA=TRUE)
)
```

    ## Unit: milliseconds
    ##                            expr      min       lq     mean   median       uq
    ##  ua_parse(agents, useNA = TRUE) 26.77469 29.25073 35.76945 31.19074 32.72564
    ##       max neval
    ##  500.9572   100

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
    ## 2         uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 2278460, 50, TRUE)
    ## 3        uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 2988297, 100, TRUE)
    ## 4       uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 11441463, 500, TRUE)
    ## 5      uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 22504115, 1000, TRUE)
    ## 6     uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 120907817, 5000, TRUE)
    ## 7    uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 290865157, 10000, TRUE)
    ## 8    uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 360390956, 15000, TRUE)
    ## 9    uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 499588233, 20000, TRUE)
    ## 10   uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 614845250, 25000, TRUE)
    ## 11   uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 743280488, 30000, TRUE)
    ## 12   uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 878147770, 35000, TRUE)
    ## 13  uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1015134807, 40000, TRUE)
    ## 14  uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1187124320, 45000, TRUE)
    ## 15  uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1260661318, 50000, TRUE)
    ## 16       uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 2588499, 10, FALSE)
    ## 17       uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 3869914, 50, FALSE)
    ## 18      uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 7319072, 100, FALSE)
    ## 19     uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 39919679, 500, FALSE)
    ## 20    uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 79681374, 1000, FALSE)
    ## 21   uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 392142583, 5000, FALSE)
    ## 22  uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 775541703, 10000, FALSE)
    ## 23 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1228723131, 15000, FALSE)
    ## 24 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1588539604, 20000, FALSE)
    ## 25 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 1996224526, 25000, FALSE)
    ## 26 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 2500650144, 30000, FALSE)
    ## 27 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 2842068651, 35000, FALSE)
    ## 28 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 3261837378, 40000, FALSE)
    ## 29 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 3666432769, 45000, FALSE)
    ## 30 uaparserjs::ua_parse(rep(workingUA, i), useNA = f).list(1, 4042804759, 50000, FALSE)
    ##          time UAcount useNA     timesec
    ## 1     2398342      10  TRUE 0.002398342
    ## 2     2278460      50  TRUE 0.002278460
    ## 3     2988297     100  TRUE 0.002988297
    ## 4    11441463     500  TRUE 0.011441463
    ## 5    22504115    1000  TRUE 0.022504115
    ## 6   120907817    5000  TRUE 0.120907817
    ## 7   290865157   10000  TRUE 0.290865157
    ## 8   360390956   15000  TRUE 0.360390956
    ## 9   499588233   20000  TRUE 0.499588233
    ## 10  614845250   25000  TRUE 0.614845250
    ## 11  743280488   30000  TRUE 0.743280488
    ## 12  878147770   35000  TRUE 0.878147770
    ## 13 1015134807   40000  TRUE 1.015134807
    ## 14 1187124320   45000  TRUE 1.187124320
    ## 15 1260661318   50000  TRUE 1.260661318
    ## 16    2588499      10 FALSE 0.002588499
    ## 17    3869914      50 FALSE 0.003869914
    ## 18    7319072     100 FALSE 0.007319072
    ## 19   39919679     500 FALSE 0.039919679
    ## 20   79681374    1000 FALSE 0.079681374
    ## 21  392142583    5000 FALSE 0.392142583
    ## 22  775541703   10000 FALSE 0.775541703
    ## 23 1228723131   15000 FALSE 1.228723131
    ## 24 1588539604   20000 FALSE 1.588539604
    ## 25 1996224526   25000 FALSE 1.996224526
    ## 26 2500650144   30000 FALSE 2.500650144
    ## 27 2842068651   35000 FALSE 2.842068651
    ## 28 3261837378   40000 FALSE 3.261837378
    ## 29 3666432769   45000 FALSE 3.666432769
    ## 30 4042804759   50000 FALSE 4.042804759

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
    bmResult = microbenchmark::microbenchmark(uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f), times = 1)
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
    bmResult = microbenchmark::microbenchmark(uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f), times = 1)
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

    ##                                                                                               expr
    ## 1                                            uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f)
    ## 2        uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 23852185, 50, TRUE, "list")
    ## 3       uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 25324163, 100, TRUE, "list")
    ## 4       uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 26161983, 500, TRUE, "list")
    ## 5      uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 28663606, 1000, TRUE, "list")
    ## 6      uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 52367235, 5000, TRUE, "list")
    ## 7     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 96360934, 10000, TRUE, "list")
    ## 8    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 160294202, 15000, TRUE, "list")
    ## 9    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 201872823, 20000, TRUE, "list")
    ## 10   uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 298504006, 25000, TRUE, "list")
    ## 11   uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 625531385, 30000, TRUE, "list")
    ## 12   uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 863676952, 35000, TRUE, "list")
    ## 13   uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 982019125, 40000, TRUE, "list")
    ## 14  uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 1146063668, 45000, TRUE, "list")
    ## 15  uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 1248732532, 50000, TRUE, "list")
    ## 16      uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 85195581, 10, FALSE, "list")
    ## 17      uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 79504299, 50, FALSE, "list")
    ## 18     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 85247251, 100, FALSE, "list")
    ## 19     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 81622215, 500, FALSE, "list")
    ## 20    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 90459568, 1000, FALSE, "list")
    ## 21   uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 115641312, 5000, FALSE, "list")
    ## 22  uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 164417719, 10000, FALSE, "list")
    ## 23  uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 219467945, 15000, FALSE, "list")
    ## 24  uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 272852520, 20000, FALSE, "list")
    ## 25  uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 545453000, 25000, FALSE, "list")
    ## 26  uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 714194841, 30000, FALSE, "list")
    ## 27  uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 855268309, 35000, FALSE, "list")
    ## 28 uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 1014451938, 40000, FALSE, "list")
    ## 29 uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 1174724632, 45000, FALSE, "list")
    ## 30 uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 1341875322, 50000, FALSE, "list")
    ## 31        uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 25246920, 10, TRUE, "env")
    ## 32        uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 23239555, 50, TRUE, "env")
    ## 33       uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 24444592, 100, TRUE, "env")
    ## 34       uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 23637904, 500, TRUE, "env")
    ## 35      uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 23262428, 1000, TRUE, "env")
    ## 36      uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 24062731, 5000, TRUE, "env")
    ## 37     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 24783156, 10000, TRUE, "env")
    ## 38     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 25458157, 15000, TRUE, "env")
    ## 39     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 25727772, 20000, TRUE, "env")
    ## 40     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 26826430, 25000, TRUE, "env")
    ## 41     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 26351760, 30000, TRUE, "env")
    ## 42     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 27356565, 35000, TRUE, "env")
    ## 43     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 24001227, 40000, TRUE, "env")
    ## 44     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 25165245, 45000, TRUE, "env")
    ## 45     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 28227306, 50000, TRUE, "env")
    ## 46       uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 79178223, 10, FALSE, "env")
    ## 47       uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 77161903, 50, FALSE, "env")
    ## 48      uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 75365008, 100, FALSE, "env")
    ## 49      uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 76798491, 500, FALSE, "env")
    ## 50     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 75452105, 1000, FALSE, "env")
    ## 51     uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 78259489, 5000, FALSE, "env")
    ## 52    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 79155665, 10000, FALSE, "env")
    ## 53    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 78858388, 15000, FALSE, "env")
    ## 54    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 78724345, 20000, FALSE, "env")
    ## 55    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 88644747, 25000, FALSE, "env")
    ## 56    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 80046865, 30000, FALSE, "env")
    ## 57    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 79481488, 35000, FALSE, "env")
    ## 58    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 78259410, 40000, FALSE, "env")
    ## 59    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 85584090, 45000, FALSE, "env")
    ## 60    uaparserjs::ua_parse(rep(workingUA, 1000), useNA = f).list(1, 88147963, 50000, FALSE, "env")
    ##          time UAcount useNA cacheType    timesec
    ## 1    26954007      10  TRUE      list 0.02695401
    ## 2    23852185      50  TRUE      list 0.02385219
    ## 3    25324163     100  TRUE      list 0.02532416
    ## 4    26161983     500  TRUE      list 0.02616198
    ## 5    28663606    1000  TRUE      list 0.02866361
    ## 6    52367235    5000  TRUE      list 0.05236723
    ## 7    96360934   10000  TRUE      list 0.09636093
    ## 8   160294202   15000  TRUE      list 0.16029420
    ## 9   201872823   20000  TRUE      list 0.20187282
    ## 10  298504006   25000  TRUE      list 0.29850401
    ## 11  625531385   30000  TRUE      list 0.62553139
    ## 12  863676952   35000  TRUE      list 0.86367695
    ## 13  982019125   40000  TRUE      list 0.98201912
    ## 14 1146063668   45000  TRUE      list 1.14606367
    ## 15 1248732532   50000  TRUE      list 1.24873253
    ## 16   85195581      10 FALSE      list 0.08519558
    ## 17   79504299      50 FALSE      list 0.07950430
    ## 18   85247251     100 FALSE      list 0.08524725
    ## 19   81622215     500 FALSE      list 0.08162221
    ## 20   90459568    1000 FALSE      list 0.09045957
    ## 21  115641312    5000 FALSE      list 0.11564131
    ## 22  164417719   10000 FALSE      list 0.16441772
    ## 23  219467945   15000 FALSE      list 0.21946794
    ## 24  272852520   20000 FALSE      list 0.27285252
    ## 25  545453000   25000 FALSE      list 0.54545300
    ## 26  714194841   30000 FALSE      list 0.71419484
    ## 27  855268309   35000 FALSE      list 0.85526831
    ## 28 1014451938   40000 FALSE      list 1.01445194
    ## 29 1174724632   45000 FALSE      list 1.17472463
    ## 30 1341875322   50000 FALSE      list 1.34187532
    ## 31   25246920      10  TRUE       env 0.02524692
    ## 32   23239555      50  TRUE       env 0.02323955
    ## 33   24444592     100  TRUE       env 0.02444459
    ## 34   23637904     500  TRUE       env 0.02363790
    ## 35   23262428    1000  TRUE       env 0.02326243
    ## 36   24062731    5000  TRUE       env 0.02406273
    ## 37   24783156   10000  TRUE       env 0.02478316
    ## 38   25458157   15000  TRUE       env 0.02545816
    ## 39   25727772   20000  TRUE       env 0.02572777
    ## 40   26826430   25000  TRUE       env 0.02682643
    ## 41   26351760   30000  TRUE       env 0.02635176
    ## 42   27356565   35000  TRUE       env 0.02735656
    ## 43   24001227   40000  TRUE       env 0.02400123
    ## 44   25165245   45000  TRUE       env 0.02516524
    ## 45   28227306   50000  TRUE       env 0.02822731
    ## 46   79178223      10 FALSE       env 0.07917822
    ## 47   77161903      50 FALSE       env 0.07716190
    ## 48   75365008     100 FALSE       env 0.07536501
    ## 49   76798491     500 FALSE       env 0.07679849
    ## 50   75452105    1000 FALSE       env 0.07545211
    ## 51   78259489    5000 FALSE       env 0.07825949
    ## 52   79155665   10000 FALSE       env 0.07915567
    ## 53   78858388   15000 FALSE       env 0.07885839
    ## 54   78724345   20000 FALSE       env 0.07872435
    ## 55   88644747   25000 FALSE       env 0.08864475
    ## 56   80046865   30000 FALSE       env 0.08004686
    ## 57   79481488   35000 FALSE       env 0.07948149
    ## 58   78259410   40000 FALSE       env 0.07825941
    ## 59   85584090   45000 FALSE       env 0.08558409
    ## 60   88147963   50000 FALSE       env 0.08814796
