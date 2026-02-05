namespace :users do
  desc "Create seed users for each role (Admin, Reviewer, Read Only)"
  task setup: :environment do
    puts "Creating users..."

    users = [
      { role: :admin, email: "admin@example.com" },
      { role: :reviewer, email: "reviewer@example.com" },
      { role: :read_only, email: "readonly@example.com" }
    ]

    users.each do |u|
      user = User.find_or_initialize_by(email_address: u[:email])
      user.password = "password"
      user.role = u[:role]

      if user.save
        puts "✅ Created/Updated: #{u[:role].to_s.humanize} - #{u[:email]} (Password: 'password')"
      else
        puts "❌ Failed to create #{u[:email]}: #{user.errors.full_messages.join(', ')}"
      end
    end

    puts "\nDone! You can now log in at http://localhost:3000/login"
  end
end
