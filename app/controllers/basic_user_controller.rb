class BasicUserController < ApplicationController
  before_filter :authenticate_user!
end