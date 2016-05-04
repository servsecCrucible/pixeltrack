Dir.glob('./{config,models,services,controllers,lib}/init.rb').each do |file|
  require file
end

run PixelTrackerAPI
