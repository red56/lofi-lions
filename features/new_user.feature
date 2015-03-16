Feature: New User
I want to be able to add an email with the password reset link
to active job when an admin creates a new user

Scenario: An email is sent when a new user is created
	Given I am logged in as an administrator
	And I create a new user "someone@example.com"
	Then an email with a password reset link should be added to the delayed jobs
	And when the email is sent
	Then in a new browser session
	Then they should be able to see the email
	And click "password reset"