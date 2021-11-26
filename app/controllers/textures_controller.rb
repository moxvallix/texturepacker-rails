class TexturesController < ApplicationController
  before_action :set_texture, only: %i[ show edit update destroy ]

  # GET /textures or /textures.json
  def index
    @textures = Texture.all
  end

  # GET /textures/1 or /textures/1.json
  def show
  end

  # GET /textures/new
  def new
    @texture = Texture.new
  end

  # GET /textures/1/edit
  def edit
  end

  # POST /textures or /textures.json
  def create
    @texture = Texture.new(texture_params)

    respond_to do |format|
      if @texture.save
        format.html { redirect_to @texture, notice: "Texture was successfully created." }
        format.json { render :show, status: :created, location: @texture }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @texture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /textures/1 or /textures/1.json
  def update
    respond_to do |format|
      if @texture.update(texture_params)
        format.html { redirect_to @texture, notice: "Texture was successfully updated." }
        format.json { render :show, status: :ok, location: @texture }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @texture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /textures/1 or /textures/1.json
  def destroy
    @texture.destroy
    respond_to do |format|
      format.html { redirect_to textures_url, notice: "Texture was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_texture
      @texture = Texture.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def texture_params
      params.require(:texture).permit(:uid, :name, :origin)
    end
end
