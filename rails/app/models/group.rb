class Group < ActiveRecord::Base
  has_many :items
  has_many :wishes

  named_scope :scoped_category_count, proc {|id, table_name|
    {
      :select => 'groups.id, groups.product_name, groups.product_icon, count(groups.id) as count',
      :conditions => ['users.login = ?', id],
      :group => 'group_id',
      :order => 'groups.id',
      :joins => "LEFT OUTER JOIN #{table_name} ON groups.id = #{table_name}.group_id LEFT OUTER JOIN users ON users.id = #{table_name}.user_id"
    }
  }
end