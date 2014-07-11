class PicturesController < ApplicationController
  def show
    @pic = Picture.find_by({ :id => params[:id] })
  end

  def index
    @pictures = Picture.all
  end

  def new
  end

  def create
    # params = {"caption"=>"hi", "source"=>"there"}

    p = Picture.new
    p.caption = params[:caption]
    p.source = params[:source]
    p.save

    redirect_to("/picture_details/#{p.id}")
  end
end












