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
           function() a_feature_string({context = ctx},
                                       table.concat({'Feature: Parse a feature name and description',
                                                     '  In order to...',
                                                     '  As a...',
                                                     '  I want to...',
                                                     ''}, '\n'))
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
          function() a_feature_string({context = ctx}, table.concat({'Feature: Meta-parse a feature',
                                                                     '  ...',
                                                                     '',
                                                                     '  Scenario: Meta-scenario',
                                                                     '    Given a Foo',
                                                                     '    When I bar that foo',
                                                                     '    I should see a foo\'d bar',
                                                                     ''}, '\n'))
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
         function() a_feature_string({context = ctx}, table.concat({'Feature: with table',
                                                                    '  ...',
                                                                    '',
                                                                    '  Scenario: with table',
                                                                    '    Given the table:',
                                                                    '      | a | b |',
                                                                    '      | 1 | 2 |',
                                                                    '      | 3 | 4 |',
                                                                    '      | 5 | 6 |',
                                                                    ''}, '\n'))
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
          function() a_feature_string({context = ctx}, table.concat({'Feature: with long string',
                                                                     '  ...',
                                                                     '',
                                                                     '  Scenario: with long string',
                                                                     '    Given the long string:',
                                                                     '      """',
                                                                     '      one',
                                                                     '      two',
                                                                     '      three',
                                                                     '      """',
                                                                     ''}, '\n'))
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
          function() a_feature_string({context = ctx}, table.concat({'Feature: with long string',
                                                                     '  ...',
                                                                     '',
                                                                     '  Scenario: with long string',
                                                                     '    Given the long string:',
                                                                     "      '''",
                                                                     '      one',
                                                                     '       two',
                                                                     '        three',
                                                                     "      '''",
                                                                     ''}, '\n'))
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
   local lines = step.context.feature.scenarios[scenario].steps[step_n].multiline
   assert_equal(lines[line_n], expected_value)
end