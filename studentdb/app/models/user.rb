# frozen_string_literal: true

# User model active record
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  before_save :make_first_user_an_admin

  protected

  # If there are no users yet, make this user an admin

  def make_first_user_an_admin
    return unless User.count.zero?

    self.is_admin = true
  end
end
