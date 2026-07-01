# 0.4.0 (2026-07-02)
* Note: Includes UAP-Core regexes.yaml commits up to: Tue May 26 15:01:27 2026 +0100 5bf1320
* Added useNA flag to return NA values instead of omitting rows or columns in the tibble, this
will result in one row of output for each row input (based on a proposal from Jim Vine) which is potentially different behaviour over past releases
* useNA=TRUE will call as_tibble from the tibble package if the tibble namespace is loadable, previous behaviour was to coerce values to a data frame and add tibble class attributes, this seems to skip some validations and is not guaranteed to work as the tibble package evolves.    

# 0.3.8 (2026-05-09)
* Note: Includes UAP-Core regexes.yaml commits up to: Thu May 7 11:59:15 2026 -0700 880683d

# 0.3.7 (2026-04-01)
* Note: Includes UAP-Core regexes.yaml commits up to: Mon Feb 9 12:37:56 2026 +0000 256bff9
* Change: added test cases from uap-core
* Bug: Fixed handling of non-ASCII characters 
* Change: updated code to latest uap-core definitions  
* Change: scripted both update of regexes from uap-core and generation of javascript, note that user agent database mentioned below is not updated, if anyone knows what it is for and whether it matters please let me know.     

# 0.3.6 (2026-03-21)
* To avoid archiving: update NEWS file formatting for new CRAN check, transfer maintainer.
* Minor updates to tests

# 0.3.5
* Updated core parser code (again)
* Added new user agent database
* Addressed issues re:Kurt's "stringsAsFactors" guidance email.
* Switched testing framework

# 0.3.0
* Updated regexes YAML to latest
* Switched to webpack from browserify

# 0.2.0
* Caching for a minor speedup

# 0.1.0 
* Initial release
