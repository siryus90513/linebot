class KeywordMapingsController < ApplicationController
  before_action :set_keyword_maping, only: %i[ show edit update destroy ]

  # GET /keyword_mapings or /keyword_mapings.json
  def index
    @keyword_mapings = KeywordMaping.all
  end

  # GET /keyword_mapings/1 or /keyword_mapings/1.json
  def show
  end

  # GET /keyword_mapings/new
  def new
    @keyword_maping = KeywordMaping.new
  end

  # GET /keyword_mapings/1/edit
  def edit
  end

  # POST /keyword_mapings or /keyword_mapings.json
  def create
    @keyword_maping = KeywordMaping.new(keyword_maping_params)

    respond_to do |format|
      if @keyword_maping.save
        format.html { redirect_to @keyword_maping, notice: "Keyword maping was successfully created." }
        format.json { render :show, status: :created, location: @keyword_maping }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @keyword_maping.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keyword_mapings/1 or /keyword_mapings/1.json
  def update
    respond_to do |format|
      if @keyword_maping.update(keyword_maping_params)
        format.html { redirect_to @keyword_maping, notice: "Keyword maping was successfully updated." }
        format.json { render :show, status: :ok, location: @keyword_maping }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @keyword_maping.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keyword_mapings/1 or /keyword_mapings/1.json
  def destroy
    @keyword_maping.destroy
    respond_to do |format|
      format.html { redirect_to keyword_mapings_url, notice: "Keyword maping was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keyword_maping
      @keyword_maping = KeywordMaping.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def keyword_maping_params
      params.require(:keyword_maping).permit(:channel_id, :keyword, :message)
    end
end
