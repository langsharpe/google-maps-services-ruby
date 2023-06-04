module GoogleMapsService
  # GoogleMapsService gem version
  VERSION = "0.6.3"

  # Current operating system
  # @private
  OS_VERSION = begin
    if RUBY_PLATFORM.match?(/mswin|win32|mingw|bccwin|cygwin/)
      `ver`.sub(/\s*\[Version\s*/, "/").sub("]", "").strip
    elsif RUBY_PLATFORM.match?(/darwin/i)
      "Mac OS X/#{`sw_vers -productVersion`}".strip
    elsif RUBY_PLATFORM == "java"
      require "java"
      name = java.lang.System.getProperty("os.name")
      version = java.lang.System.getProperty("os.version")
      "#{name}/#{version}".strip
    else
      `uname -sr`.sub(" ", "/").strip
    end
  rescue
    RUBY_PLATFORM
  end
end
