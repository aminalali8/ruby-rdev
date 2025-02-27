#!/usr/bin/env ruby

require 'fileutils'
require 'listen'

class PermissionsManager
  def initialize(root_path)
    @root_path = root_path
    @listener = nil
  end

  def fix_permissions
    puts "\nStarting permissions fix..."
    puts "Current directory: #{Dir.pwd}"
    puts "Target directory: #{@root_path}"
    
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
        system("chmod 777 #{path.shellescape}")
        puts "Set directory permissions for: #{path}"
      else
        system("chmod 666 #{path.shellescape}")
        puts "Set file permissions for: #{path}"
      end
    rescue => e
      puts "Error processing #{path}: #{e.message}"
      puts e.backtrace.join("\n")
    end
  end
end

# Run if called directly
if __FILE__ == $0
  watcher = PermissionsManager.new(File.expand_path('.'))
  watcher.fix_permissions
  watcher.start_watcher
  
  begin
    sleep
  rescue Interrupt
    puts "\nStopping watcher..."
    watcher.stop_watcher
  end
end 