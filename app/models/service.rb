class Service < ActiveRecord::Base
  attr_accessible :email_content, :name, :team_id
  
  validates :name, :presence => true
  validates :team, :presence => true
  
  belongs_to :team
  has_many :dlists
  has_many :blists

  has_many :surveys
  has_many :servicesusers
  has_many :users, :through => :servicesusers

end
