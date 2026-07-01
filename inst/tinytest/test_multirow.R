#    Copyright 2026 Greg Hunt

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at

#        http://www.apache.org/licenses/LICENSE-2.0

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

library(yaml)
library(tinytest)
library(uaparserjs)

uas_test <- data.frame(
  label = LETTERS[1:6],
  uastrings = c(
    paste0("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, ",
           "like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 ",
           "Chrome/15.0.874.106 Safari/535.2",
           collapse=""),
    "",
    paste0("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ",
           "(KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36",
           collapse=""),
    NA_character_,
    paste0("Mozilla/5.0 (Linux; Android 9; moto g(6)) AppleWebKit/537.36 ",
           "(KHTML, like Gecko) Chrome/90.0.4430.210 Mobile Safari/537.36",
           collapse=""),
    " "

  ))

res = uaparserjs::ua_parse(uas_test$uastrings)

# dumped output from old code for comparison
oldres <-structure(list(userAgent =
c("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 Chrome/15.0.874.106 Safari/535.2",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36",
"Mozilla/5.0 (Linux; Android 9; moto g(6)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.210 Mobile Safari/537.36",
" "), ua.family = c("Chromium", "Chrome", "Chrome Mobile", "Other"
), ua.major = c("15", "90", "90", NA), ua.minor = c("0", "0",
"0", NA), ua.patch = c("874", "4430", "4430", NA), os.family = c("Ubuntu",
"Windows", "Android", "Other"), os.major = c("11", "10", "9",
NA), os.minor = c("10", NA, NA, NA), device.family = c("Other",
"Other", "Motorola g(6)", "Other"), device.brand = c(NA, NA,
"Motorola", NA), device.model = c(NA, NA, "g(6)", NA)), row.names = c(NA,
-4L), class = c("tbl_df", "tbl", "data.frame"))

expect_equal(nrow(res), 4, info="useNA FALSE in multi-row check")
expect_equal(res, oldres, info="useNA FALSE in multi-row check")

res = uaparserjs::ua_parse(uas_test$uastrings, useNA = TRUE)

# dumped output from useNA code
NAres <-
structure(list(userAgent = c("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 Chrome/15.0.874.106 Safari/535.2",
"", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36",
NA, "Mozilla/5.0 (Linux; Android 9; moto g(6)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.210 Mobile Safari/537.36",
" "), ua.family = c("Chromium", "Other", "Chrome", "Other", "Chrome Mobile",
"Other"), ua.major = c("15", NA, "90", NA, "90", NA), ua.minor = c("0",
NA, "0", NA, "0", NA), ua.patch = c("874", NA, "4430", NA, "4430",
NA), os.family = c("Ubuntu", "Other", "Windows", "Other", "Android",
"Other"), os.major = c("11", NA, "10", NA, "9", NA), os.minor = c("10",
NA, NA, NA, NA, NA), os.patch = c(NA_character_, NA_character_,
NA_character_, NA_character_, NA_character_, NA_character_),
    os.patchMinor = c(NA_character_, NA_character_, NA_character_,
    NA_character_, NA_character_, NA_character_), device.family = c("Other",
    "Other", "Other", "Other", "Motorola g(6)", "Other"), device.brand = c(NA,
    NA, NA, NA, "Motorola", NA), device.model = c(NA, NA, NA,
    NA, "g(6)", NA)), class = c("tbl_df", "tbl", "data.frame"
), row.names = c(NA, -6L))

expect_equal(nrow(res), 6, info="useNA TRUE in multi-row check")
expect_equal(res, NAres, info="useNA TRUE in multi-row check")

# permutation code copied from https://stackoverflow.com/questions/11095992/generating-all-distinct-permutations-of-a-list-in-r
# under CC SA license
#

getPermutations <- function(x) {
    if (length(x) == 1) {
        return(x)
    }
    else {
        res <- matrix(nrow = 0, ncol = length(x))
        for (i in seq_along(x)) {
            res <- rbind(res, cbind(x[i], Recall(x[-i])))
        }
        return(res)
    }
}

permutations = unique(getPermutations(list("", "", " ", " ", NA, NA, "aaa", paste0("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, ",
           "like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 ",
           "Chrome/15.0.874.106 Safari/535.2",
           collapse=""))))

templateResult = list()

# collect results from first row
for(p in permutations[1,])
{
    templateResult[deparse(p)] = list(tibble::as_tibble(uaparserjs::ua_parse(p, useNA=TRUE)))
}

# number of rows
numPerms = dim(permutations)[1]

# for each combination
for(i in 1:numPerms)
{
    res = uaparserjs::ua_parse(unlist(permutations[i,]), useNA=TRUE)
    for(j in seq_along(length(res)))
    {
       expect_equal(res[j,], templateResult[[deparse(unlist(permutations[i,j]))]], info=permutations[i,j])
    }
}
