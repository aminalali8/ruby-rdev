#!/usr/bin/env ruby

require 'fileutils'
require 'listen'
require 'etc'

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
    
    # Add debug info about current process
    puts "Process running as: #{Process.uid}:#{Process.gid}"
    
    begin
      @app_user = Etc.getpwnam('appuser')
      @app_uid = @app_user.uid
      @app_gid = @app_user.gid
      puts "Found appuser with uid:gid = #{@app_uid}:#{@app_gid}"
    rescue => e
      puts "Error getting appuser info: #{e.message}"
      # Fallback to 1000:1000
      @app_uid = 1000
      @app_gid = 1000
      puts "Falling back to uid:gid = #{@app_uid}:#{@app_gid}"
    end
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
      current_stat = File.stat(path)
      puts "\nProcessing: #{path}"
      puts "Current ownership: #{current_stat.uid}:#{current_stat.gid}"
      puts "Current mode: #{current_stat.mode.to_s(8)}"
      
      # Force ownership to 1000:1000
      system("chown -h 1000:1000 #{path.shellescape}")
      
      if File.directory?(path)
        system("chmod 755 #{path.shellescape}")
        new_stat = File.stat(path)
        puts "Updated directory to #{new_stat.mode.to_s(8)} 1000:1000"
      else
        system("chmod 644 #{path.shellescape}")
        new_stat = File.stat(path)
        puts "Updated file to #{new_stat.mode.to_s(8)} 1000:1000"
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