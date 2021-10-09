# frozen_string_literal: true

Given('I am a teacher') do
  @user = FactoryBot.create :teacher
end

Given('there is a project') do
  @project = FactoryBot.create :project
end

Given('I want to add a student to the project') do
  @student = FactoryBot.build :student
end

When('I visit the projects page') do
  visit projects_url
end

Then('I should see a link for the project') do
  expect(page).to have_link(href: project_path(@project))
end

When('I click the link for the project') do
  find_all("a[href='#{project_path(@project)}']").first.click
end

Then('I should see the details of my project') do
  expect(page).to have_content @project.name
  expect(page).to have_content @project.url
end

Then('I should see a form to add a student') do
  within '#new-student-form' do
    expect(page).to have_field('Studentid')
    expect(page).to have_field('Name')
  end
end

When('I submit the form') do
  within '#new-student-form' do
    fill_in 'Studentid', with: @student.studentid
    fill_in 'Name', with: @student.name
  end
  click_button 'Update project students'
end

Then('I should see the student added to the project') do
  expect(page).to have_content @student.studentid
  expect(page).to have_content @student.name
end

Then('I should see an edit link') do
  expect(page).to have_link href: edit_project_path(@project)
end

When('I click the edit link') do
  find_link(href: edit_project_path(@project)).click
end

Given('I am a student') do
  @user = FactoryBot.create :student_user
end

Given('I want to add myself to the project') do
  @student_to_add = @user
end

Then('I should see a link to add myself to the project') do
  expect(page).to have_link text: 'Add self to project'
end

When('I click the “add myself” link') do
  find_link(text: 'Add self to project').click
end

Then('I should be listed as a student on the project') do
  expect(page).to have_content @user.studentid
end
