class Usergroup < ActiveRecord::Base
  attr_accessible :name
  has_many :roles
  has_many :users, :through => :roles


  #has_and_belongs_to_many :users
end
