Feature: Generate telescope contexts
  In order to test features
  As a test framework author
  I need to generate telescope contexts

  Scenario: Match on a simple string
    Given a step named "Hello there"
    When I make a step with name "Hello there"
    And I call that step function
    Then that step should be called with no parameters

  Scenario: Match on a non-whitespace wildcard
    Given a step named "Hello (.*) there"
    When I make a step with name "Hello you there"
    And I call that step function
    Then that step should be called with the parameter "you"

  Scenario: Match on multiple wildcards
    Given a step named 'Hello "(.*)" over (.*)'
    When I make a step with name 'Hello "you people" over there'
    And I call that step function
    Then that step should be called with these parameters:
      | param      |
      | you people |
      | there      |

  Scenario: Telescope steps for a simple feature
    Given a feature string
      """
      Feature: context
      
        Scenario: subcontext
          Given a test
      """
    And a step named "a test"
    When I generate a telescope context
    Then that context should have the following values:
      | context | context_name | name         | parent |
      | true    |              | context      | 0      |
      | true    |              | subcontext   | 1      |
      |         | subcontext   | Given a test | 2      |
