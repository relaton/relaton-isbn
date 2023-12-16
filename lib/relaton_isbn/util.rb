module RelatonIsbn
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonIsbn.configuration.logger
    end
  end
end
