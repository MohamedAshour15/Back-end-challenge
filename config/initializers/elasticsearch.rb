Message.__elasticsearch__.create_index! force: true
Message.import
Message.__elasticsearch__.refresh_index!