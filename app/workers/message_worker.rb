class MessageWorker
  include Sidekiq::Worker

  def perform(chat_application_token, chat_number)
    delete_queued_and_scheduled_jobs(chat_application_token, chat_number)
    Sidekiq::Client.enqueue_to('low', MessagesCountWorker, chat_application_token, chat_number)
  end

  def delete_queued_and_scheduled_jobs(chat_application_token, chat_number)
    Sidekiq::Queue.new('low').each do |job|
      check_job(job, chat_application_token, chat_number)
    end

    Sidekiq::ScheduledSet.new.each do |job|
      check_job(job, chat_application_token, chat_number)
    end
  end

  def check_job(job, chat_application_token, chat_number)
    job.delete if (job.klass == 'MessageWorker' && job.args[0] == chat_application_token && job.args[1] == chat_number)
  end
end

