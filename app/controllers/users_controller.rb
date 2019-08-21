class UsersController < ApplicationController
  before_action :logged_in_user, except: [:show, :new, :create]
  before_action :load_user, except: [:index, :new, :create]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.activated.paginate page: params[:page],
      per_page: Settings.users.perpage
  end

  def show
    redirect_to root_path && return unless @user.activated?
    @microposts = @user.microposts.paginate page: params[:page],
      per_page: Settings.users.perpage
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      # flash[:success] = t "controller.user.create_success"
      # redirect_to @user
      redirect_to root_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "controller.user.update_success"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = t "controller.user.delete_success"
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation, :avatar
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "controller.user.not_found"
    redirect_to root_path
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  def correct_user
    @user = User.find_by id: params[:id]
    redirect_to(root_path) unless current_user?(@user)
  end
end
