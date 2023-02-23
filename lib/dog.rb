class Dog

    attr_accessor :name, :breed, :id

    # Creation of the constructor

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

      #We create a class method that will handle the query of table creation
    def self.create_table
        sql = <<-SQL

        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            breed TEXT NOT NULL
        )
        SQL

        DB[:conn].execute(sql)
      
    end
    # Method for dropping table if exists in db

    def self.drop_table
        sql= <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end
   
    def save

        
        # We create a method that will handle the saving of the object
        sql = <<-SQL
        INSERT INTO dogs(name, breed) VALUES(?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)

        #Get the dog id from db and save it to the ruby instance
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        
        #Return the ruby instance
        self
        
    end

    def self.create(name:, breed:)
        # We create a method that will handle the creation of a row in database
        dog = Dog.new(name: name, breed:breed)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed:row[2])
    end
    def self.all

        sql = <<-SQL
        SELECT * FROM dogs
        SQL

        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ? LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end
  
end
