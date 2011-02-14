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
