require "purger/version"
require "ffi-rzmq"

class Purger
  #Singleton because we don't want to have lots of connections to the purge forwarder
  include Singleton
  attr_accessor :zmq_socket
  attr_reader :configured

  def initialize
    @configured = false
  end

  def config!(purger_host, purger_port) 
    return :already_configured if configured
    zmq_context = ZMQ::Context.new
    if zmq_context
      @zmq_socket = zmq_context.socket ZMQ::REQ
      rc = @zmq_socket.connect("tcp://#{purger_host}:#{purger_port}")
      if rc == 0
        @configured = true
        return nil
      else
        return :socket_connection_failed
      end
    else
      return :context_creation_failed
    end
  end

  def purge(pattern=".*")
    return :not_configured unless @configured
    @zmq_socket.send_string(pattern)
    response = ""
    @zmq_socket.receive_string response
    return nil
  rescue
    return :error
  end
end
