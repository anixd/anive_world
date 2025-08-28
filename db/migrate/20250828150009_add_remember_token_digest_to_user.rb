class AddRememberTokenDigestToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :remember_token_digest, :string
  end
end
