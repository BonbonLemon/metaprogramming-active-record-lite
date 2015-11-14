require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  attr_accessor :table_name

  def self.columns
    # ...
    results = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    results.first.map { |col| col.to_sym}
  end

  def self.finalize!
    self.columns.each do |column|
      define_method "#{column}" do
        attributes[column]
      end

      define_method "#{column}=" do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.to_s.tableize
  end

  def self.all
    # ...
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL

    self.parse_all(results)
  end

  def self.parse_all(results)
    # ...
    results.map { |hash| self.new(hash) }
  end

  def self.find(id)
    # ...
    result = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = #{id}
      LIMIT 1
    SQL

    return nil if result.empty?
    self.new(result.first)
  end

  def initialize(params = {})
    # ...
    params.each do |attr_name, val|
      if self.class.columns.include?(attr_name.to_sym)
        self.send("#{attr_name}=", val)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    self.class.columns.map { |column| self.send(column) }
  end

  def insert
    # ...
    col_names = self.class.columns.join(', ')
    question_marks = ['?'] * self.class.columns.count
    question_marks = question_marks.join(', ')

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    set_data = self.class.columns.map {|column| "#{column} = ?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_data}
      WHERE
        id = ?
    SQL
  end

  def save
    # ...
    if id.nil?
      insert
    else
      update
    end
  end
end
