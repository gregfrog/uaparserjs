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

# smoke test
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

# existing behaviour
res <- uaparserjs::ua_parse("", useNA=FALSE)
expect_true(nrow(res) == 0, info="0 character string parameter")
res <- uaparserjs::ua_parse(" ", useNA=FALSE)
expect_true(length(names(res)) == 4)
res <- uaparserjs::ua_parse(NULL, useNA=FALSE)
expect_true(nrow(res) == 0, info="NULL parameter")

# new behaviour
res <- uaparserjs::ua_parse(" ", useNA=TRUE)
expect_equal(res$userAgent, " ")
expect_true(is.na(res$ua.patch))
expect_equal(res$os.family, "Other")
expect_equal(res$ua.family, "Other")
expect_true(is.na(res$ua.major))
expect_true(is.na(res$ua.minor))
expect_true(is.na(res$ua.patch))
expect_true(is.na(res$os.major))
expect_true(is.na(res$os.minor))
expect_equal(res$device.family, "Other")

res <- uaparserjs::ua_parse(list(" "), useNA=TRUE)
expect_equal(res$userAgent, " ")
expect_true(is.na(res$ua.patch))
expect_equal(res$os.family, "Other")
expect_equal(res$ua.family, "Other")
expect_true(is.na(res$ua.major))
expect_true(is.na(res$ua.minor))
expect_true(is.na(res$ua.patch))
expect_true(is.na(res$os.major))
expect_true(is.na(res$os.minor))
expect_equal(res$device.family, "Other")

res <- uaparserjs::ua_parse("", useNA=TRUE)
expect_equal(res$userAgent, "")
expect_true(is.na(res$ua.patch))
expect_equal(res$os.family, "Other")
expect_equal(res$ua.family, "Other")
expect_true(is.na(res$ua.major))
expect_true(is.na(res$ua.minor))
expect_true(is.na(res$ua.patch))
expect_true(is.na(res$os.major))
expect_true(is.na(res$os.minor))
expect_equal(res$device.family, "Other")

res <- uaparserjs::ua_parse(list(""), useNA=TRUE)
expect_equal(res$userAgent, "")
expect_true(is.na(res$ua.patch))
expect_equal(res$os.family, "Other")
expect_equal(res$ua.family, "Other")
expect_true(is.na(res$ua.major))
expect_true(is.na(res$ua.minor))
expect_true(is.na(res$ua.patch))
expect_true(is.na(res$os.major))
expect_true(is.na(res$os.minor))
expect_equal(res$device.family, "Other")

res <- uaparserjs::ua_parse(NULL, useNA=TRUE)
expect_true(is.na(res$userAgent))
expect_true(is.na(res$ua.patch))
expect_equal(res$os.family, "Other")
expect_equal(res$ua.family, "Other")
expect_true(is.na(res$ua.major))
expect_true(is.na(res$ua.minor))
expect_true(is.na(res$ua.patch))
expect_true(is.na(res$os.major))
expect_true(is.na(res$os.minor))
expect_equal(res$device.family, "Other")

# check cache does not return wrong values as well as checking null return values
res <- uaparserjs::ua_parse(NULL, useNA=FALSE)
expect_true(!("userAgent" %in% names(res)))
expect_true(!("os.patch" %in% names(res)))
expect_true(!("osfamily" %in% names(res)))
expect_true(!("ua.family" %in% names(res)))
expect_true(!("ua.major" %in% names(res)))
expect_true(!("ua.minor" %in% names(res)))
expect_true(!("ua.patch" %in% names(res)))
expect_true(!("os.major" %in% names(res)))
expect_true(!("os.minor" %in% names(res)))
expect_true(!("device.family" %in% names(res)))

res <- uaparserjs::ua_parse(list(NULL), useNA=TRUE)
expect_true(is.na(res$userAgent))
expect_true(is.na(res$ua.patch))
expect_equal(res$os.family, "Other")
expect_equal(res$ua.family, "Other")
expect_true(is.na(res$ua.major))
expect_true(is.na(res$ua.minor))
expect_true(is.na(res$ua.patch))
expect_true(is.na(res$os.major))
expect_true(is.na(res$os.minor))
expect_equal(res$device.family, "Other")

res <- uaparserjs::ua_parse(NA, useNA=TRUE)
expect_true(is.na(res$userAgent))
expect_true(is.na(res$ua.patch))
expect_equal(res$os.family, "Other")
expect_equal(res$ua.family, "Other")
expect_true(is.na(res$ua.major))
expect_true(is.na(res$ua.minor))
expect_true(is.na(res$ua.patch))
expect_true(is.na(res$os.major))
expect_true(is.na(res$os.minor))
expect_equal(res$device.family, "Other")

res <- uaparserjs::ua_parse(list(NA), useNA=TRUE)
expect_true(is.na(res$userAgent))
expect_true(is.na(res$ua.patch))
expect_equal(res$os.family, "Other")
expect_equal(res$ua.family, "Other")
expect_true(is.na(res$ua.major))
expect_true(is.na(res$ua.minor))
expect_true(is.na(res$ua.patch))
expect_true(is.na(res$os.major))
expect_true(is.na(res$os.minor))
expect_equal(res$device.family, "Other")
