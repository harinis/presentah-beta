class AddInterestedUsersTable < ActiveRecord::Migration
    def self.up
        create_table :interested_users do |t|
            t.string :email
        end
    end

    def self.down
        drop_table :interested_users
    end
end
