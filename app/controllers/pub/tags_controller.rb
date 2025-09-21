class Pub::TagsController < Pub::BaseController
  def show
    @tag = Tag.find_by!(name: params[:name])

    results = ContentEntry.published
                          .joins(:tags)
                          .where(tags: { id: @tag.id })
                          .order(published_at: :desc)

    @pagy, @results = pagy(results)
  end
end
