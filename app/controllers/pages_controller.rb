class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]


  skip_before_action :authenticate_user!, only: %i[home about glossary healthcheck landing launch]

  def home; end

  def about; end

  def glossary; end

  def healthcheck; end

  def landing; end

  def launch; end
  
end
