class Forge::TagsController < Forge::BaseController
  before_action :set_tag, only: %i[edit update destroy]

  def index
    authorize Tag
    @tags = policy_scope(Tag)
              .left_joins(:taggings)
              .group(:id)
              .order(name: :asc)
              .select('tags.*, COUNT(taggings.id) AS taggings_count')
  end

  def new
    @tag = Tag.new
    authorize @tag
  end

  def create
    @tag = Tag.new(tag_params)
    authorize @tag

    if @tag.save
      redirect_to forge_tags_path, notice: "Тег '#{@tag.name}' создан."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @tag
  end

  def update
    authorize @tag
    if @tag.update(tag_params)
      redirect_to forge_tags_path, notice: "Тег '#{@tag.name}' обновлен."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @tag
    # Благодаря `dependent: :destroy` в модели Tag,
    # все связанные записи `taggings` будут удалены автоматически.
    @tag.destroy
    redirect_to forge_tags_path, notice: "Тег '#{@tag.name}' удален."
  end

  def search
    authorize Tag
    query = params[:query].to_s.downcase
    tags = policy_scope(Tag).where("name LIKE ?", "#{query}%").limit(10).pluck(:name)
    render json: tags
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
