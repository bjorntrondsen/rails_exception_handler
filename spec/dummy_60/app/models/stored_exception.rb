# Only used for testing model errors
class StoredException < ApplicationRecord
  self.table_name = :error_messages

  def failure
    nil.foo
  end
end
