class Wish < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  named_scope :scoped_calendar_by_register_date, proc {|id, current_month, next_month|
    {
      :select => 'SUBSTRING(register_date, 1, 10) AS date',
      :conditions => ["users.login = ? AND wishes.register_date BETWEEN ? AND ?",
        id, current_month, next_month],
      :joins => "LEFT OUTER JOIN users ON users.id = wishes.user_id",
      :group => 'date'
    }
  }
end
