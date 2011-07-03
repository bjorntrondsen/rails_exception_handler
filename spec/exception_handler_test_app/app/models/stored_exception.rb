# Only used for testing model errors
class StoredException < ActiveRecord::Base
  set_table_name :error_messages


  def failure
    nil.foo
  end
end
