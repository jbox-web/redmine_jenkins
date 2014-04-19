class JenkinsQueryFilter
  unloadable

  attr_accessor :name, :available_values, :db_table, :db_field

  def initialize(name, available_values, db_table, db_field)
    self.name = name
    self.available_values = available_values
    self.db_table = db_table
    self.db_field = db_field
  end
end
