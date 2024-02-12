package utils

import (
	"log"
	"os"
	"testing"
	"time"
)

// AggregatedLogger represents an aggregated logger with different log levels.
type AggregatedLogger struct {
	infoLogger  *log.Logger
	warnLogger  *log.Logger
	errorLogger *log.Logger
}

// NewAggregatedLogger creates a new instance of AggregatedLogger.
func NewAggregatedLogger(logFilePath string) (*AggregatedLogger, error) {
	file, err := os.Create(logFilePath)
	if err != nil {
		return nil, err
	}

	return &AggregatedLogger{
		infoLogger:  log.New(file, "", 0),
		warnLogger:  log.New(file, "", 0),
		errorLogger: log.New(file, "", 0),
	}, nil
}

// getLogArgs is a helper function to generate common log arguments.
func getLogArgs(t *testing.T, message string) []interface{} {
	return []interface{}{
		time.Now().Format("2006-01-02 15:04:05"),
		t.Name(),
		message,
	}
}

// Info logs informational messages.
func (l *AggregatedLogger) Info(t *testing.T, message string) {
	format := "[%s] [INFO]  [%s] : %v\n"
	l.infoLogger.Printf(format, getLogArgs(t, message)...)
}

// Warn logs warning messages.
func (l *AggregatedLogger) Warn(t *testing.T, message string) {
	format := "[%s] [WARN]  [%s] : %v\n"
	l.warnLogger.Printf(format, getLogArgs(t, message)...)
}

// Error logs error messages.
func (l *AggregatedLogger) Error(t *testing.T, message string) {
	format := "[%s] [ERROR] [%s] : %v\n"
	l.errorLogger.Printf(format, getLogArgs(t, message)...)
}