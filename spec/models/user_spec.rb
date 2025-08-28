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
require 'rails_helper'

RSpec.describe User, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
