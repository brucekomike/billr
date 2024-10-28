require 'sqlite3'
require 'optparse'

db = SQLite3::Database.new "Billr.db"
db.execute <<-SQL
  create table if not exists configs (
    name varchar(30) UNIQUE,
    description varchar(255),
    value int,
    created_time datetime,
    updated_time datetime
  );
SQL
db.execute <<-SQL
  create table if not exists bills (
    name varchar(30) UNIQUE,
    description varchat(255),
    start_at float,
    now_is float,
    created_time datetime,
    updated_time datetime
  );
SQL

class DBsousaku
  def initialize(db, table)
    @db = db
    @table = table
  end

  def write(contents)
    values = ""
    contents.each do |content|
      values += '"'
      values += content.to_s
      values += "\","
    end
    values = values[0...-1]
    @db.execute <<-EOS
      insert or replace into #{@table} VALUES (#{values});
    EOS
  end
  def read()
    values = @db.execute("select * from #{@table}")
    return values
  end
end

def input(prompt ='')
    print prompt
    return gets[0...-1]
end

config = DBsousaku.new(db, "configs")

config.write(["test", "test description", 0, Time.now, Time.now ])

bills = DBsousaku.new(db, "bills")

options = {}
OptionParser.new do |parser|
  parser.banner = "Usage: billr.rb [options] <values>"

  parser.on("-a INVEST_NAME", "--add INVEST_NAME",
            "Add a invest to the database.") do |invest|
    invested = input("invested value:")
    bills.write([invest.to_s, input("description:"), invested, invested, Time.now, Time.now])
  end
  parser.on("-c NAME", "--consume NAME", "Consume a invest.") do |c|
    values = bills.read()
    values do |row|
      puts row
      puts row[0]
    end
  end    
  parser.on("-s", "--show", "Show tables.") do |s|
    values = bills.read()
    values do |row|
      p row
    end
  end
  
end.parse!

