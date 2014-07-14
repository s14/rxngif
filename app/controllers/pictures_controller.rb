class PicturesController < ApplicationController
  def show
    @pic = Picture.find_by({ :id => params[:id] })
  end

  def index
    @pictures = Picture.order("created_at DESC")
  end

  def new
    @picture = Picture.new
  end

  def edit
    @picture = Picture.find_by({ :id => params[:id] })
  end

  def create
    # params = {"caption"=>"hi", "source"=>"there"}

    @picture = Picture.new
    @picture.caption = params[:caption]
    @picture.source = params[:source]

    if @picture.save == true
      redirect_to("/all_pictures", { :notice => "You successfully added a picture" })
    else
      render('new')
    end
  end

  def update
    @picture = Picture.find_by({ :id => params[:id] })
    @picture.caption = params[:caption]
    @picture.source = params[:source]

    if @picture.save == true
      redirect_to("/picture_details/#{@picture.id}", { :notice => "You edited the picture" })
    else
      render('edit')
    end
  end
end
