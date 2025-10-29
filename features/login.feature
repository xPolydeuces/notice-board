Feature: User login
  In order to access my account
  As a registered user
  I want to log in

  Scenario: Successful login
    Given a user exists with email "patryk@example.com" and password "secret"
    When I log in as "patryk@example.com" with password "secret"
    Then I should see "Signed in successfully"

  Scenario: Unsuccessful login
    Given a user exists with email "patryk@example.com" and password "secret"
    When I log in as "patryk@example.com" with password "wrong"
    Then I should see "Invalid Email or password."

  Scenario: Not registered user
    When I log in as "patryk@example.com" with password "secret"
    Then I should see "Invalid Email or password."
