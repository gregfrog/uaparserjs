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

# ported from the javascript uap-core tests

#['../test_resources/firefox_user_agent_strings.yaml', '../tests/test_ua.yaml', '../test_resources/pgts_browser_list.yaml',
#  '../test_resources/opera_mini_user_agent_strings.yaml','../test_resources/podcasting_user_agent_strings.yaml'].forEach(function(fileName) {
#  var fixtures = readYAML(fileName).test_cases;
#  suite(fileName, function() {
#    fixtures.forEach(function(f) {
#      test(f.user_agent_string, function() {
#        var ua = refImpl.parse(f.user_agent_string).ua;
#        fixFixture(f, ['major', 'minor', 'patch']);
#        assert.strictEqual(ua.family, f.family, msg('ua.family', ua.family, f.family));
#         assert.strictEqual(ua.major, f.major, msg('ua.major', ua.major, f.major));
#         assert.strictEqual(ua.minor, f.minor, msg('ua.minor', ua.minor, f.minor));
#         assert.strictEqual(ua.patch, f.patch, msg('ua.patch', ua.patch, f.patch));
#       });
#     });
#   });
# });

uaTest <- function()
{
  uaFiles = c("./tests/test_ua.yaml")

  uaparserjs:::cache_reset()

  for(fName in uaFiles)
  {
    uas = read_yaml(fName)
    for(ua in uas$test_cases)
    {
      thisUa = uaparserjs::ua_parse(ua$user_agent_string)
      expect_equal(thisUa$ua.family, ua$family)
      expect_equal(thisUa$ua.major, ua$major)
      expect_equal(thisUa$ua.minor, ua$minor)
      expect_equal(thisUa$ua.patch, ua$patch)
    }
  }
}

uaTestNA <- function()
{
  uaFiles = c("./tests/test_ua.yaml")

  #uaparserjs:::cache_reset()
  for(fName in uaFiles)
  {
    uas = read_yaml(fName)
    #uas = uaparserjs:::nullToNA(uas)
    for(ua in uas$test_cases)
    {
      thisUa = uaparserjs::ua_parse(ua$user_agent_string, useNA=TRUE)
      expect_equal(thisUa$ua.family, ua$family)
      if(is.null(ua$major))
      {
        expect_true(is.na(thisUa$ua.major))
      }
      else
      {
        expect_equal(thisUa$ua.major, ua$major)
      }
      if(is.null(ua$minor))
      {
        expect_true(is.na(thisUa$ua.minor))
      }
      else
      {
        expect_equal(thisUa$ua.minor, ua$minor)
      }
      if(is.null(ua$patch))
      {
        expect_true(is.na(thisUa$ua.patch))
      }
      else
      {
        expect_equal(thisUa$ua.patch, ua$patch)
      }
    }
  }

}

uaTest()
uaTestNA()

# ['../tests/test_os.yaml', '../test_resources/additional_os_tests.yaml'].forEach(function(fileName) {
#   var fixtures = readYAML(fileName).test_cases;
#   suite(fileName, function() {
#     fixtures.forEach(function(f) {
#       test(f.user_agent_string, function() {
#         var os = refImpl.parse(f.user_agent_string).os;
#         fixFixture(f, ['major', 'minor', 'patch', 'patch_minor']);
#         assert.strictEqual(os.family, f.family, msg('os.family', os.family, f.family));
#         assert.strictEqual(os.major, f.major, msg('os.major', os.major, f.major));
#         assert.strictEqual(os.minor, f.minor, msg('os.minor', os.minor, f.minor));
#         assert.strictEqual(os.patch, f.patch, msg('os.patch', os.patch, f.patch));
#         assert.strictEqual(os.patchMinor, f.patch_minor, msg('os.patchMinor', os.patchMinor, f.patch_minor));
#       });
#     });
#   });
# });

osTest <- function()
{
  uaFiles = c("./tests/test_os.yaml")

  for(fName in uaFiles)
  {
    uas = read_yaml(fName)
    for(os in uas$test_cases)
    {
      thisUa = uaparserjs::ua_parse(os$user_agent_string)
      expect_equal(thisUa$os.family, os$family)
      expect_equal(thisUa$os.major, os$major)
      expect_equal(thisUa$os.minor, os$minor)
      expect_equal(thisUa$os.patch, os$patch)
    }
  }
}


osTestNA <- function()
{
  uaFiles = c("./tests/test_os.yaml")

  for(fName in uaFiles)
  {
    uas = read_yaml(fName)
    for(os in uas$test_cases)
    {
      thisUa = uaparserjs::ua_parse(os$user_agent_string, useNA=TRUE)
      expect_equal(thisUa$os.family, os$family)
      if(is.null(os$major))
      {
        expect_true(is.na(thisUa$os.major))
      }
      else
      {
        expect_equal(thisUa$os.major, os$major)
      }
      if(is.null(os$minor))
      {
        expect_true(is.na(thisUa$os.minor))
      }
      else
      {
        expect_equal(thisUa$os.minor, os$minor)
      }
      if(is.null(os$patch))
      {
        expect_true(is.na(thisUa$os.patch))
      }
      else
      {
        expect_equal(thisUa$os.patch, os$patch, info="NA true - patch")
      }
    }
  }
}

osTest()
osTestNA()


# ['../tests/test_device.yaml'].forEach(function(fileName) {
#   var fixtures = readYAML(fileName).test_cases;
#   suite(fileName, function() {
#     fixtures.forEach(function(f) {
#       test(f.user_agent_string, function() {
#         var device = refImpl.parse(f.user_agent_string).device;
#         fixFixture(f, ['family', 'brand', 'model']);
#         assert.strictEqual(device.family, f.family, msg('device.family', device.family, f.family));
#         assert.strictEqual(device.brand, f.brand, msg('device.brand', device.brand, f.brand));
#         assert.strictEqual(device.model, f.model, msg('device.model', device.model, f.model));
#       });
#     });
#   });
# });

devTest <- function()
{
  uaFiles = c("./tests/test_device.yaml")


  for(fName in uaFiles)
  {
    uas = read_yaml(fName)
    for(dev in uas$test_cases)
    {
      thisUa = uaparserjs::ua_parse(dev$user_agent_string)
      expect_equal(thisUa$device.family, dev$family)
      expect_equal(thisUa$device.brand, dev$brand)
      expect_equal(thisUa$device.model, dev$model)
    }
  }
}

devTestNA <- function()
{
  uaFiles = c("./tests/test_device.yaml")

  for(fName in uaFiles)
  {
    uas = read_yaml(fName)
    for(dev in uas$test_cases)
    {
      thisUa = uaparserjs::ua_parse(dev$user_agent_string, useNA=TRUE)
      if(is.null(dev$family))
      {
        expect_true(is.na(thisUa$device.family))
      }
      else
      {
        expect_equal(thisUa$device.family, dev$family)
      }
      if(is.null(dev$brand))
      {
        expect_true(is.na(thisUa$device.brand))
      }
      else
      {
        expect_equal(thisUa$device.brand, dev$brand, info=paste("with NA", thisUa$device.brand, dev$brand))
      }
      if(is.null(dev$model))
      {
        expect_true(is.na(thisUa$device.model))
      }
      else
      {
        expect_equal(thisUa$device.model, dev$model)
      }
    }
  }
}

devTest()
devTestNA()

#function fixFixture(f, props) {
#  // A bug in the YAML parser makes empty fixture props
#  // return a vanila object.
#  props.forEach(function(p) {
#    if (typeof f[p] === 'object') {
#      f[p] = null;
#    }
#  })
#  return f;
#}

