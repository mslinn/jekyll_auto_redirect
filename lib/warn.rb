# frozen_string_literal: true

# Monkey patch Warning to suppress 'warning: $SAFE will become a normal global variable in Ruby 3.0'
def Warning.warn(msg)
  return unless msg !~ /warning: (URI.(un|)escape is obsolete|\$SAFE will become a normal global variable)/

  super msg
end
