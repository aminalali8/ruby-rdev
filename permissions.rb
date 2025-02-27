#!/usr/bin/env ruby

require 'fileutils'
require 'listen'

class PermissionsManager
  DEFAULT_FILE_MODE = 0644    # rw-r--r--
  DEFAULT_DIR_MODE = 0755     # rwxr-xr-x
  
  def self.fix_permissions(root_path = File.expand_path('.'))
    new(root_path).fix_permissions
  end

  def self.start_watcher(root_path = File.expand_path('.'))
    new(root_path).start_watcher
  end

  def initialize(root_path)
    @root_path = root_path
    @listener = nil
  end

  def fix_permissions
    puts "Fixing permissions in #{@root_path}..."
    
    Dir.glob("#{@root_path}/**/*", File::FNM_DOTMATCH).each do |path|
      next if path =~ /\/\.{1,2}$/  # Skip . and .. directories
      fix_path_permissions(path)
    end
    
    puts "Permissions update complete!"
  end

  def start_watcher
    return if @listener

    puts "Starting permission watcher for #{@root_path}..."
    
    @listener = Listen.to(@root_path) do |modified, added, _removed|
      (modified + added).each do |path|
        fix_path_permissions(path)
      end
    end

    @listener.start
    puts "Permission watcher started successfully!"
  end

  def stop_watcher
    if @listener
      @listener.stop
      @listener = nil
      puts "Permission watcher stopped."
    end
  end

  private

  def fix_path_permissions(path)
    begin
      if File.directory?(path)
        FileUtils.chmod(DEFAULT_DIR_MODE, path)
        puts "Set directory permissions for: #{path}"
      else
        FileUtils.chmod(DEFAULT_FILE_MODE, path)
        puts "Set file permissions for: #{path}"
      end
    rescue => e
      puts "Error setting permissions for #{path}: #{e.message}"
    end
  end
end

# Run if called directly
if __FILE__ == $0
  watcher = PermissionsManager.new(File.expand_path('.'))
  watcher.fix_permissions  # Fix all permissions initially
  watcher.start_watcher   # Start watching for changes
  
  # Keep the script running
  begin
    sleep
  rescue Interrupt
    puts "\nStopping watcher..."
    watcher.stop_watcher
  end
end 