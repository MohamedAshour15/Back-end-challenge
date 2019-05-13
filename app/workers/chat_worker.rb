class ChatWorker
  include Sidekiq::Worker

  def perform(chat_application_token)
    delete_queued_and_scheduled_jobs(chat_application_token)
    Sidekiq::Client.enqueue_to('low', ChatsCountWorker, chat_application_token)
  end

  def delete_queued_and_scheduled_jobs(chat_application_token)
    Sidekiq::Queue.new('low').each do |job|
      check_job(job, chat_application_token)
    end

    Sidekiq::ScheduledSet.new.each do |job|
      check_job(job, chat_application_token)
    end
  end

  def check_job(job, chat_application_token)
    job.delete if (job.klass == 'ChatWorker' && job.args[0] == chat_application_token)
  end
end

