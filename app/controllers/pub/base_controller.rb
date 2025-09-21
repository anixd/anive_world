# frozen_string_literal: true

class Pub::BaseController < ApplicationController
  include Paginatable

  layout "pub"
end
