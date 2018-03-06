module Debugger
  module MultiProcess
    class << self
      def pre_child(options = nil)
        require 'socket'
        require 'ostruct'

        host = ENV['RDEBUG_HOST']
        port = ENV['RDEBUG_PORT']

        options ||= OpenStruct.new(
            'frame_bind'  => false,
            'host'        => host,
            'load_mode'   => false,
            'port'        => port,
            'stop'        => false,
            'tracing'     => false,
            'int_handler' => true,
            'cli_debug'   => (ENV['DEBUGGER_CLI_DEBUG'] == 'true'),
            'notify_dispatcher' => true,
            'evaluation_timeout' => 10,
            'trace_to_s' => false,
            'debugger_memory_limit' => 10,
            'inspect_time_limit' => 100
        )
      
        start_debugger(options)
      end

      def start_debugger(options)
        if Debugger.started?
          # we're in forked child, only need to restart control thread
          Debugger.breakpoints.clear
          Debugger.control_thread = nil
          Debugger.start_control(options.port)
        end

        if options.int_handler
          # install interruption handler
          trap('INT') { Debugger.interrupt_last }
        end

        Debugger.keep_frame_binding = options.frame_bind
        Debugger.tracing = options.tracing
        Debugger.evaluation_timeout = options.evaluation_timeout
        Debugger.trace_to_s = options.trace_to_s
        Debugger.debugger_memory_limit = options.debugger_memory_limit
        Debugger.inspect_time_limit = options.inspect_time_limit
        Debugger.cli_debug = options.cli_debug
        Debugger.prepare_debugger(options)
      end
    end
  end
end