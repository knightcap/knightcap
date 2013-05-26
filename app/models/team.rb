class Team < ActiveRecord::Base
  attr_accessible :name
  validates :name, :uniqueness => true, :presence => true
  
  has_many :feeds
  has_many :services
  
  has_many :teamsusers
  has_many :users, :through => :teamsusers
end
