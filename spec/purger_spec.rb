require 'minitest/spec'
require 'minitest/autorun'
require './lib/purger'

describe Purger do
  after do
    instance = Purger.instance
    instance.instance_variable_set(:@zmq_socket, nil)
    instance.instance_variable_set(:@configured, false)
  end

  it "should not be configured by default" do
    Purger.instance.configured.must_equal false
  end

  it "should not be configured because the zmq context creation failed" do
    ZMQ::Context.stub :new, nil do
      Purger.instance.config!('localhost', 3128).must_equal :context_creation_failed
    end
  end

  it "should raise because zmq socket failed to connect" do
    socket_mock = MiniTest::Mock.new
    socket_mock.expect(:connect, -1, ["tcp://localhost:3128"])
    context_mock = MiniTest::Mock.new
    context_mock.expect(:socket, socket_mock, [ZMQ::REQ])
    ZMQ::Context.stub :new, context_mock do
      Purger.instance.config!('localhost', 3128).must_equal :socket_connection_failed
    end
  end

  it "should be configured" do
    socket_mock = MiniTest::Mock.new
    socket_mock.expect(:connect, 0, ["tcp://localhost:3128"])
    context_mock = MiniTest::Mock.new
    context_mock.expect(:socket, socket_mock, [ZMQ::REQ])
    ZMQ::Context.stub :new, context_mock do
      instance = Purger.instance
      instance.config!('localhost', 3128).must_be_nil
      instance.configured.must_equal true
    end
  end

  it "should not be reconfigured" do
    socket_mock = MiniTest::Mock.new
    socket_mock.expect(:connect, 0, ["tcp://localhost:3128"])
    context_mock = MiniTest::Mock.new
    context_mock.expect(:socket, socket_mock, [ZMQ::REQ])
    ZMQ::Context.stub :new, context_mock do
      instance = Purger.instance
      instance.config!('localhost', 3128)
    end

    Purger.instance.config!('bim',1234).must_equal :already_configured
  end

  it "should return :not_configured when the purge is called on a non configured object" do
    socket_mock = MiniTest::Mock.new
    socket_mock.expect(:connect, 0, ["tcp://localhost:3128"])
    socket_mock.expect(:send_string, nil, [".*bla"])
    socket_mock.expect(:receive_string, "ok", [""])
    context_mock = MiniTest::Mock.new
    context_mock.expect(:socket, socket_mock, [ZMQ::REQ])
    ZMQ::Context.stub :new, context_mock do
      instance = Purger.instance
    end

    Purger.instance.purge(".*bla").must_equal :not_configured
  end

  it "should return :error when the purge failed" do
    socket_mock = MiniTest::Mock.new
    socket_mock.expect(:connect, 0, ["tcp://localhost:3128"])
    socket_mock.expect(:send_string, nil, [".*bla"])
    context_mock = MiniTest::Mock.new
    context_mock.expect(:socket, socket_mock, [ZMQ::REQ])
    ZMQ::Context.stub :new, context_mock do
      instance = Purger.instance
      instance.config!('localhost', 3128)
    end

    Purger.instance.purge(".*bla").must_equal :error
  end

  it "should return nil when the purge succeed" do
    socket_mock = MiniTest::Mock.new
    socket_mock.expect(:connect, 0, ["tcp://localhost:3128"])
    socket_mock.expect(:send_string, nil, [".*bla"])
    socket_mock.expect(:receive_string, "ok", [""])
    context_mock = MiniTest::Mock.new
    context_mock.expect(:socket, socket_mock, [ZMQ::REQ])
    ZMQ::Context.stub :new, context_mock do
      instance = Purger.instance
      instance.config!('localhost', 3128)
    end

    Purger.instance.purge(".*bla").must_be_nil
  end
end
