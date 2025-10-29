Feature: User registration
  In order to create an account
  As a visitor
  I want to register

  Scenario: Successful registration
    When I register as "patryk@example.com" with password "secret"
    Then I should see "Welcome! You have signed up successfully."

  Scenario: User already registered
    Given a user exists with email "patryk@example.com" and password "secret"
    When I register as "patryk@example.com" with password "secret"
    Then I should see "Email has already been taken"
