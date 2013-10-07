require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    results = DBConnection.execute("SELECT * FROM #{table_name}")
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{table_name}
      WHERE id = ?
    SQL

    return nil if result.empty?
    self.new(result[0])
  end

  def create
    attr_values = attribute_values

    attribute_line = self.class.attributes.join(',')
    insert_line = (['?'] * self.class.attributes.length).join(',')

    DBConnection.execute(<<-SQL, *attr_values)
      INSERT INTO #{self.class.table_name}(#{attribute_line})
      VALUES (#{insert_line})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    attr_values = attribute_values

    set_line = self.class.attributes.map do |attribute|
      "#{attribute} = ?"
    end.join(',')

    DBConnection.execute(<<-SQL, *attr_values)
    UPDATE #{self.class.table_name}
    SET #{set_line}
    WHERE id = #{self.id}
    SQL
  end


  def save
    if self.class.find(self.id)
      update
    else
      create
    end
  end

  def attribute_values
    attr_values = []
    self.class.attributes.each do |attribute|
      attr_values << self.send(attribute)
    end
    attr_values
  end
end
