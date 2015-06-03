class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :verify_mobile]

  before_action :set_twilio, only: [:mobile_verification, :create_call, :handle_ivr_call, :twilio_client, :bulk_sms]
  before_action :get_countries, only: [:make_call, :make_an_ivr, :twilio_client]
  #before_filter :authenticate!, except: [:new, :create]
  skip_before_filter :verify_authenticity_token
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    params[:user][:phone] = params[:user][:country_code] + params[:user][:phone]
    @user = User.new(user_params)
        respond_to do |format|
         if @user.save
         #*********************2Factor Authentication************************************************
              session[:user_id] = @user.id
              authy = Authy::API.register_user(email: @user.email, cellphone: @user.phone, country_code: @user.country_code)
              @user.update_attributes(authy_id: authy.id)
         #*********************2Factor Authentication************************************************
              format.html { redirect_to users_path, notice: 'User was successfully created.' }
              format.json { render :show, status: :created, location: @user }
        else
              format.html { render :new }
              format.json { render json: @user.errors, status: :unprocessable_entity }
        end
        end
  end
   
  
  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
#*******************************************Verify Mobile**************************************************  
  def verify_mobile
    render :layout => false
  end 

  def mobile_verification
        phone = params[:user][:phone]
        @user = User.find_by_phone(phone)
        User.send_verification_code(@client, phone, @user.otp)
        render :layout => false
  end
  
  def final_verification
        user = User.find_by_phone_and_otp(params[:user][:phone], params[:user][:otp])
        respond_to do |format|
            if !user.nil?
                user.update_attributes(:verified => true)
                format.html { redirect_to users_path, notice: 'User was successfully updated.' }
            else
                format.html { redirect_to users_path, error: 'Invalid OTP' }
            end
        end
  end
  
 #*******************************************Verify Mobile**************************************************
 
 #*******************************************Voice Calling**************************************************
    def make_call
        render :layout => false
    end
    
     def create_call
       @code = params[:user][:code]
       @phone = @code.to_s + params[:user][:phone]
       begin
           @call = @client.account.calls.create(:from => TWILIO_CONFIG["from"], :to => @phone, :url => "#{root_url}connect")
           redirect_to users_path, notice: " A phone call will get to that #{@phone} number"
       rescue Exception => e
            redirect_to users_path, error: "#{e.message.inspect}"
       end
       
    end
    
    
     def connect
        response = Twilio::TwiML::Response.new do |r|
            r.Say 'Welcome To Technology World', :voice => 'alice'
            r.Gather :action=>"/process_gather", :method=>"GET" do |g|
               g.Say   "Please press 1 to know today's time"
            end
            r.Say "We didn't receive any input. Goodbye!"
        end
        render text: response.text and return
     end
     
     def process_gather
          redirect '/connect' unless params['Digits'] == '1'
          Twilio::TwiML::Response.new do |r|
            r.Say 'The Time is: #{Time.now}'
            r.Say 'Thank you Listening. Goodbye.'
          end
     end
 #*******************************************Calling**************************************************

 #*******************************************Connect APPS**************************************************
  def connect_twilio
        redirect_to "https://www.twilio.com/authorize/CNfd350e0a62a611b15430243b3d155401"
  end
  
  def authorize
    @acid = params["AccountSid"]
    client = Twilio::REST::Client.new(params["AccountSid"], TWILIO_CONFIG["token"])
    @urls = client.account.authorized_connect_apps.list
  end
 
 #*******************************************Connect APPS**************************************************
  #*******************************************Make an IVR**************************************************
 def make_an_ivr
        render :layout => false
 end
 
 def handle_ivr_call
        @code = params[:code]
        @phone = @code.to_s + params[:phone]
        begin
            @client.account.calls.create(:from => TWILIO_CONFIG["from"], :to => @phone, :url => "#{root_url}initial_listen")
            respond_to users_path, notice: "A phone call will get to the number #{@phone.inspect} "
        rescue Exception => e
            respond_to users_path, error: "Something Went Wrong: #{e.message.inspect} "
        end    
  end
  
  def initial_listen
        response = Twilio::TwiML::Response.new do |r|
           r.Gather :action=>"/input", :numDigits=>"1" do |g|
             g.Say "Welcome to Nyros Technologies."
             g.Say "For Office hours, press 1"
             g.Say "To speak to any employee, press 2."
           end
            #If customer doesn't input anything, prompt and try again.
           r.Say "Sorry, I didn't get your response."
           redirect '/initial_listen' unless params['Digits'] == '1'
        end
        render text: response and return
  end   
  
  def input
        fromuser = params['Digits'];
        response = Twilio::TwiML::Response.new do |r|
            case ( fromuser)
                when "1"
                  r.Say "Our Office hours are 8 AM to 8 PM everyday."
                when "2"
                  r.Gather :action=> "/employees", :numDigits=>"1" do |g|
                    g.Say "Please enter any number to talk to the employee."
                    g.Say "Press 0 to return to the main menu."
                  end
                  r.Say "Sorry, I didn't get your response."
                  r.Redirect :method=>"GET", :action => "/input?Digits=2"
                  redirect "/input?Digits=2", :method=>"GET" unless params['Digits'] == '1'
                else
                  r.Say "Sorry, I can't do that yet."
                  redirect '/initial_listen' unless params['Digits'] == '1'
                end
         end
         render text: response.text and return
  end
  
  def employees
    fromuser = params['Digits'];
    response = Twilio::TwiML::Response.new do |r|
       case (fromuser)
        when "0"
          r.Say "Taking you back to the main menu"
          redirect '/initial_listen'
        else
          if( !INPUT_NAMES["Array"][fromuser.to_i].nil? )
            employee = INPUT_NAMES["Array"][fromuser.to_i]
            r.Say "Connecting you to #{employee['firstname']}"
            r.Dial "#{employee['phone']}"
          else
            r.Say "Sorry, No employee found."
            r.Redirect "/input?Digits=2"
            redirect "/input?Digits=2"
          end
        end
     end
     render text: response.text and return        
  end
   #*******************************************Make an IVR**************************************************
   
