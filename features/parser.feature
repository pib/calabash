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

  Scenario: Parse a feature and scenario with a table in the steps
    Given a feature string:
      """
      Feature: with table
        ...

        Scenario: with table
          Given the table:
            | a | b |
            | 1 | 2 |
            | 3 | 4 |
            | 5 | 6 |
      """
    When I parse the feature string
    Then scenario 1, step 1, row 1, field "a" should be "1"
    And scenario 1, step 1, row 1, field "b" should be "2"
    And scenario 1, step 1, row 2, field "a" should be "3"
    And scenario 1, step 1, row 2, field "b" should be "4"
    And scenario 1, step 1, row 3, field "a" should be "5"
    And scenario 1, step 1, row 3, field "b" should be "6"

  Scenario: Parse a feature and scenario with double-quoted long strings
    Given a feature string:
      '''
      Feature: with long string
        ...

        Scenario: with long string
          Given the long string:
            """
            one
             two
              three
            """
      '''
    When I parse the feature string
    Then scenario 1, step 1 multiline line 1 should be "one"
    And scenario 1, step 1 multiline line 2 should be "two"
    And scenario 1, step 1 multiline line 3 should be "three"

  Scenario: Parse a feature and scenario with single-quoted long strings
    Given a feature string:
      """
      Feature: with long string
        ...

        Scenario: with long string
          Given the long string:
            '''
            four
            five
            six
            '''
      """
    When I parse the feature string
    Then scenario 1, step 1 multiline line 1 should be "one"
    And scenario 1, step 1 multiline line 2 should be "two"
    And scenario 1, step 1 multiline line 3 should be "three"
