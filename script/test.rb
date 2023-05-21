# frozen_string_literal: true

# Play from the Pry console with:
#   play script/test.rb

# Test 1 #######################################################################

class IncludeProcessor
  include Say

  def run
    say("IncludeProcessor") {
      say("Successfully did the thing!")
      say("Debug details about this ...", :debug)
      say("Info about stuff ...", :info)
      say("Maybe look into this thing ...", :warn)
      say("Maybe look into the above thing ...", :warning)
      say("Failed to do a thing ...", :error)

      "The Result!"
    }
  end
end

result = IncludeProcessor.new.run
puts("Result: #{result.inspect}", "\n")

# Test 2 #######################################################################

class ModuleFunctionProcessor
  def run
    Say.say("ModuleFunctionProcessor") {
      Say.say("Successfully did the thing!")
      Say.say("Failed to do a thing ...", :error)

      "The Result!"
    }
  end
end

result = ModuleFunctionProcessor.new.run
puts("Result: #{result.inspect}", "\n")
