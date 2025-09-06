class RemovePartOfSpeechFromWords < ActiveRecord::Migration[7.2]
  def change
    remove_reference :words, :part_of_speech, null: false, foreign_key: true
  end
end
