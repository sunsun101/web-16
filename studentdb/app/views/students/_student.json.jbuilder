# frozen_string_literal: true

json.extract! student, :id, :studentid, :name, :created_at, :updated_at
json.url student_url(student, format: :json)
