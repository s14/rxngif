class PicturesController < ApplicationController
  def show
    @pic = Picture.find_by({ :id => params[:id] })
  end

  def index
    @pictures = Picture.all
  end

  def new
  end

  def edit
    @picture = Picture.find_by({ :id => params[:id] })
  end

  def create
    # params = {"caption"=>"hi", "source"=>"there"}

    p = Picture.new
    p.caption = params[:caption]
    p.source = params[:source]
    p.save

    redirect_to("/all_pictures", { :notice => "You successfully added a picture" })
  end

  def update
    p = Picture.find_by({ :id => params[:id] })
    p.caption = params[:caption]
    p.source = params[:source]
    p.save

    redirect_to("/picture_details/#{p.id}", { :notice => "You edited the picture" })
  end
end












