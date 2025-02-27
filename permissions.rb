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

    puts "\n=== Starting File Watcher ==="
    puts "Watching directory: #{@root_path}"
    
    @listener = Listen.to(@root_path, force_polling: true, latency: 0.1) do |modified, added, removed|
      puts "\n=== Changes Detected ==="
      
      modified.each do |path|
        puts "Modified: #{path}"
        fix_path_permissions(path)
      end
      
      added.each do |path|
        puts "Added: #{path}"
        fix_path_permissions(path)
      end
      
      removed.each do |path|
        puts "Removed: #{path}"
      end
    end

    @listener.start
    puts "Watcher started successfully!"
    puts "Waiting for file changes..."
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
        puts ">>> Set directory permissions (777) for: #{path}"
      else
        system("chmod 666 #{path.shellescape}")
        puts ">>> Set file permissions (666) for: #{path}"
      end
    rescue => e
      puts "!!! Error processing #{path}: #{e.message}"
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
    puts "\nWatcher is running. Press Ctrl+C to stop."
    sleep
  rescue Interrupt
    puts "\nStopping watcher..."
    watcher.stop_watcher
  end
end 