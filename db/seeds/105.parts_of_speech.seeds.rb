# db/seeds/105.parts_of_speech.seeds.rb

author = User.first
unless author
  puts "❌ Не найден ни один пользователь. Пожалуйста, создайте админа перед запуском сидов."
  return # Используем return вместо exit для большей безопасности
end

json_file_path = Rails.root.join('db', 'word_types_export.json')

unless File.exist?(json_file_path)
  puts "❌ Файл для импорта не найден: #{json_file_path}"
  return
end

puts "== Seeding Parts of Speech from JSON =="

# Читаем и парсим JSON
word_types_data = JSON.parse(File.read(json_file_path))

# Находим нужные языки в новой базе
languages = Language.where(code: word_types_data.pluck("language_code").uniq).index_by(&:code)

word_types_data.each do |attrs|
  language = languages[attrs['language_code']]
  unless language
    puts "⚠️ Пропущен тип '#{attrs['code']}', так как язык '#{attrs['language_code']}' не найден в базе."
    next
  end

  # Используем find_or_initialize_by для безопасного многократного запуска
  pos = PartOfSpeech.find_or_initialize_by(code: attrs['code'], language: language)
  pos.name = attrs['name']
  pos.explanation = attrs['explanation']
  pos.author = author

  if pos.new_record?
    puts "  -> Creating: #{pos.name} (#{pos.code}) for #{language.code}"
  else
    puts "  -> Updating: #{pos.name} (#{pos.code}) for #{language.code}"
  end

  pos.save!
end

puts "== Seeding complete! =="
