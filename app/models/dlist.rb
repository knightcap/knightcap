class Dlist < ActiveRecord::Base
  attr_accessible :email
  belongs_to :service
  #has_and_belongs_to_many :emails
  
  #has_many :dlistsemails
  #has_many :emails, :through => :dlistsemails
end
