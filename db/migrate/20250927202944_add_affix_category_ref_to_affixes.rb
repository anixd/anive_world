# frozen_string_literal: true

class AddAffixCategoryRefToAffixes < ActiveRecord::Migration[7.2]
  def change
    add_reference :affixes, :affix_category, null: true, foreign_key: true
  end
end
