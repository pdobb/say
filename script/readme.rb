# frozen_string_literal: true

# Play from the Pry console with:
#   play script/readme.rb

require "yaml"

################################################################################
# `include Say`
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
  # ...
  result
end

################################################################################
# `Say.<method>`
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
  # ...
  result
end

################################################################################
# Namespace Pollution
################################################################################
Say.("Added Methods Test") do
  class WithInclude
    include Say
  end

  class WithoutInclude end

  added_class_methods = WithInclude.methods - WithoutInclude.methods
  Say.("Class methods added by `include Say`: #{added_class_methods}", :info)

  added_instance_methods =
    (WithInclude.new.methods - WithoutInclude.new.methods).sort!
  Say.(
    "Instance methods added by `include Say`: #{added_instance_methods}",
    :info)
  puts(added_instance_methods.map { |im| "`#{im}`".to_sym }.to_yaml)
end;
