require 'fileutils'

Rails::Generator::Commands::Base.class_eval do
  def file_contains?(relative_destination, line)
    File.read(destination_path(relative_destination)).include?(line)
  end
end

Rails::Generator::Commands::Create.class_eval do
  def copy_files(base, source)
    logger.copy "Copying '#{source}' to '#{base}'"
    FileUtils.cp_r File.join(source_root, base, source), File.join(destination_root, base)
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
