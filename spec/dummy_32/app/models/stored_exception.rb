# Only used for testing model errors
class StoredException < ActiveRecord::Base
  self.table_name = :error_messages


  def failure
    nil.foo
  end
end
