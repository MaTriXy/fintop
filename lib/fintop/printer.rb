module Fintop
  module Printer
    extend self

    # Given an array of (pid, admin_port) pairs, gather data and print output.
    def apply(pid_port_pairs)
      threads_data = Hash[ pid_port_pairs.map { |pid, port|
        # Create a ThreadsData object for the Finagle server with admin port `port`.
        [pid, Fintop::ThreadsData.new(port)]
      }]

      total_threads = threads_data.values.map { |t| t.num_threads }.inject(:+)
      runnable_threads = threads_data.values.map { |t| t.num_runnable }.inject(:+)
      waiting_threads = threads_data.values.map { |t| t.num_waiting + t.num_timed_waiting }.inject(:+)

      if pid_port_pairs.empty?
        puts "Finagle processes: 0"
        exit
      end

      puts "Finagle processes: #{pid_port_pairs.size}, Threads: #{total_threads} total, #{runnable_threads} runnable, #{waiting_threads} waiting"
      puts
      printf "%-7s %-7s %-9s %-11s %-10s %-15s\n", "PID", "ADMIN", "#THREADS", "#RUNNABLE", "#WAITING", "#TIMEDWAITING"

      pid_port_pairs.each { |pid, port|
        # Create a ThreadsData object for the Finagle server with admin port `port`.
        threads_data = Fintop::ThreadsData.new(port)
        printf(
          "%-7s %-7s %-9s %-11s %-10s %-15s\n",
          pid,
          port,
          threads_data.num_threads,
          threads_data.num_runnable,
          threads_data.num_waiting,
          threads_data.num_timed_waiting
        )
      }
    end
  end
end
