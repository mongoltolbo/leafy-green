class Createchats < ActiveRecord::Migration
  def change
  
     create_table :chats do |t|
     
      t.string :from
      t.string :to
      t.string :message
      t.datetime :sent
      t.integer :recd , :default => 0
      
      t.timestamps
    end
    
  end
end
