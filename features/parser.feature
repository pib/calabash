Feature: Parse featuers
  In order to test features
  As a test framework author
  I need to parse features

  Scenario: Parse a feature name
    Given a feature string "Feature: Parse a feature name"
    When I parse the feature string
    Then I should get the following attributes:
      | key  | value                |
      | name | Parse a feature name |

  Scenario: Parse a feature name and description
    Given a feature string:
      """
      Feature: Parse a feature name and description
        In order to...
        As a...
        I want to...
      """
    When I parse the feature string
    The attribute "name" should be "Parse a feature name and description"
    And the attribute "description" should be:
      """
      In order to...
      As a...
      I want to...
      """

  Scenario: Parse a feature name, description, and scenario
    Given a feature string:
      """
      Feature: Meta-parse a feature
        ...

        Scenario: Meta-scenario
          Given a Foo
          When I bar that foo
          I should see a foo'd bar
      """
    When I parse the feature string
    The attribute "name" should be "Meta-parse a feature"
    And the attribute "description" should be "..."
    And the scenarios list should have length 1
    And scenario 1 attribute "name" should be "Meta-scenario"
    And scenario 1 should have these steps:
      | step                     |
      | Given a Foo              |
      | When I bar that foo      |
      | I should see a foo'd bar |