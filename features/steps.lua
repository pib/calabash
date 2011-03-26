require 'calabash'
require 'lpeg'

step('a feature string "(.*)"',
function(step, str)
   step.context.feature_string = str
end)

step('a feature string:',
function(step)
   step.context.feature_string = step.multiline
end)

step('parse the feature string',
function(step)
   step.context.feature = calabash.parse(step.context.feature_string)
end)

step('I should get the following attributes:',
function(step)
   local feature = step.context.feature
   for i = 1, #step.hashes do
      local hash = step.hashes[i]
      assert_equal(feature[hash.key], hash.value)
   end
end)

step('scenario (.*) attribute "(.*)" should be "(.*)"',
function(step, num, name, value)
   assert_equal(step.context.feature.scenarios[tonumber(num)][name], value)
end)

step('feature attribute "(.*)" should be "(.*)"',
function(step, name, value)
   assert_equal(step.context.feature[name], value)
end)

step('feature attribute "(.*)" should be:',
function(step, name)
   assert_equal(step.context.feature[name], step.multiline)
end)

step('scenarios list should have length (.*)',
function(step, length)
   assert_equal(#step.context.feature.scenarios, tonumber(length))
end)

step('scenario (.*) should have these steps:',
function(step, num)
   local actual_steps = step.context.feature.scenarios[tonumber(num)].steps
   for i, step in ipairs(step.hashes) do
      assert_equal(actual_steps[i].name, step.step)
   end
end)

step('scenario (.*) step (.*) row (.*) field "(.*)" should be "(.*)"',
function(step, scenario, step_n, row, field, expected_value)
   scenario, step_n, row = tonumber(scenario), tonumber(step_n), tonumber(row)
   local actual_value = step.context.feature.scenarios[scenario].steps[step_n].hashes[row][field]
   assert_equal(actual_value, expected_value)
end)

function split (s, sep)
   sep = lpeg.P(sep)
   local elem = lpeg.C((1 - sep)^0)
   local p = lpeg.Ct(elem * (sep * elem)^0)
   return lpeg.match(p, s)
end

step('scenario (.*) step (.*) multiline line (.*) should be "(.*)"',
function(step, scenario, step_n, line_n, expected_value)
   scenario, step_n, line_n = tonumber(scenario), tonumber(step_n), tonumber(line_n)
   local lines = split(step.context.feature.scenarios[scenario].steps[step_n].multiline, '\n')
   assert_equal(lines[line_n], expected_value)
end)

function a_step_named(step, name)
   step.context.steps = step.context.steps or {}
   step.context.steps[calabash.make_step_pattern(name)] = function(step_, ...)
                                                             step.context.step_params = {...}
                                                          end
end
step('a step named "(.*)"', a_step_named)
step("a step named '(.*)'", a_step_named)

function make_a_step_with_name(step, name)
   step.context.created_step = calabash.make_step({name = name}, step.context.steps)
end
step('make a step with name "(.*)"', make_a_step_with_name)
step("make a step with name '(.*)'", make_a_step_with_name)

step('call that step',
function(step)
   step.context.created_step()
end)

step('step should be called with no parameters',
function(step)
   assert_equal(#step.context.step_params, 0)
end)

step('step should be called with the parameter "(.*)"',
function(step, param)
   assert_equal(#step.context.step_params, 1)
   assert_equal(step.context.step_params[1], param)
end)

step('step should be called with these parameters:',
function(step)
   for i, hash in pairs(step.hashes) do
      assert_equal(step.context.step_params[i], hash.param)
   end
end)

step('generate a telescope context',
function(step)
   step.context.telescope_context = calabash.generate_contexts(step.context.feature_string,
                                                              step.context.steps)
end)

step('context should have the following values:',
function(step)
   for i, context in pairs(step.context.telescope_context) do
      local expected = step.hashes[i]
      for key, value in pairs(context) do
         if key ~= 'test' then
            assert_equal(tostring(value), expected[key])
         end
      end
   end
end)

step('feature should have the tags:',
function(step)
   for i, tag in pairs(step.hashes) do
      assert_equal(step.context.feature.tags[i], tag.tag)
   end
end)

step('scenario (.*) should have the tags:',
function(step, scenario)
   local tags = step.context.feature.scenarios[tonumber(scenario)].tags
   for i, tag in pairs(step.hashes) do
      assert_equal(tags[i], tag.tag)
   end
end)