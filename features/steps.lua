require 'telescope'
require 'feature'
require 'lpeg'

-- For bootstrapping, I'm embedding all the tests directly in here
-- Just until I have .feature parsing done enough to parse them from there...

-- Feature:
context("Parse Features",
function ()
   local ctx = {}
   
   -- Scenario:
   context("Parse a feature name",
   function()
      test('Given a feature string "Feature: Parse a feature name"',
           function() a_feature_string({context = ctx}, "Feature: Parse a feature name") end)

      test('When I parse the feature string',
           function() i_parse_the_feature_string{context = ctx} end)

      test('Then I should get the following attributes:',
           function()
              i_should_get_the_following_attributes({
                  context = ctx,
                  hashes = {{key = 'name', value = 'Parse a feature name'}}}) 
           end)
   end)

   -- Scenario:
   context("Parse a feature name and description",
   function()
      test('Given a feature string:',
           function() a_multiline_feature_string({context = ctx, multiline = table.concat(
                                           {'Feature: Parse a feature name and description',
                                            '  In order to...',
                                            '  As a...',
                                            '  I want to...',
                                            ''}, '\n')})
           end)
      
      test('When I parse the feature string',
           function() i_parse_the_feature_string{context = ctx} end)

      
      test('The attribute "name" should be "Parse a feature name and description"',
           function()
              the_attribute_should_be({context = ctx},
                                      'name',
                                      'Parse a feature name and description')
           end)

      test('And the attribute "description" should be:',
           function()
              the_attribute_should_be({context = ctx},
                                      'description',
                                      table.concat({'In order to...',
                                                    'As a...',
                                                    'I want to...'}, '\n'))
           end)
   end)

   -- Scenario:
  context("Parse a feature name, description, and scenario",
  function()
     test('Given a feature string:',
          function() a_multiline_feature_string{context = ctx, multiline = table.concat(
                                                   {'Feature: Meta-parse a feature',
                                                    '  ...',
                                                    '',
                                                    '  Scenario: Meta-scenario',
                                                    '    Given a Foo',
                                                    '    When I bar that foo',
                                                    '    I should see a foo\'d bar',
                                                    ''}, '\n')}
          end)

     test('When I parse the feature string',
          function() i_parse_the_feature_string{context = ctx} end)

     test('The attribute "name" should be "Meta-parse a feature"',
          function()
             the_attribute_should_be({context = ctx},
                                     'name',
                                     'Meta-parse a feature')
          end)

     test('And the attribute "description" should be "..."',
          function()
             the_attribute_should_be({context = ctx},
                                     'description',
                                     '...')
          end)

     test('And the scenarios list should have length 1',
          function()
             scenarios_list_should_have_length({context = ctx}, 1)
          end)

     test('And scenario 1 attribute "name" should be "Meta-scenario"',
          function() scenario_attribute_should_be({context = ctx}, 1, 'name', 'Meta-scenario') end)

     test('And scenario 1 should have these steps:',
          function()
             scenario_should_have_these_steps({context = ctx},
                                              1,
                                              {{step = 'Given a Foo'},
                                               {step = 'When I bar that foo'},
                                               {step = 'I should see a foo\'d bar'}})
          end)
  end)

  -- Scenario:
  context("Parse a feature and scenario with a table in the steps",
  function()
    test('Given a feature string:',
         function() a_multiline_feature_string({context = ctx, multiline = table.concat(
                                                   {'Feature: with table',
                                                    '  ...',
                                                    '',
                                                    '  Scenario: with table',
                                                    '    Given the table:',
                                                    '      | a | b |',
                                                    '      | 1 | 2 |',
                                                    '      | 3 | 4 |',
                                                    '      | 5 | 6 |',
                                                    ''}, '\n')})
         end)

    test('When I parse the feature string', 
         function() i_parse_the_feature_string{context = ctx} end)

    test('Then scenario 1, step 1, row 1, field "a" should be "1"',
         function() scenario_step_row_field_should_be({context = ctx}, 1, 1, 1, 'a', '1') end)

    test('Then scenario 1, step 1, row 1, field "b" should be "2"',
         function() scenario_step_row_field_should_be({context = ctx}, 1, 1, 1, 'b', '2') end)

    test('Then scenario 1, step 1, row 2, field "a" should be "3"',
         function() scenario_step_row_field_should_be({context = ctx}, 1, 1, 2, 'a', '3') end)

    test('Then scenario 1, step 1, row 2, field "b" should be "4"',
         function() scenario_step_row_field_should_be({context = ctx}, 1, 1, 2, 'b', '4') end)

    test('Then scenario 1, step 1, row 3, field "a" should be "5"',
         function() scenario_step_row_field_should_be({context = ctx}, 1, 1, 3, 'a', '5') end)

    test('Then scenario 1, step 1, row 3, field "b" should be "6"',
         function() scenario_step_row_field_should_be({context = ctx}, 1, 1, 3, 'b', '6') end)

  end)

  -- Scenario:
  context("Parse a feature and scenario with double-quoted long strings",
  function()
     test('Given a feature string:',
          function() a_multiline_feature_string({context = ctx, multiline = table.concat(
                                                    {'Feature: with long string',
                                                     '  ...',
                                                     '',
                                                     '  Scenario: with long string',
                                                     '    Given the long string:',
                                                     '      """',
                                                     '      one',
                                                     '      two',
                                                     '      three',
                                                     '      """',
                                                     ''}, '\n')})
          end)

    test('When I parse the feature string', 
         function() i_parse_the_feature_string{context = ctx} end)

    test('Then scenario 1, step 1, multiline line 1 should be "one"',
         function() scenario_step_multiline_line_should_be({context = ctx}, 1, 1, 1, "one") end)

    test('Then scenario 1, step 1, multiline line 1 should be "two"',
         function() scenario_step_multiline_line_should_be({context = ctx}, 1, 1, 2, "two") end)

    test('Then scenario 1, step 1, multiline line 2 should be "three"',
         function() scenario_step_multiline_line_should_be({context = ctx}, 1, 1, 3, "three") end)

 end)

  -- Scenario:
  context("Parse a feature and scenario with double-quoted long strings",
  function()
     test('Given a feature string:',
          function() a_multiline_feature_string({context = ctx, multiline = table.concat(
                                                    {'Feature: with long string',
                                                     '  ...',
                                                     '',
                                                     '  Scenario: with long string',
                                                     '    Given the long string:',
                                                     "      '''",
                                                     '      one',
                                                     '       two',
                                                     '        three',
                                                     "      '''",
                                                     ''}, '\n')})
          end)

    test('When I parse the feature string', 
         function() i_parse_the_feature_string{context = ctx} end)

    test('Then scenario 1, step 1, multiline line 1 should be "one"',
         function() scenario_step_multiline_line_should_be({context = ctx}, 1, 1, 1, "one") end)

    test('Then scenario 1, step 1, multiline line 1 should be "two"',
         function() scenario_step_multiline_line_should_be({context = ctx}, 1, 1, 2, " two") end)

    test('Then scenario 1, step 1, multiline line 2 should be "three"',
         function() scenario_step_multiline_line_should_be({context = ctx}, 1, 1, 3, "  three") end)

 end)

end)

