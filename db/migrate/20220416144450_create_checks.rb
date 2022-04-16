class CreateChecks < ActiveRecord::Migration[6.1]
  def change
    create_table :checks do |t|
      t.string :ip
      t.string :hostname
      t.string :scandur
      t.integer :score
      t.bigint :user_id
      t.jsonb :fullresponse
      t.jsonb :attacksurface
      t.integer :domcheck_duration
      t.string :duration

      t.timestamps
    end
  end
end
