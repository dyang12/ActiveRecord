require_relative './db_connection'

module Searchable
  def where(params)
    args = params.keys.map do |attribute|
      "#{attribute} = ?"
    end.join(' AND ')

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT *
      FROM #{self.table_name}
      WHERE #{args}
    SQL

    self.parse_all(results)
  end
end