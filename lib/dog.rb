class Dog

    attr_accessor :id, :name, :breed

    def initialize (id: nil, name:, breed: )
        @id = id
        @name = name 
        @breed = breed
    end

# Class method on Dog that will execute the correct SQL to create a dogs table.
    def self.create_table 
        sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

# Class method on `Dog` that will execute the correct SQL to drop a dogs table.
    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

# Given an instance of a dog, simply calling `save` will insert a new record into the database and return the instance.
    def save
        sql = <<-SQL 
    INSERT INTO dogs (name, breed)
    VALUES(?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

# This is a class method that should: 
# (1)Create a new row in the database 
# (2)Uses the #save method to save that dog to the database
# (3)Return a new instance of the `Dog` class/returns a new dog object
    def self.create (name:, breed:)
        dog = Dog.new(name: name, breed: breed) #1
        dog.save #(2)
        dog #(3)
    end

# Creates an instance with corresponding attribute values
    def self.new_from_db (row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

# This class method should return an array of `Dog` instances for every record in the `dogs` table.
    def self.all
        sql = <<-SQL
        SELECT * FROM dogs
        SQL
        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

# Returns an instance of dog that matches the name from the DB
    def self.find_by_name (name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
    end

# returns a new dog object by id
    def self.find (id)
        sql = <<-SQL
        SELECT * 
        FROM dogs 
        WHERE id = ?
        SQL
        self.new_from_db(DB[:conn].execute(sql, id).first)
    end
end
