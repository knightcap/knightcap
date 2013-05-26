class Blist < ActiveRecord::Base
  attr_accessible :email
  belongs_to :service

end
