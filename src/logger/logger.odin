package logger

import "core:log"
import "core:os"

LOG_DIRECTORY :: "logs"
LOG_PATH :: LOG_DIRECTORY + "/game.log"

console_logger: log.Logger
file_logger: log.Logger
multi_logger: log.Logger
file_logging_enabled: bool

// init creates an application logger that writes to both the terminal and game.log.
// The caller must assign the returned logger to context.logger.
init :: proc() -> log.Logger {
	console_logger = log.create_console_logger()

	if !os.exists(LOG_DIRECTORY) {
		if err := os.make_directory_all(LOG_DIRECTORY); err != nil {
			context.logger = console_logger
			log.errorf("Could not create log directory: %v", err)
			return console_logger
		}
	}

	file, err := os.open(
		LOG_PATH,
		os.O_RDWR | os.O_APPEND | os.O_CREATE,
		os.Permissions_Default_File,
	)
	if err != nil {
		context.logger = console_logger
		log.errorf("Could not open log file: %v", err)
		return console_logger
	}

	file_logger = log.create_file_logger(file)
	multi_logger = log.create_multi_logger(console_logger, file_logger)
	file_logging_enabled = true
	return multi_logger
}

// destroy flushes and releases the application loggers.
destroy :: proc() {
	if file_logging_enabled {
		log.destroy_multi_logger(multi_logger)
		log.destroy_file_logger(file_logger)
	}
	log.destroy_console_logger(console_logger)
}
