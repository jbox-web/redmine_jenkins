class JenkinsQueryFilter
  unloadable

  attr_accessor :name, :available_values, :db_table, :db_field

  def initialize(name, available_values, db_table, db_field)
    @name = name
    @available_values = available_values
    @db_table = db_table
    @db_field = db_field
  end
end
