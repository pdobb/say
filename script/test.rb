# frozen_string_literal: true

# Play from the Pry console with:
#   play script/test.rb

################################################################################
Say.call do
  class IncludeProcessor
    include Say

    def run
      say("IncludeProcessor") {
        say("Successfully did the thing!")
        say
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
  puts("IncludeProcessor#run Result: #{result.inspect}")
end;

################################################################################
Say.call do
  class DirectAccessProcessor
    def run
      Say.("DirectAccessProcessor") {
        Say.("Successfully did the thing!")
        Say.() # Or: Say.call
        Say.("Debug details about this ...", :debug)
        Say.("Info about stuff ...", :info)
        Say.("Maybe look into this thing ...", :warn)
        Say.("Maybe look into the above thing ...", :warning)
        Say.("Failed to do a thing ...", :error)

        "The Result!"
      }
    end
  end

  result = DirectAccessProcessor.new.run
  puts("DirectAccessProcessor#run Result: #{result.inspect}")
end;

################################################################################
Say.("Added Methods Test") do
  class WithInclude
    include Say
  end

  class WithoutInclude end

  Say.("Class methods added by `include Say`: #{WithInclude.methods - WithoutInclude.methods}", :info)
  Say.("Instance methods added by `include Say`: #{WithInclude.new.methods - WithoutInclude.new.methods}", :info)
end;
