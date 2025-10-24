class AuthorsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_author, only: %i[show update destroy]

  def index
    authors = Author.all.order(:name)
    render json: authors
  end

  def show
    render json: @author
  end

  def create
    author = author_class.new(author_params)
    author.save!
    render json: author, status: :created
  end

  def update
    @author.update!(author_params)
    render json: @author
  end

  def destroy
    @author.destroy!
    head :no_content
  end

  private

  def set_author
    @author = Author.find(params[:id])
  end

  def author_class
    case params[:type]
    when 'PersonAuthor' then PersonAuthor
    when 'InstitutionAuthor' then InstitutionAuthor
    else Author
    end
  end

  def author_params
    params.require(:author).permit(:name, :birth_date, :city, :type)
  end
end

