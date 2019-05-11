class ChatWorker
  include Sidekiq::Worker

  def perform(chat_application_id)
    delete_queued_and_scheduled_jobs(chat_application_id)
    Sidekiq::Client.enqueue_to('default', ChatsCountWorker, chat_application_id)
  end

  def delete_queued_and_scheduled_jobs(chat_application_id)
    Sidekiq::Queue.new('default').each do |job|
      check_job(job, chat_application_id)
    end

    Sidekiq::ScheduledSet.new.each do |job|
      check_job(job, chat_application_id)
    end
  end

  def check_job(job, chat_application_id)
    job.delete if (job.klass == 'ChatWorker' && job.args[0] == chat_application_id)
  end
end

