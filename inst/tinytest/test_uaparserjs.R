#    Copyright 2020 Bob Rudis
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

library(uaparserjs)
library(tinytest)

# Placeholder with simple test
res <- ua_parse(paste0("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, ",
                       "like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 ",
                       "Chrome/15.0.874.106 Safari/535.2", collapse=""))

expect_true(inherits(res, "data.frame"))
expect_equal(res$ua.patch, "874")
expect_equal(res$os.family, "Ubuntu")
expect_equal(res$ua.family, "Chromium")
expect_equal(res$ua.major, "15")
expect_equal(res$ua.minor, "0")
expect_equal(res$ua.patch, "874")
expect_equal(res$os.major, "11")
expect_equal(res$os.minor, "10")
expect_equal(res$device.family, "Other")
