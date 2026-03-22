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
