class Result < ActiveRecord::Base
  attr_accessible :comments, :done, :email, :score
  belongs_to :survey
end
