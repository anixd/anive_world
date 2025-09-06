class Forge::BaseController < ApplicationController
  before_action :require_authentication

  layout "forge"
end