#*******************************************Twilio Client**************************************************
    def twilio_client
        @client.account.applications.list.each do |app|
                @app_id = app.sid
        end
        @default_client  = "Anusha"
        capability = Twilio::Util::Capability.new(TWILIO_CONFIG["sid"], TWILIO_CONFIG["token"])
        capability.allow_client_outgoing @app_id
        capability.allow_client_incoming @default_client
        @token = capability.generate(expires=600)
   end
    
   def client_incoming_call
        number = params[:Code] + params[:PhoneNumber]
        response = Twilio::TwiML::Response.new do |r|
             r.Dial :callerId => "+918897524475" do |d|
            # Test to see if the PhoneNumber is a number, or a Client ID. In
            # this case, we detect a Client ID by the presence of non-numbers
            # in the PhoneNumber parameter.
            if /^[\d\+\-\(\) ]+$/.match(number)
                d.Number(CGI::escapeHTML number)
            else
                d.Client @default_client
            end
        end
        end
    render :text => response.text and return
   end
#******************************************Twilio Client**************************************************

 #******************************************Bulk SMS**************************************************
  def bulk_sms
        @arr = User.all.map {|x| [x.name, x.phone]}
        @arr.each do |arr|
            begin
                @client.account.messages.create(:from => TWILIO_CONFIG["from"], :to => arr[1], :body => "Hello #{arr[0]}")
                redirect_to users_path, notice: "Bulk SMS Succeded"
            rescue Exception => e
                redirect_to users_path, error: "Something Went Wrong: #{e.message.inspect}"
            end
        end
        
  end
 
 #******************************************Bulk SMS**************************************************
 
  private
    # Use callbacks to share common setup or constraints between actions.
    
    def get_countries
        @countries = Country.all
    end

    def set_twilio
        @client = Twilio::REST::Client.new(TWILIO_CONFIG["sid"], TWILIO_CONFIG["token"])
    end
    
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :phone, :password, :country_code, :authy_id)
    end
end
