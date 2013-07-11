require 'socket'

class Server
  attr_reader :pid

  def initialize
    @reader, @writer = Socket.pair(:UNIX, :DGRAM, 0)

    @pid = fork do
      @writer.close
      Client.new(@reader)
    end

    Signal.trap(:INT) do
      @writer.close;
      puts "Exiting Server"
      exit
    end

    puts "Process created: #{@pid}"
    @reader.close

    5.times do
      say "Hello"
    end

    Process.waitpid pid
  end

  def say message
    @writer.puts message
  end
end

class Client
  def initialize reader
    @reader = reader;

    Signal.trap(:INT) do
      @reader.close;
      puts "Exiting Client"
      exit
    end

    run
  end

  def run
    while( (msg = @reader.gets) != nil)
      puts "Client: #{msg}"
      sleep 2
    end
  end
end



s = Server.new()

