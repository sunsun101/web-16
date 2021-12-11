
Feature: Admin

    Admin should to be able to perform user management activities

    Scenario: Remove Bozo user

        An Admin should be able to remove bozo user

        Given I am an Admin
        Given There are users
        And I am logged in
        When I visit admin dashboard
        Then I should see a list of users
        When I click delete button for a user
        Then the user should be deleted

    Scenario: Update  user

        Admin should be able to update a user

        Given I am an Admin
        Given There are users
        And I am logged in
        When I visit admin dashboard
        Then I should see a list of users
        When I click edit button for a user
        Then I should see a user edit form
        When I submit the user edit form
        Then I should see the changes in user

