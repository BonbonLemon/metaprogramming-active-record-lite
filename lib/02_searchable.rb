require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...
    DBConnection.execute(<<-SQL)
    SQL
  end
end

class SQLObject
  # Mixin Searchable here...
end
