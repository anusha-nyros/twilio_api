class Message < ActiveRecord::Base

attr_accessor :code

    belongs_to :user
    
end
