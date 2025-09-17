
class LegacyRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :anixsite_legacy
end

module Legacy
  class AnikeWordType < LegacyRecord
    self.table_name = "anike_word_types"
    has_and_belongs_to_many :words,
                            class_name: "Legacy::AnikeWord",
                            join_table: "anike_words_word_types",
                            foreign_key: "anike_word_type_id",
                            association_foreign_key: "anike_word_id"
  end

  class AnikeEtymology < LegacyRecord
    self.table_name = "anike_etymologies"
  end

  class AnikeWord < LegacyRecord
    self.table_name = "anike_words"
    has_and_belongs_to_many :word_types,
                            class_name: "Legacy::AnikeWordType",
                            join_table: "anike_words_word_types",
                            foreign_key: "anike_word_id",
                            association_foreign_key: "anike_word_type_id"
    has_one :etymology, class_name: "Legacy::AnikeEtymology", foreign_key: "word_id"
  end



  class AnikeArticle < LegacyRecord
    self.table_name = "anike_articles"
  end

  class AnikeHistoryEntry < LegacyRecord
    self.table_name = "anike_history_entries"
  end

  class AnikeNote < LegacyRecord
    self.table_name = "anike_notes"
  end
end
