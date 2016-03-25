require 'yaml'
require 'active_record'

class DatabaseAlreadyExists < StandardError; end

class Database
  class << self
    def setup
      setup_config
      configuration = ActiveRecord::Base.configurations[:test]
      begin
        ActiveRecord::Tasks::SQLiteDatabaseTasks.new(configuration).create
      rescue DatabaseAlreadyExists
        $stderr.puts "#{configuration['database']} already exists"
      end
    end

    def reset
      setup_config
      establish_connection
      connection = ActiveRecord::Base.connection
      create_resource_table(connection, :men)
      create_resource_table(connection, :users)
    end

    def establish_connection
      setup_config
      ActiveRecord::Base.establish_connection(
        ActiveRecord::Base.configurations[:test])
    end

    private

    def create_resource_table(connection, name)
      connection.drop_table(name) if connection.table_exists?(name)
      connection.create_table name.to_s, force: :cascade do |t|
        t.string 'email',                  default: ''
        t.string 'image',                  default: '', null: false
        t.string 'encrypted_password',     default: '', null: false
        t.string 'reset_password_token'
        t.datetime 'reset_password_sent_at'
        t.datetime 'remember_created_at'
        t.integer 'sign_in_count',          default: 0,  null: false
        t.integer 'admin',                  default: 0,  null: false
        t.integer 'operating_thetan',       default: 0,  null: false
        t.string 'height'
        t.datetime 'current_sign_in_at'
        t.datetime 'last_sign_in_at'
        t.string 'current_sign_in_ip'
        t.string 'last_sign_in_ip'
        t.datetime 'created_at'
        t.datetime 'updated_at'
        t.string 'confirmation_token'
        t.datetime 'confirmed_at'
        t.datetime 'confirmation_sent_at'
        t.string 'unconfirmed_email' # Only if using reconfirmable
        t.string 'provider',               default: '', null: false
        t.string 'uid',                    default: '', null: false
        t.string 'nickname',               default: '', null: false
        t.string 'name',                   default: '', null: false
        t.string 'favorite_color',         default: '', null: false
        t.text 'tokens'
      end
    end

    def setup_config
      configuration = config('test')
      ActiveRecord::Base.configurations[:test] = configuration
    end

    def config(env)
      YAML.load_file(File.expand_path('../../config/database.yml', __FILE__))[env]
    end
  end
end
