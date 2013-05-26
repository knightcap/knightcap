class Teamsuser < ActiveRecord::Base
  attr_accessible :role, :team_id, :user_id
  
  belongs_to :team
  belongs_to :user
end
