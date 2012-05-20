class Item < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  named_scope :scoped_category_list, proc {|id|
    {
      :conditions => ['users.login = ?', id],
      :group => 'group_id',
      :include => [:group, :user]
    }
  }

  named_scope :scoped_total_cost_by_date, proc {|id, date|
    {
      :select => 'items.id, SUM(items.item_price * items.item_count) AS total_cost',
      :conditions => ['users.login = ? AND items.register_date > ?', id, date],
      :joins => 'LEFT OUTER JOIN users ON users.id = items.user_id'
    }
  }

  named_scope :scoped_calendar_by_register_date, proc {|id, current_month, next_month|
    {
      :select => 'SUBSTRING(register_date, 1, 10) AS date',
      :conditions => ["users.login = ? AND items.register_date BETWEEN ? AND ?",
        id, current_month, next_month],
      :joins => "LEFT OUTER JOIN users ON users.id = items.user_id",
      :group => 'date'
    }
  }

  named_scope :scoped_reference_myself_by_jancode, proc {|id, jancode|
    {
      :conditions => ['items.jancode = ? AND users.login = ?', jancode, id],
      :include => :user
    }
  }

  named_scope :scoped_reference_user_by_jancode, proc {|jancode|
    {
      :conditions => ['items.jancode = ? AND items.open = ?', jancode, true],
      :include => :user
    }
  }
end