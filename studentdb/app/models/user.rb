# frozen_string_literal: true

# User model active record
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  before_save :make_first_user_an_admin

  # Return student ID of a student user
  def studentid
    return unless is_student

    email[/st([0-9]*)@/, 1]
  end

  protected

  # If there are no users yet, make this user an admin
  def make_first_user_an_admin
    return unless User.count.zero?

    self.is_admin = true
  end

end
