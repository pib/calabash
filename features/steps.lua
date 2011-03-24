require 'telescope'
require 'feature'
require 'lpeg'

step('a feature string "(.*)"',
function(step, str)
   step.context.feature_string = str
end)
-- a feature string "(.*)"
function a_feature_string(step, str)
   step.context.feature_string = str
end

step('a feature string',
function(step)
   step.context.feature_string = step.multiline
end)
-- a feature string
function a_multiline_feature_string(step)
   step.context.feature_string = step.multiline
end

-- I parse the feature string
function i_parse_the_feature_string(step)
   step.context.feature = feature.parse(step.context.feature_string)
end

-- I should get the following attributes:
function i_should_get_the_following_attributes(step)
   local feature = step.context.feature
   for i = 1, #step.hashes do
      local hash = step.hashes[i]
      assert_equal(feature[hash.key], hash.value)
   end
end

-- the attribute "(.*)" should be "(.*)"
function the_attribute_should_be(step, name, value)
   assert_equal(step.context.feature[name], value)
end

-- scenarios list should have length (.*)
function scenarios_list_should_have_length(step, length)
   assert_equal(#step.context.feature.scenarios, length)
end

-- scenario (.*) attribute "(.*)" should be "(.*)"
function scenario_attribute_should_be(step, num, name, value)
   assert_equal(step.context.feature.scenarios[num][name], value)
end

-- scenario (.*) should have these steps:
function scenario_should_have_these_steps(step, num, expected_steps)
   local actual_steps = step.context.feature.scenarios[num].steps
   for i, step in ipairs(expected_steps) do
      assert_equal(actual_steps[i].name, step.step)
   end
end

-- scenario (.*), step (.*), row (.*), field "(.*)" should be "(.*)"
function scenario_step_row_field_should_be(step, scenario, step_n, row, field, expected_value)
   local actual_value = step.context.feature.scenarios[scenario].steps[step_n].hashes[row][field]
   assert_equal(actual_value, expected_value)
end

function split (s, sep)
   sep = lpeg.P(sep)
   local elem = lpeg.C((1 - sep)^0)
   local p = lpeg.Ct(elem * (sep * elem)^0)
   return lpeg.match(p, s)
end

-- scenario (.*), step (.*), multiline line (.*) should be "(.*)"
function scenario_step_multiline_line_should_be(step, scenario, step_n, line_n, expected_value)
   local lines = split(step.context.feature.scenarios[scenario].steps[step_n].multiline, '\n')
   assert_equal(lines[line_n], expected_value)
end

function a_step_named(step, name)
   step.context.steps = step.context.steps or {}
   step.context.steps[feature.make_step_pattern(name)] = function(step_, ...)
                                                            step.context.step_params = {...}
                                                         end
end
step('a step named "(.*)"', a_step_named)
step("a step named '(.*)'", a_step_named)

function make_a_step_with_name(step, name)
   step.context.created_step = feature.make_step({name = name}, step.context.steps)
end
step('make a step with name "(.*)"', make_a_step_with_name)
step("make a step with name '(.*)'", make_a_step_with_name)

step('call that step',
function(step)
   step.context.created_step()
end)
-- call that step
function call_step(step)
   step.context.created_step()
end

step('step should be called with no parameters',
function(step)
   assert_equal(#step.context.step_params, 0)
end)
-- step should be called with no parameters
function step_should_be_called_with_no_parameters(step)
   assert_equal(#step.context.step_params, 0)
end

step('step should be called with the parameter "(.*)"',
function(step, param)
   assert_equal(#step.context.step_params, 1)
   assert_equal(step.context.step_params[1], param)
end)
-- step should be called with the parameter "(.*)"
function step_should_be_called_with_the_parameter(step, param)
   assert_equal(#step.context.step_params, 1)
   assert_equal(step.context.step_params[1], param)
end

step('step should be called with these parameters:',
function(step)
   for i, hash in pairs(step.hashes) do
      assert_equal(step.context.step_params[i], hash.param)
   end
end)
-- step should be called with these parameters:
function step_should_be_called_with_these_parameters(step)
   for i, hash in pairs(step.hashes) do
      assert_equal(step.context.step_params[i], hash.param)
   end
end

step('generate a telescope context',
function(step)
   step.context.telescope_context = feature.generate_context(step.context.feature_string,
                                                             step.context.steps)
end)
-- generate a telescope context
function i_generate_a_telescope_context(step)
   step.context.telescope_context = feature.generate_context(step.context.feature_string,
                                                             step.context.steps)
end

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
-- context should have the following values:
function that_context_should_have_the_following_values(step)
   for i, context in pairs(step.context.telescope_context) do
      local expected = step.hashes[i]
      for key, value in pairs(context) do
         if key ~= 'test' then
            assert_equal(tostring(value), expected[key])
         end
      end
   end
end
