class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i(show destroy)
  before_action :set_parents

  def new
    @post = Post.new
    @post.arts.build
  end

  def create
    @post = Post.new(post_params)
    if @post.arts.present?
      @post.save
      redirect_to root_path
      flash[:notice] = "投稿が保存されました"
    else
      redirect_to root_path
      flash[:alert] = "投稿に失敗しました"
    end
  end

  def index
    @posts = Post.includes(:arts, :user).order("created_at DESC").page(params[:page]).per(3)
  end

  def show
  end

  def destroy
    if @post.user == current_user
      flash[:notice] = "投稿が削除されました" if @post.destroy
    else
      flash[:alert] = "投稿の削除に失敗しました"
    end
    redirect_to root_path
  end

  def get_category_children
    @category_children = Category.find("#{params[:parent_id]}").children
  end

  def get_category_grandchildren
    @category_grandchildren = Category.find("#{params[:child_id]}").children
  end

  private
    def post_params
      params.require(:post).permit(:art_name,arts_attributes: [:image]).merge(user_id: current_user.id)
    end

    def set_post
      @post = Post.find_by(id: params[:id])
    end

    def set_parents
      @parents = Category.where(ancestry: nil)
    end
end
