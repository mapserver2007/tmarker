class Recommendation < ActiveRecord::Base
  validates_format_of :item_id, :with => /\d/
  validates_length_of :item_id, :is => 13
end
