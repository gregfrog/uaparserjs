#!/usr/bin/env bash

#    Copyright 2026 Greg Hunt

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License ats

#        http://www.apache.org/licenses/LICENSE-2.0

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

mv bundle.js ../inst/js/bundle.js
mv tests/* ../inst/tinytest/tests/

LASTCOMMIT=`cat LASTUAPCOMMIT`

cat << EOFSED > sedfile
1,/^\*.*$/{
        /\* Note: Includes UAP.*/d;
        /^\#/{
            a \* Note: Includes UAP-Core regexes.yaml commits up to: ${LASTCOMMIT}
            p
        }
 }
3,\${
     p
}

EOFSED

sed -n -f sedfile -i ../NEWS.md
head ../NEWS.md
rm sedfile
