# frozen_string_literal: true

# Say is the top-level namespace/module for this gem.
module Say
end

require "say/say"
require "say/interpolation_template"
require "say/message"
require "say/time"
require "say/version"

# GENERATORS

require "say/generators/banner_generator"

# JUSTIFIERS

require "say/justifiers/justifier_behaviors"
require "say/justifiers/left_justifier"
require "say/justifiers/center_justifier"
require "say/justifiers/right_justifier"

# PROGRESS

# Empty namespace holder.
module Say::Progress
end

require "say/progress/tracker"
require "say/progress/interval"
