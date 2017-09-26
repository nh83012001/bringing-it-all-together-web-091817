class Dog
  attr_accessor :name, :breed, :id


  def initialize(name:, breed:, id:nil)
    #binding.pry
    @id = id
    @name = name
    @breed = breed
  end

 #class method. this is because we won't want to create a table every time we create a song.
  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id #makes it so we don't duplicate records
      self.update
    else
    sql =  <<-SQL
      INSERT INTO dogs (name,breed)
      values (?, ?)
    SQL
      DB[:conn].execute(sql, self.name, self.breed) #persist them to the database
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] #save id (row in sql database)
      self
    end
  end

  def self.create(hash)
    dog = Dog.new(hash) #creates class instance
    dog.save #saves to database
    dog #returns class instance
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    #binding.pry
    array = DB[:conn].execute(sql, id).flatten
    Dog.new(name: array[1], breed: array[2], id: array[0])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty? #true if info is in database and we create an instance
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed) #not in database so we create instance and row
    end
    dog
  end

  def self.new_from_db(dog_data)
    #binding.pry
    new_dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])  #creates class instance
    new_dog  # return the newly created instance
  end

  def self.find_by_name(name)#normally just doing by unique property
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    #binding.pry
    DB[:conn].execute(sql,name).map do |row|
      #binding.pry
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end



end
