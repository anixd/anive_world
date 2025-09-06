class Forge::BaseController < ApplicationController
  include Paginatable

  before_action :require_authentication

  layout "forge"
end
