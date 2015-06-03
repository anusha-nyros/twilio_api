class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]
#before_filter :authenticate!

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @userid = params[:id]
    @message = Message.new
    @countries = Country.all    
    render :layout => false
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    #begin
    #@user = User.find(params[:message][:user_id])
    @code = params[:message][:code]
    @phone = @code.to_s + params[:message][:mob_num]
    @body =params[:message][:body]
    @message = Message.new(message_params)
    
    client = Twilio::REST::Client.new(TWILIO_CONFIG["sid"], TWILIO_CONFIG["token"])
    client.account.messages.create(:from => TWILIO_CONFIG["from"], :to => @phone, :body => "#{@body})")
    
    respond_to do |format|
      if @message.save
        format.html { redirect_to users_path, notice: 'Your Message has sent successfully' }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
    #rescue
    #    redirect_to users_path, notice: "Mobile must be verified in this app twilio account"
    #end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:mob_num, :body, :user_id, :code)
    end
end
