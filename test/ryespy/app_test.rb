require 'logger'
require 'net/imap'


require_relative '../helper'

require_relative '../../lib/ryespy'


def start_and_stop_app(app)
  app_thread = Thread.new { app.start }
  
  sleep 1 # patience, patience; give app time to start
  
  app.stop
  
  app_thread.join(2)
  
  Thread.kill(app_thread)
end


describe Ryespy::App do
  
  describe "#initialize" do
    before do
      @app = Ryespy::App.new
    end
    
    it "defaults running to false" do
      @app.running.must_equal false
    end
  end
  
  describe "#configure" do
    before do
      @app = Ryespy::App.new
      
      @config = @app.config
    end
    
    describe "main" do
      before do
        @app.configure do |c|
          c.log_level           = 'ERROR'
          c.listener            = 'imap'
          c.polling_interval    = 13
          c.redis_url           = 'redis://127.0.0.1:6379/1'
          c.redis_ns_ryespy     = 'WithMyLittleEye!'
          c.redis_ns_notifiers  = 'LaLaLiLi-'
          c.notifiers           = [{ :sidekiq => 'redis://127.0.0.1:6379/2' }]
        end
      end
      
      it "configures log_level" do
        @config.log_level.must_equal 'ERROR'
      end
      
      it "sets logger level" do
        @app.instance_variable_get(:@logger).level.must_equal Logger::ERROR
      end
      
      it "configures listener" do
        @config.listener.must_equal 'imap'
      end
      
      it "configures polling_interval" do
        @config.polling_interval.must_equal 13
      end
      
      it "configures redis_url" do
        @config.redis_url.must_equal 'redis://127.0.0.1:6379/1'
      end
      
      it "configures redis_ns_ryespy" do
        @config.redis_ns_ryespy.must_equal 'WithMyLittleEye!'
      end
      
      it "configures redis_ns_notifiers" do
        @config.redis_ns_notifiers.must_equal 'LaLaLiLi-'
      end
      
      it "configures notifiers" do
        @config.notifiers.must_equal [{ :sidekiq => 'redis://127.0.0.1:6379/2' }]
      end
    end
    
    describe "listener IMAP" do
      before do
        @app.configure do |c|
          c.imap_host     = 'imap.example.com'
          c.imap_port     = 143
          c.imap_ssl      = false
          c.imap_username = 'lucy.westenra@example.com'
          c.imap_password = 'white'
          c.imap_filters  = 'BoxA,Sent Messages'
        end
      end
      
      it "configures imap_host" do
        @config.imap_host.must_equal 'imap.example.com'
      end
      
      it "configures imap_port" do
        @config.imap_port.must_equal 143
      end
      
      it "configures imap_ssl" do
        @config.imap_ssl.must_equal false
      end
      
      it "configures imap_username" do
        @config.imap_username.must_equal 'lucy.westenra@example.com'
      end
      
      it "configures imap_password" do
        @config.imap_password.must_equal 'white'
      end
      
      it "configures imap_filters" do
        @config.imap_filters.must_equal 'BoxA,Sent Messages'
      end
    end
    
    describe "listener FTP" do
      before do
        @app.configure do |c|
          c.ftp_host     = 'ftp.example.org'
          c.ftp_port     = 2121
          c.ftp_passive  = true
          c.ftp_username = 'madam.mina@example.com'
          c.ftp_password = 'black'
          c.ftp_filters  = ['BoxA', 'Sent Messages']
        end
      end
      
      it "configures ftp_host" do
        @config.ftp_host.must_equal 'ftp.example.org'
      end
      
      it "configures ftp_port" do
        @config.ftp_port.must_equal 2121
      end
      
      it "configures ftp_passive" do
        @config.ftp_passive.must_equal true
      end
      
      it "configures ftp_username" do
        @config.ftp_username.must_equal 'madam.mina@example.com'
      end
      
      it "configures ftp_password" do
        @config.ftp_password.must_equal 'black'
      end
      
      it "configures ftp_filters" do
        @config.ftp_filters.must_equal ['BoxA', 'Sent Messages']
      end
    end
    
    describe "listener amzn-s3" do
      before do
        @app.configure do |c|
          c.amzn_s3_access_key = 'r.m.renfield'
          c.amzn_s3_secret_key = 'master'
          c.amzn_s3_bucket     = 'i-can-wait'
          c.amzn_s3_filters    = ['flies/', 'spiders/']
        end
      end
      
      it "configures amzn_s3_access_key" do
        @config.amzn_s3_access_key.must_equal 'r.m.renfield'
      end
      
      it "configures amzn_s3_secret_key" do
        @config.amzn_s3_secret_key.must_equal 'master'
      end
      
      it "configures amzn_s3_bucket" do
        @config.amzn_s3_bucket.must_equal 'i-can-wait'
      end
      
      it "configures amzn_s3_filters" do
        @config.amzn_s3_filters.must_equal ["flies/", "spiders/"]
      end
    end
    
    describe "listener goog-cs" do
      before do
        @app.configure do |c|
          c.goog_cs_access_key = 'r.m.renfield'
          c.goog_cs_secret_key = 'master'
          c.goog_cs_bucket     = 'i-can-wait'
          c.goog_cs_filters    = ['flies/', 'spiders/']
        end
      end
      
      it "configures goog_cs_access_key" do
        @config.goog_cs_access_key.must_equal 'r.m.renfield'
      end
      
      it "configures goog_cs_secret_key" do
        @config.goog_cs_secret_key.must_equal 'master'
      end
      
      it "configures goog_cs_bucket" do
        @config.goog_cs_bucket.must_equal 'i-can-wait'
      end
      
      it "configures goog_cs_filters" do
        @config.goog_cs_filters.must_equal ["flies/", "spiders/"]
      end
    end
    
    describe "listener rax-cf" do
      before do
        @app.configure do |c|
          c.rax_cf_endpoint  = 'uk'
          c.rax_cf_region    = 'lon'
          c.rax_cf_username  = 'van.helsing'
          c.rax_cf_api_key   = 'M.D., D.Ph., D.Litt., etc.'
          c.rax_cf_container = 'the-milk-that-is-spilt-cries-not-out-afterwards'
          c.rax_cf_filters   = ['abraham/', 'van/']
        end
      end
      
      it "configures rax_cf_endpoint" do
        @config.rax_cf_endpoint.must_equal 'uk'
      end
      
      it "configures rax_cf_region" do
        @config.rax_cf_region.must_equal 'lon'
      end
      
      it "configures rax_cf_username" do
        @config.rax_cf_username.must_equal 'van.helsing'
      end
      
      it "configures rax_cf_api_key" do
        @config.rax_cf_api_key.must_equal 'M.D., D.Ph., D.Litt., etc.'
      end
      
      it "configures rax_cf_container" do
        @config.rax_cf_container.must_equal 'the-milk-that-is-spilt-cries-not-out-afterwards'
      end
      
      it "configures rax_cf_filters" do
        @config.rax_cf_filters.must_equal ["abraham/", "van/"]
      end
    end
  end
  
  describe "#notifiers" do
    before do
      @app = Ryespy::App.new
      
      @app.configure do |c|
        c.notifiers = { :sidekiq => ['redis://127.0.0.1:6379/11'] }
      end
      
      @app.instance_variable_set(:@notifiers, nil)
    end
    
    it "creates notifiers when empty" do
      @app.notifiers.map(&:class).must_equal [Ryespy::Notifier::Sidekiq]
    end
    
    it "returns notifiers when extant" do
      @notifiers = stub
      
      @app.instance_variable_set(:@notifiers, @notifiers)
      
      @app.notifiers.must_equal @notifiers
    end
  end
  
  describe "#start" do
    before do
      Net::IMAP.stubs(:new).returns(stub(
        :login      => nil,
        :select     => nil,
        :uid_search => [],
        :disconnect => nil
      ))
      
      @app = Ryespy::App.new(true)
      
      @app.instance_variable_set(:@logger, Logger.new(nil))
      
      @app.configure do |c|
        c.listener         = :imap
        c.polling_interval = 10
      end
    end
    
    it "sets status running within 1s" do
      thread_app = Thread.new { @app.start }
      
      sleep 1 # patience, patience; give app time to start
      
      @app.running.must_equal true
      
      Thread.kill(thread_app)
    end
    
    it "stops running within 1s" do
      thread_app = Thread.new { @app.start }
      
      sleep 1 # patience, patience; give app time to start
      
      @app.stop; t0 = Time.now
      
      thread_app.join(2)
      
      Thread.kill(thread_app)
      
      assert_operator (Time.now - t0), :<=, 1
    end
    
    it "calls #setup hook" do
      @app.expects(:setup)
      
      start_and_stop_app(@app)
    end
    
    it "calls #cleanup hook" do
      @app.expects(:cleanup)
      
      start_and_stop_app(@app)
    end
  end
  
  describe "#stop" do
    before do
      @app = Ryespy::App.new
      
      @app.instance_variable_set(:@running, true)
    end
    
    it "sets status not-running" do
      @app.stop
      
      @app.running.must_equal false
    end
  end
  
end
