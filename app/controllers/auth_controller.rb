class AuthController <ApplicationController
  before_action :check_session, only: %i[new create]
  before_action :require_authentication, only: %i[destroy]

  def new; end

  def create
    # render plain: params.to_yaml and return # debug
    user = User.find_by username: params[:username]

    if user&.authenticate(params[:password]) && user&.can_login?
      sign_in user
      remember(user) if params[:remember_me] == '1'
      flash[:success] = "Welcome, #{user.firstname}!"
      redirect_to mng_root_path
    else
      flash[:warning] = 'Incorrect username and/or password'
      redirect_to login_path
    end
  end

  def destroy
    sign_out
    flash[:success] = 'Bye!'
    redirect_to root_path
  end
end
