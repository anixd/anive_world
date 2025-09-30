# frozen_string_literal: true

class Forge::NotesController < Forge::BaseController
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @notes = pagy(policy_scope(Note).order(created_at: :desc))
  end

  def show
    authorize @note
  end

  def new
    @note = Note.new
    authorize @note
  end

  def create
    @note = current_user.notes.build(note_params)
    authorize @note

    if @note.save
      redirect_to forge_note_path(@note), notice: "Note created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @note
  end

  def update
    authorize @note
    if @note.update(note_params)
      redirect_to forge_note_path(@note), notice: "Note updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @note
    @note.discard
    redirect_to forge_notes_path, notice: "Note was successfully archived."
  end

  def search
    authorize Note, :create? # Anyone who can create notes can search for their own tags
    query = params[:query].to_s.downcase
    tags = policy_scope(current_user.note_tags).where("name LIKE ?", "#{query}%").limit(10).pluck(:name)
    render json: tags
  end

  private

  def set_note
    # Find the note by slug within the scope of all notes (Pundit will authorize it).
    @note = Note.find_by!(slug: params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :body, :tags_string)
  end
end
