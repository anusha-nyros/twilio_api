
class User < ActiveRecord::Base
    has_secure_password

    validates :phone, :presence => true, :format => /([\+91][0-9][10])/
    validates :name, :presence => true
    validates :email, :presence => true, :uniqueness => true, :format => /([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+/
   
    has_many :messages   
    before_create :get_verification_code
    
    def get_verification_code
        self.otp = self.otp || rand(999999).to_s
    end
    
    def self.send_verification_code(client, phone, otp)
        client.account.messages.create(:from => TWILIO_CONFIG["from"], :to => phone, :body => "Please enter this OTP (#{otp})")
    end
end
