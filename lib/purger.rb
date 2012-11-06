require "purger/version"
require "ffi-rzmq"
require "singleton"
require "timeout"

class Purger
  #Singleton because we don't want to have lots of connections to the purge forwarder
  include Singleton
  attr_reader :zmq_context
  attr_reader :configured

  def initialize
    @configured = false
    @zmq_context = ZMQ::Context.new
    @zmq_socket = zmq_context.socket ZMQ::REQ if @zmq_context
  end

  def config!(purger_host, purger_port) 
    return :already_configured if configured
    if @zmq_context
      rc = nil
      Timeout::timeout(5) {
        rc = @zmq_socket.connect("tcp://#{purger_host}:#{purger_port}")
      }
      if rc == 0
        @configured = true
        return nil
      else
        return :socket_connection_failed
      end
    else
      return :context_creation_failed
    end
  rescue Timeout::Error
    return :socket_connect_timeout
  end

  def purge(pattern=".*")
    return :not_configured unless @configured
    @zmq_socket.send_string(pattern)
    response = ""
    @zmq_socket.recv_string response
    return nil
  rescue
    return :error
  end
end
