# == Schema Information
#
# Table name: users
#
#  id                    :bigint           not null, primary key
#  active                :boolean          default(FALSE)
#  displayname           :string           not null
#  email                 :string           not null
#  firstname             :string
#  lastname              :string
#  password_digest       :string
#  remember_token_digest :string
#  username              :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_username  (username) UNIQUE
#
class User < ApplicationRecord

  attr_accessor :remember_token

  has_secure_password

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 16 }
  validates :email, presence: true, uniqueness: true, length: { minimum: 9, maximum: 42 }
  validates :firstname, presence: true, length: { minimum: 2, maximum: 16 }
  validates :lastname, presence: true, length: { minimum: 2, maximum: 16 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

end
