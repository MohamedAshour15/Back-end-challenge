class MessageWorker
  include Sidekiq::Worker

  def perform(chat_id)
    delete_queued_and_scheduled_jobs(chat_id)
    Sidekiq::Client.enqueue_to('low', MessagesCountWorker, chat_id)
  end

  def delete_queued_and_scheduled_jobs(chat_id)
    Sidekiq::Queue.new('low').each do |job|
      check_job(job, chat_id)
    end

    Sidekiq::ScheduledSet.new.each do |job|
      check_job(job, chat_id)
    end
  end

  def check_job(job, chat_id)
    job.delete if (job.klass == 'MessageWorker' && job.args[0] == chat_id)
  end
end

