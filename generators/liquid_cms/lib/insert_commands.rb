require 'fileutils'

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
