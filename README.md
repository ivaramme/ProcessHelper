#ProcessHelper

A small and academic library that works with Unix processes using Ruby.
This library provides a module that you can add to your classes and will let you create sub processes for specific tasks for cases when you want to keep memory under control or want to avoid IO blocking calls by delegating them to another process.
It also gives you the opportunity to decide whether you want to wait for the the subprocess to wait or you would rather to fire and forget (default)
Code works only on *nix machines due to lack of support of Windows to the fork command.

## Usage
Include this library as a module in your class and wherever you need to create a separate task, call the method '

## Examples
Usage:
```ruby
class Stats
  #Include module
  include ProcessHelper

  def initialize
    @counters = Hash.new
    @output = File.open "stats.txt", mode="w"
  end

  def track_event name, fire_and_forget = true
    @counters[name] = 0 if !@counters.has_key?(name)
    @counters[name] += 1

    persist_with_helper "Tracked event#{name} @ #{Time.new}", fire_and_forget
  end

  def persist_with_helper data, fire_and_forget = true
    #Implement the task to execute
    create_task(fire_and_forget){
      persist data
    }
  end

  def persist data
    @output.puts data
    sleep 2 #some heavy stuff here
  end

  def close
    @output.close
  end
end
```

##Benchmark
```ruby
stats = Stats.new()

Benchmark.bmbm do |x|
  #Using fire and forget
  x.report "Fire and forget" do
    10.times do
      stats.track_event "new_user", true
    end
  end

  #Blocking until tasks are done
  x.report "Blocking" do
    10.times do
      stats.track_event "new_user", false
    end
  end

  #Directly call your method
  x.report "Direct call" do
    10.times do
      stats.persist "Tracked event @ #{Time.new}"
    end
  end
end

stats.close
```
##Results:
```
Rehearsal ---------------------------------------------------
Fire and forget   0.010000   0.020000   0.030000 (  0.060628)
Blocking          0.010000   0.010000   0.800000 ( 22.541970)
Direct call       0.000000   0.000000   0.000000 ( 20.002045)
------------------------------------------ total: 0.830000sec

                      user     system      total        real
Fire and forget   0.010000   0.010000   0.020000 (  0.009094)
Blocking          0.000000   0.010000   0.710000 ( 20.437528)
Direct call       0.000000   0.000000   0.000000 ( 20.002029)
```