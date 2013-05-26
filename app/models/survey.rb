class Survey < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :service
  has_many :results
end
