Feature: Parse featuers
  In order to test features
  As a test framework author
  I need to parse features

  Scenario: Parse a feature name
    Given a name "Feature: Parse a feature headline"
    When I parse the name
    Then I should get the following attribute:
      | key  | value                    |
      | name | Parse a feature headline |