class Forge::BaseController < ApplicationController
  before_action :require_authentication
end
