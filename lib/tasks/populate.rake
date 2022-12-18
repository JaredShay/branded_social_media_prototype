namespace :fill do
  desc 'Fill data'
  task data: :environment do
    require 'faker'
    puts 'Erasing existing data'
    puts '====================='

    [User, Post, Event, Comment].each(&:delete_all)
    ActsAsVotable::Vote.delete_all
    PublicActivity::Activity.delete_all

    puts 'Creating users'
    puts '=============='
    genders = ['male', 'female']
    password = 'socify123'

    20.times do |n|
      now = DateTime.now

      user = User.new
      user.name = Faker::Name.name
      user.email = Faker::Internet.email
      user.sex = genders
      user.dob = Time.at((45.years.ago - 15.years.ago).to_f*rand + 15.years.ago.to_f)
      user.phone_number = Faker::PhoneNumber.cell_phone
      user.password = password
      user.confirmed_at = now
      user.sign_in_count = n
      user.posts_count = 0

      user.save!
      puts "created user #{user.name}"
    end

    user = User.new(name: 'Rails', email: 'test@socify.com', sex: 'female', password: 'password')
    user.skip_confirmation!
    user.save!
    puts 'Created test user with email=test@socify.com and password=password'

    puts 'Generate Friendly id slug for users'
    puts '==================================='
    User.find_each(&:save)

    puts 'Creating Posts'
    puts '=============='
    users = User.all

    15.times do |n|
      post = Post.new
      post.content = Faker::Lorem.paragraph(sentence_count: n + 1)
      post.user = users.sample
      post.save!
      puts "created post #{post.id}"
    end

    puts 'Creating Comments For Posts'
    puts '==========================='

    posts = Post.all

    15.times do |n|
      post = posts.sample
      user = users.sample
      comment = post.comments.new
      comment.comment = Faker::Lorem.paragraph(sentence_count: n + 1)
      comment.user = user
      comment.save
      puts "user #{user.name} commented on post #{post.id}"
    end

    puts 'Creating Events'
    puts '==============='

    15.times do |n|
      event = Event.new
      event.name = Faker::Lorem.words(number: n + 1).join(" ").titleize
      event.event_datetime = Time.at((2.years.ago - 1.days.ago).to_f*rand + 1.days.ago.to_f)
      event.user = users.sample
      event.save
      puts "created event #{event.name}"
    end

    puts 'Creating Likes For Posts'
    puts '========================'

    15.times do
      post = posts.sample
      user = users.sample
      post.liked_by user
      puts "post #{post.id} liked by user #{user.name}"
    end

    puts 'Creating Likes For Events'
    puts '========================='
    events = Event.all

    15.times do
      event = events.sample
      user = users.sample
      event.liked_by user
      puts "event #{event.id} liked by user #{user.name}"
    end

    puts 'Creating Comments For Events'
    puts '============================='

    15.times do |n|
      event = events.sample
      user = users.sample
      comment = event.comments.new
      comment.commentable_type = 'Event'
      comment.comment = Faker::Lorem.paragraph(sentence_count: n + 1)
      comment.user = user
      comment.save
      puts "user #{user.name} commented on event #{event.id}"
    end

  end
end
