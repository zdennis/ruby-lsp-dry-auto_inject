class Bar
  def call
     puts "#{self.class}##{__method__} from #{caller(0)[1]}"
  end
end
