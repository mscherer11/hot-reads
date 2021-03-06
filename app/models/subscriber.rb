class Subscriber
  attr_reader :channel, :lockbox_to_hotreads_queue_link, :lockbox_to_hotreads_queue_user

  def initialize
    # connection = Bunny.new(
    # host: "experiments.turing.io",
    # port: "5672",
    # user: "student",
    # pass: "PLDa{g7t4Fy@47H"
    # )
    connection = Bunny.new(ENV['RABBITMQ_BIGWIG_RX_URL'])
    connection.start
    @channel = connection.create_channel
    create_link_channel
    create_user_channel
  end

  def create_link_channel
    @lockbox_to_hotreads_queue_link = channel.queue("ms.lockbox.to.hotreads.link")
  end

  def create_user_channel
    @lockbox_to_hotreads_queue_user = channel.queue("ms.lockbox.to.hotreads.user")
  end

  def subscribe_to_link_queue
    lockbox_to_hotreads_queue_link.subscribe do |delivery_info, metadata, payload|
      parsed_payload = JSON.parse(payload)
      link = Link.create(parsed_payload)
      puts "#{link}"
    end
  end

  def subscribe_to_user_queue
    lockbox_to_hotreads_queue_user.subscribe do |delivery_info, metadata, payload|
      parsed_payload = JSON.parse(payload)
      user = User.find_or_create_by(email: parsed_payload["email"])
      puts "#{user}"
    end
  end

end
