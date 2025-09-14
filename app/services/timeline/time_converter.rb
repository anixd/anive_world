class Timeline::TimeConverter
  # При инициализации мы можем "загрузить" все календари один раз,
  # чтобы не делать лишних запросов к БД при многократных вызовах.
  def initialize
    @calendars = Timeline::Calendar.all.index_by(&:id)
  end

  # Конвертирует из абсолютного года в дату для конкретного календаря
  # Пример: from_absolute(absolute_year: 7034, to_calendar_id: 2) -> "1712 год Откровения"
  def from_absolute(absolute_year:, to_calendar_id:)
    calendar = @calendars[to_calendar_id]
    return "N/A" unless calendar && absolute_year

    # Вычисляем год относительно "нулевой точки" календаря.
    # Вычитаем (epoch - 1), чтобы год начала эпохи считался как "1", а не "0".
    relative_year = absolute_year - (calendar.absolute_year_of_epoch - 1)

    format_year(relative_year, calendar.epoch_name)
  end

  # Конвертирует из даты в конкретном календаре в абсолютный год
  # Пример: to_absolute(year: 1712, from_calendar_id: 2) -> 7034
  # Пример: to_absolute(year: -100, from_calendar_id: 2) -> 5222 (100 лет до Катастрофы)
  def to_absolute(year:, from_calendar_id:)
    calendar = @calendars[from_calendar_id]
    return nil unless calendar

    # Год "до нашей эры" просто прибавляется (т.к. он уже отрицательный)
    if year <= 0
      calendar.absolute_year_of_epoch + year
    else
      # Год "нашей эры"
      calendar.absolute_year_of_epoch + year - 1
    end
  end

  def convert(year:, from_calendar_id:, to_calendar_id:)
    # Шаг 1: Конвертируем из "календаря А" в абсолютную шкалу
    absolute = to_absolute(year: year, from_calendar_id: from_calendar_id)

    # Шаг 2: Конвертируем из абсолютной шкалы в "календарь Б"
    from_absolute(absolute_year: absolute, to_calendar_id: to_calendar_id)
  end

  def from_absolute_parts(absolute_year:, to_calendar_id:)
    calendar = @calendars[to_calendar_id]
    return nil unless calendar && absolute_year

    relative_year = absolute_year - (calendar.absolute_year_of_epoch - 1)

    if relative_year <= 0
      { year: relative_year.abs + 1, is_before_epoch: true }
    else
      { year: relative_year, is_before_epoch: false }
    end
  end

  private

  # Вспомогательный метод для красивого форматирования
  def format_year(year, epoch_name)
    if year <= 0
      # Год 0 — это 1-й год до эпохи. Год -1 — это 2-й. Поэтому .abs + 1
      "#{year.abs + 1} год до #{epoch_name}"
    else
      "#{year} год #{epoch_name}"
    end
  end
end
