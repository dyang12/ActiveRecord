require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    @other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_reader :other_class_name, :primary_key, :foreign_key

  def initialize(name, params)
    @other_class_name = params[:class_name] || name.to_s.camelcase
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || :"#{name}_id"
  end

  def type
    :belongs_to
  end
end

class HasManyAssocParams < AssocParams
  attr_reader :other_class_name, :primary_key, :foreign_key

  def initialize(name, params, self_class)
    @other_class_name = params[:class_name] || name.to_s.singularize.camelcase
    @primary_key = params[:primary_key] || @primary_key = :id
    @foreign_key = params[:foreign_key] || :"#{self_class.snake_case}_id"
  end

  def type
    :has_many
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    settings = BelongsToAssocParams.new(name, params)

    define_method(name.to_sym) do
      result = DBConnection.execute(<<-SQL, self.send(settings.foreign_key))
        SELECT *
        FROM #{settings.other_table}
        WHERE #{settings.primary_key} = ?
      SQL

      return nil if result.empty?
      settings.other_class.assoc_params[name.to_sym] =
            settings.other_class.new(result[0])
    end
  end

  def has_many(name, params = {})
    settings = HasManyAssocParams.new(name, params, self.class.to_s)

    define_method(name.to_sym) do
      results = DBConnection.execute(<<-SQL, self.send(settings.primary_key))
        SELECT *
        FROM #{settings.other_table}
        WHERE #{settings.foreign_key} = ?
      SQL

      settings.other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
    define_method(name.to_sym, assoc1, assoc2) do

      result = DBConnection.execute(<<-SQL)
      SELECT *
      FROM
      SQL

      return nil if result.empty?

    end
  end
end
