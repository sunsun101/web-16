# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { "testuser1@example.com" }
    password { "testpassword" }
    confirmed_at { 1.day.ago }
  end

  factory :teacher, class: User do
    email { "joe_teacher@ait.asia" }
    password { "testpassword" }
    confirmed_at { 1.day.ago }
  end

  factory :student_user, class: User do
    email { "st123456@ait.asia" }
    password { "testpassword" }
    is_student { true }
    confirmed_at { 1.day.ago }
  end

  factory :project do
    name { "My favorite project" }
    url { "http://somewhere.com" }
  end

  factory :student do
    name { "Joe Student" }
    studentid { "123456" }
  end

  factory :admin, class: User do
    email { "admin@ait.asia" }
    password { "password" }
    password_confirmation { "password" }
    is_admin { true }
    confirmed_at { 1.day.ago }
  end

  factory :user1, class: User do
    email { "sunsun@example.com" }
    password { "sunsun" }
    confirmed_at { 1.day.ago }
  end

  factory :user2, class: User do
    email { "prajwal@example.com" }
    password { "prajwal" }
    confirmed_at { 1.day.ago }
  end
end
