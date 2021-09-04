
Feature: Users

  The application needs to maintain information about Users

  Scenario: Sign up

    On sign up, I should have to confirm by email

    Given I am an unregistered user
    When I sign up
    Then I should see an email confirmation page
    When I confirm
    Then I should be confirmed
    When I sign in
    Then I should be signed in
