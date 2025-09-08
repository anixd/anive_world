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
#  role                  :integer          default("neophyte"), not null
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
  # enum role: { admin: 0, owner: 1, editor: 2 }, _suffix: :role

  attr_accessor :remember_token

  has_secure_password

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 16 }
  validates :email, presence: true, uniqueness: true, length: { minimum: 9, maximum: 42 }
  validates :firstname, presence: true, length: { minimum: 2, maximum: 16 }
  validates :lastname, presence: true, length: { minimum: 2, maximum: 16 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  enum :role, { root: 0, owner: 1, author: 2, editor: 3, neophyte: 4 }

  def can_manage_all_content?
    root? || owner? || author?
  end

  def can_manage_user_role?(other_user)
    # root может менять всех, owner тоже.
    # Остальные могут менять только тех, кто ниже по иерархии.
    root? || owner? || User.roles[self.role] < User.roles[other_user.role]
  end

  def remember_me
    self.remember_token = SecureRandom.urlsafe_base64
    update_column :remember_token_digest, digest(remember_token)
  end

  def forget_me
    update_column :remember_token_digest, nil
    self.remember_token = nil
  end

  def remember_token_authenticated?(remember_token)
    return false unless remember_token_digest.present?

    BCrypt::Password.new(remember_token_digest).is_password?(remember_token)
  end

  def can_login?
    return false unless active?

    true
  end

  private

  def digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost:)
  end
end
