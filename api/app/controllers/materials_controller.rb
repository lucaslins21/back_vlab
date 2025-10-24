class MaterialsController < ApplicationController
  before_action :authenticate_user!, only: %i[create update destroy]
  before_action :set_material, only: %i[show update destroy]
  before_action :authorize_owner!, only: %i[update destroy]

  def index
    scope = Material.includes(:author)
    if current_user
      # Published from everyone + all mine
      scope = scope.where('materials.status = ? OR materials.user_id = ?', 'publicado', current_user.id)
    else
      scope = scope.published
    end
    scope = scope.search(params[:q]) if params[:q].present?
    materials = scope.order(created_at: :desc).page(params[:page]).per(params[:per] || 20)
    render json: {
      data: materials.as_json,
      pagination: {
        current_page: materials.current_page,
        total_pages: materials.total_pages,
        total_count: materials.total_count
      }
    }
  end

  def search
    index
  end

  def show
    # Allow if published or owned by requester
    if @material.status != 'publicado'
      authenticate_user!
      return render json: { error: 'Sem permissão' }, status: :forbidden unless @material.user_id == current_user.id
    end
    render json: @material
  end

  def create
    material = material_class.new(material_params)
    material.user = current_user
    if material.is_a?(Book)
      OpenLibraryClient.fill_book!(material) if material.isbn.present?
    end
    material.save!
    render json: material, status: :created
  end

  def update
    if @material.is_a?(Book) && params.dig(:material, :isbn).present?
      OpenLibraryClient.fill_book!(@material, incoming: material_params.to_h)
    end
    @material.update!(material_params)
    render json: @material
  end

  def destroy
    @material.destroy!
    head :no_content
  end

  private

  def set_material
    @material = Material.find(params[:id])
  end

  def authorize_owner!
    render json: { error: 'Sem permissão' }, status: :forbidden unless @material.user_id == current_user.id
  end

  def material_class
    case params[:type] || params.dig(:material, :type)
    when 'Book' then Book
    when 'Article' then Article
    when 'Video' then Video
    else Material
    end
  end

  def material_params
    params.require(:material).permit(
      :type, :title, :description, :status, :author_id, :isbn, :page_count, :doi, :duration_minutes
    )
  end
end

