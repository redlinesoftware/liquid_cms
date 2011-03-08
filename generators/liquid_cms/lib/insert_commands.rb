require 'fileutils'

Rails::Generator::Commands::Create.class_eval do
  def copy_files(base, source, template_path = nil)
    logger.copy "Copying '#{source}' to '#{base}'"
    FileUtils.cp_r File.join(source_root, template_path || '', base, source), File.join(destination_root, base)
  end

  # override the migration template method so that we can continue the generation and not fail if the migration already exists
  def migration_template(relative_source, relative_destination, template_options = {})
    migration_directory relative_destination
    migration_file_name = template_options[:migration_file_name] || file_name

    # override the default behavior of halting the generator if the file is found and instead provide a warning for the migration and continue
    if migration_exists?(migration_file_name)
      puts "Another migration is already named #{migration_file_name}: #{existing_migrations(migration_file_name).first}... skipping"
      return
    end

    template(relative_source, "#{relative_destination}/#{next_migration_string}_#{migration_file_name}.rb", template_options)
  end
end

Rails::Generator::Commands::Destroy.class_eval do
  def copy_files(base, source)
    logger.copy "Removing '#{source}' from '#{base}'"
    FileUtils.rm_rf File.join(destination_root, base, source)
  end
end

Rails::Generator::Commands::List.class_eval do
  def copy_files(base, source)
    logger.copy "Copying '#{source}' to '#{base}'"
  end
end
