class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :question_set
end
