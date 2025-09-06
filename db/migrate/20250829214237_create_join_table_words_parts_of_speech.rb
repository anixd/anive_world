class CreateJoinTableWordsPartsOfSpeech < ActiveRecord::Migration[7.2]
  def change
    create_join_table :words, :parts_of_speech do |t|
      t.index [:word_id, :part_of_speech_id]
      t.index [:part_of_speech_id, :word_id]
    end
  end
end
