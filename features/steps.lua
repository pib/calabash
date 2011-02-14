require 'telescope'
require 'feature'

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
                                                     'In order to...',
                                                     'As a...',
                                                     'I want to...'}, '\n'))
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
end)

-- Given a feature string "(.*)"
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

-- The attribute "(.*)" should be "(.*)"
function the_attribute_should_be(step, name, value)
   assert_equal(step.context.feature[name], value)
end