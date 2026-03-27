
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

uaTest<-function()
{
  uaFiles = c('./tests/test_ua.yaml')

  for(fName in uaFiles )
  {
    uas = read_yaml(fName)
    for(ua in uas$test_cases)
    {
      thisUa = uaparserjs::ua_parse(ua$user_agent_string)
      expect_equal(thisUa$ua.family, ua$family);
      expect_equal(thisUa$ua.major, ua$major);
      expect_equal(thisUa$ua.minor, ua$minor);
      expect_equal(thisUa$ua.patch, ua$patch);
    }
  }
}

uaTest()

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

osTest<-function()
{
  uaFiles = c("./tests/test_os.yaml")

  for(fName in uaFiles )
  {
    uas = read_yaml(fName)
    for(os in uas$test_cases)
    {
      thisUa = uaparserjs::ua_parse(os$user_agent_string)
      expect_equal(thisUa$os.family, os$family);
      expect_equal(thisUa$os.major, os$major);
      expect_equal(thisUa$os.minor, os$minor);
      expect_equal(thisUa$os.patch, os$patch);
    }
  }
}

osTest()


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

devTest<-function()
{
  uaFiles = c("./tests/test_device.yaml")

  for(fName in uaFiles )
  {
    uas = read_yaml(fName)
    for(dev in uas$test_cases)
    {
      thisUa = uaparserjs::ua_parse(dev$user_agent_string)
      expect_equal(thisUa$device.family, dev$family);
      expect_equal(thisUa$device.brand, dev$brand);
      expect_equal(thisUa$device.model, dev$model);
    }
  }
}

devTest()

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