-- a feature string "(.*)"
function a_feature_string(step, str)
   step.context.feature_string = str
end

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

-- Feature:
context('Generate telescope contexts',
function()
   local ctx = {}

   -- Scenario:
   context('Match on a simple string',
   function()
      test('Given a step named "Hello there"',
           function() a_step_named({context = ctx}, 'Hello there') end)

      test('When I make a step with name "Hello there"',
           function() make_a_step_with_name({context = ctx}, 'Given Hello there') end)

      test('And I call that step',
           function() call_step{context = ctx} end)

      test('Then that step should be called with no parameters',
           function() step_should_be_called_with_no_parameters{context = ctx} end)

   end)

   -- Scenario:
   context('Match on a non-whitespace wildcard',
   function()
      test('Given a step named "Hello (.*) there"',
           function() a_step_named({context = ctx}, 'Hello (.*) there') end)

      test('When I make a step with name "Hello you there"',
           function() make_a_step_with_name({context = ctx}, 'Hello you there') end)

      test('And I call that step',
           function() call_step{context = ctx} end)

      test('Then that step should be called with the parameter "you"',
           function() step_should_be_called_with_the_parameter({context = ctx}, 'you') end)

   end)
   
   -- Scenario:
   context('Match on multiple wildcards',
   function()
      test('Given a step named \'Hello "(.*)" over (.*)\'',
           function() a_step_named({context = ctx}, 'Hello "(.*)" over (.*)') end)

      test('When I make a step with name "Hello you there"',
           function() make_a_step_with_name({context = ctx}, 'Hello "you people" over there') end)

      test('And I call that step',
           function() call_step{context = ctx} end)

      test('Then that step should be called with these parameters:',
           function() step_should_be_called_with_these_parameters({context = ctx,
                                                                   hashes = {
                                                                      {param = 'you people'},
                                                                      {param = 'there'}
                                                                }}) end)

   end)

   -- Scenario:
   context('Telescope steps for a simple feature',
   function()
      test('Given a feature string',
           function() a_multiline_feature_string{context = ctx, multiline = table.concat(
                                                    {'Feature: context',
                                                     '',
                                                     '  Scenario: subcontext',
                                                     '    Given a test',
                                                     ''}, '\n')} end)

      test('And a step named "a simple telescope test"',
           function() a_step_named({context = ctx}, 'a test') end)

      test('When I generate a telescope context',
           function() i_generate_a_telescope_context({context = ctx}) end)

      test('Then that context should have the following values:',
           function() that_context_should_have_the_following_values(
                 {context = ctx, hashtable =
                  {{context = 'true', context_name = '', name = 'context', parent = '0'},
                   {context = 'true', context_name = '', name = 'subcontext', parent = '1'},
                   {context = '', context_name = 'subcontext', name='Given a test', parent = '2'}}}) end)
   end)

end)

-- a step named
function a_step_named(step, name)
   step.context.steps = step.context.steps or {}
   step.context.steps[feature.make_step_pattern(name)] = function(step_, ...)
                                                            step.context.step_params = {...}
                                                         end
end

-- make a step with name "(.*)"
function make_a_step_with_name(step, name)
   step.context.created_step = feature.make_step({name = name}, step.context.steps)
end

-- call that step
function call_step(step)
   step.context.created_step()
end

-- step should be called with no parameters
function step_should_be_called_with_no_parameters(step)
   assert_equal(#step.context.step_params, 0)
end

-- step should be called with the parameter "(.*)"
function step_should_be_called_with_the_parameter(step, param)
   assert_equal(#step.context.step_params, 1)
   assert_equal(step.context.step_params[1], param)
end

-- step should be called with these parameters:
function step_should_be_called_with_these_parameters(step)
   for i, hash in pairs(step.hashes) do
      assert_equal(step.context.step_params[i], hash.param)
   end
end

-- generate a telescope context
function i_generate_a_telescope_context(step)
   step.context.telescope_context = feature.generate_context(step.context.feature_string,
                                                             step.context.steps)
end

-- context should have the following values:
function that_context_should_have_the_following_values(step)
   for i, context in pairs(step.context.telescope_context) do
      local expected = step.hashtable[i]
      for key, value in pairs(context) do
         if key ~= 'test' then
            assert_equal(tostring(value), expected[key])
         end
      end
   end
end