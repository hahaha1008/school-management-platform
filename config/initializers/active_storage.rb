# Disable background analysis for Active Storage
Rails.application.config.active_storage.queues.analysis = nil
Rails.application.config.active_storage.queues.purge = nil

# Make variant processor synchronous (for image resizing without background jobs)
Rails.application.config.active_storage.variant_processor = :mini_magick