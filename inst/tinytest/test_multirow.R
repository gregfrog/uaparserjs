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

expect_equal(nrow(res), 4, info="useNA FALSE in multi-row check")

res = uaparserjs::ua_parse(uas_test$uastrings, useNA = TRUE)

expect_equal(nrow(res), 6, info="useNA TRUE in multi-row check")
