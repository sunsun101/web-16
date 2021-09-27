# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'testuser1@example.com' }
    password { 'testpassword' }
    confirmed_at { 1.day.ago }
  end

  factory :teacher, class: User do
    email { 'joe_teacher@ait.asia' }
    password { 'testpassword' }
    confirmed_at { 1.day.ago }
  end

  factory :project do
    name { 'My favorite project' }
    url { 'http://somewhere.com' }
  end

  factory :student do
    name { 'Joe Student' }
    studentid { '123456' }
  end
end
