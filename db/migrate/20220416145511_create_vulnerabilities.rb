class CreateVulnerabilities < ActiveRecord::Migration[6.1]
  def change
    create_table :vulnerabilities do |t|
      t.string :port
      t.string :protocol
      t.string :state
      t.string :service
      t.bigint :check_id
      t.string :version
      t.string :reason
      t.string :product
      t.string :weakness
      t.string :risk
      t.string :recommandation
      t.integer :impact
      t.integer :likelihood
      t.integer :netrisk

      t.timestamps

      t.index ["check_id"], name: "index_vulnerabilities_on_check_id"

    end
  end
end
