# frozen_string_literal: true

class Pub::HistoryEntriesController < Pub::BaseController
  def index
    entries = HistoryEntry.published.order(absolute_year: :asc)
    @pagy, @history_entries = pagy(entries)
  end

  def show
    @history_entry = HistoryEntry.published
                                 .includes(:participating_characters, :participating_locations)
                                 .find_by!(slug: params[:id])
  end
end
