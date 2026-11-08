
# frozen_string_literal: true

module SaveGame
  SAVE_FILE = 'save.dat'

  def save_state
    File.open(SAVE_FILE, 'wb') do |file|
      Marshal.dump(self, file)
    end
  end

  def self.load_state
    return nil unless File.exist?(SAVE_FILE)

    File.open(SAVE_FILE, 'rb') do |file|
      Marshal.load(file)
    end
  end
end
