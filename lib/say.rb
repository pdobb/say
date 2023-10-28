# frozen_string_literal: true

# Say is the top-level namespace/module for this gem.
module Say
end

require "say/say"
require "say/interpolation_template"
require "say/message"
require "say/time"
require "say/version"

# BANNERS

require "say/banners/lj_banner"

# PROGRESS

# Empty namespace holder.
module Say::Progress
end

require "say/progress/tracker"
require "say/progress/interval"
