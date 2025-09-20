# frozen_string_literal: true

class Forge::HistoryEntriesController < Forge::BaseController
  before_action :set_history_entry, only: %i[show edit update destroy]
  before_action :set_form_options, only: %i[new edit create update]

  def index
    @pagy, @history_entries = pagy(policy_scope(HistoryEntry).includes(:tags).order(absolute_year: :asc))
  end

  def show
    authorize @history_entry
    @calendars = Timeline::Calendar.order(:name)
  end

  def new
    @history_entry = HistoryEntry.new
    authorize @history_entry
  end

  def create
    @history_entry = HistoryEntry.new(history_entry_params)
    @history_entry.author = current_user
    authorize @history_entry

    # Конвертируем дату из формы в absolute_year перед сохранением
    convert_date_to_absolute_year

    if @history_entry.save
      redirect_to forge_history_entry_path(@history_entry), notice: "History entry created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @history_entry
  end

  def update
    authorize @history_entry
    @history_entry.assign_attributes(history_entry_params)

    # Конвертируем дату из формы в absolute_year перед сохранением
    convert_date_to_absolute_year

    if @history_entry.save
      redirect_to forge_history_entry_path(@history_entry), notice: "History entry updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @history_entry
    @history_entry.discard
    redirect_to forge_history_entries_path, notice: "History entry archived."
  end

  private

  def set_history_entry
    @history_entry = HistoryEntry.includes(:tags).find_by!(slug: params[:id])
  end

  def set_form_options
    @calendars = Timeline::Calendar.order(:name)
    @eras = Timeline::Era.order(:name)
    # TODO: В будущем здесь нужно будет фильтровать Эры по выбранному Календарю
  end

  def convert_date_to_absolute_year
    # Получаем "виртуальные" атрибуты из формы
    calendar_id = params[:history_entry][:calendar_id].to_i
    year = params[:history_entry][:year].to_i
    is_before_epoch = params[:history_entry][:is_before_epoch] == "1"

    # Если год "до н.э.", делаем его отрицательным
    year = -year if is_before_epoch

    if calendar_id.present? && year.present?
      converter = Timeline::TimeConverter.new
      @history_entry.absolute_year = converter.to_absolute(year: year, from_calendar_id: calendar_id)
    end
  end

  def history_entry_params
    params.require(:history_entry).permit(:title, :body, :era_id, :display_date, :tags_string, :publish)
  end
end
