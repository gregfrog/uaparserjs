#!/usr/bin/env bash

UAPCOREGITREPO=workdir-uap-core
UAPCOREREPOURL=https://github.com/ua-parser/uap-core.git

if [[ ! -d ${UAPCOREGITREPO} ]]; then
  mkdir ${UAPCOREGITREPO}
fi

cd ${UAPCOREGITREPO}

npm init -y

npm install --save-dev yaml base-64 uap-ref-impl webpack webpack-dev-server
npm install -g --save-dev webpack-cli

git init
git remote add origin ${UAPCOREREPOURL}
git sparse-checkout set --no-cone 'tests/*.yaml' 'test_resources/*.yaml' 'regexes.yaml'
git pull origin master

if [[ ! -f regexes.yaml ]]; then
  echo "regexes.yaml not present after git pull"
  return 1
fi

if [[ -e index.js ]]; then
  rm index.js
fi 
touch index.js

node << EOFNODE2
const fs = require('fs')
const YAML = require('yaml')
const file = fs.readFileSync('regexes.yaml', 'utf8')
regexes =  JSON.stringify(YAML.parse(file))

const outputFilePath = 'index.js';

try {
  fs.appendFileSync(outputFilePath,"global.regexes = " + regexes + ";\n" +
        "global.uap = require('uap-ref-impl');\n")

} catch (err) {
    console.error('Error writing to index.js:', err);
    process.exit(1)
}
EOFNODE2

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "ERROR in creating index.js"
    return 1
fi

cd ..

if [[ ! -e webpack.config.js ]]; then
  cat << EOFWEBPACK > webpack.config.js
module.exports = {
  output: {
    filename: 'bundle.js'
  },
  performance: {
    hints: false, // Disables all performance hints
  },
};

EOFWEBPACK
fi

webpack --mode="production" ./workdir-uap-core/index.js -o ./dist

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "ERROR in Webpack"
    return 1
fi


node << EOFNODE3
const util = require('util');
const vm = require('vm');
const fs = require('fs');

const sandbox = {
  result: ""
};

fileContent = fs.readFileSync("/home/greg/src/wk2/uaparserjs/build/dist/bundle.js", { encoding: 'utf8', flag: 'r' })
const script = new vm.Script(fileContent);

const context = new vm.createContext(sandbox);

script.runInContext(context);

const parseScript = new vm.Script("var parser = uap(regexes);\n result = parser.parse(\"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, " + 
                 "like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 " + 
                 "Chrome/15.0.874.106 Safari/535.2\");");

parseScript.runInContext(context);

//console.log(util.inspect(sandbox));
console.log(sandbox.result);

EOFNODE3

cp dist/bundle.js .
if [[ ! -d tests ]]; then
  mkdir tests
fi
cp workdir-uap-core/tests/* ./tests/
rm -rf dist
rm -rf workdir-uap-core
rm -rf webpack.config.js

echo "generated bundle.js moved to build/bundle.js, it must be moved by hand to inst/js for the R packaghe build"
echo "test yaml files from uap core are in build/tests and must be moved by hand into inst/tinytest/tests"
