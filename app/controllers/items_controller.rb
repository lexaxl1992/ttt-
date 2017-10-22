class ItemsController < ApplicationController
  def show
    @item = Item[params[:id]]
    @galleryData = []
    for imageset in @item.imagesets
      unless imageset.photoUrl.nil?
        @galleryData.push({
          "src": imageset.photoUrl,
          "w": imageset.photoWidth,
          "h": imageset.photoHeight,
          "title": imageset.photoCaption,
        })
      end
      unless imageset.pictureUrl.nil?
        @galleryData.push({
          "src": imageset.pictureUrl,
          "w": imageset.pictureWidth,
          "h": imageset.pictureHeight,
          "title": imageset.pictureCaption,
        })
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def new
    @windowId = "Ox"+Digest::CRC32.hexdigest(Random.rand(1..10000).to_s)
    respond_to do |format|
      format.js
    end
  end

  def edit
    @windowId = "Ox"+Digest::CRC32.hexdigest(Random.rand(1..10000).to_s)
    @item = Item[params[:id]]
    respond_to do |format|
      format.js
    end
  end

  def create
    lambda = params[:item].merge({"name": params[:item][:name].mb_chars.upcase})
    item_params = lambda
    # Сохранение загруженной миниатюры
    unless item_params[:thumbnail].nil?
      new_fileName = Digest::CRC32.hexdigest(item_params[:name])+".png"
      uploaded_file = item_params[:thumbnail]
      File.open(Rails.root.join('public', 'uploads', 'items', 'thumbs', new_fileName), 'wb') do |file|
        file.write(uploaded_file.read)
      end
      # и запись пути к ней в базу данных
      lambda = item_params.merge({"thumbnail": "/uploads/items/thumbs/"+new_fileName})
    end

    @item = Item.create(lambda)
    @item.update(category: Category[params[:categoryId]])

    unless params[:imagesets].nil?
      uid = 0
      for imageset_id in params[:imagesets]
        imageset = Imageset[imageset_id]
        imageset.update(item: @item)
        unless imageset.photoUrl.nil?
          imageset.update(photoUid: uid)
          uid += 1
        end
        unless imageset.pictureUrl.nil?
          imageset.update(pictudeUid: uid)
          uid += 1
        end
      end
    end

    respond_to do |format|
      if @item.save
        format.js
      else
        format.html {render action "new", notice:$custom_error_msg}
      end
    end
  end

  def update
    lambda = params[:item].merge({"name": params[:item][:name].mb_chars.upcase})
    item_params = lambda
    # Сохранение загруженной миниатюры
    unless item_params[:thumbnail].nil?
      new_fileName = Digest::CRC32.hexdigest(params[:itemId])+".png"
      uploaded_file = item_params[:thumbnail]
      File.open(Rails.root.join('public', 'uploads', 'items', 'thumbs', new_fileName), 'wb') do |file|
        file.write(uploaded_file.read)
      end
      # и запись пути к ней в базу данных
      lambda = item_params.merge({"thumbnail": "/uploads/items/thumbs/"+new_fileName})
    end

    @item = Item[params[:itemId]]
    @item.update(lambda)

    unless params[:imagesets].nil?
      uid = 0
      for imageset_id in params[:imagesets]
        imageset = Imageset[imageset_id]
        imageset.update(item: @item)
        unless imageset.photoUrl.nil?
          imageset.update(photoUid: uid)
          uid += 1
        end
        unless imageset.pictureUrl.nil?
          imageset.update(pictureUid: uid)
          uid += 1
        end
      end
    end

    respond_to do |format|
      if @item.save
        format.js
      else
        format.js {render "error"}
      end
    end
  end

  def destroy
    @item_id = params[:id]
    @item = Item[@item_id]
    @categoryIndex = @item.category.index
    @item.delete
    respond_to do |format|
      if @item.delete
        format.js
      else
        format.js {render "error"}
      end
    end
  end
  def update_order
    unless params[:categories_order].nil?
      i = 0; params[:categories_order].each do |id|
        Category[id].update("position": i)
        i += 1
      end
    end
    unless params[:items_order].nil?
      i = 0; params[:items_order].each do |id|
        Item[id].update("position": i)
        i += 1
      end
    end
  end
end
