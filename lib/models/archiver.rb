class Archiver
  class << self
    # def load_db
    #   tables = [
    #     "x_utf_members",
    #     "core_members",
    #
    #     "x_utf_topics",
    #     "forums_topics",
    #     "x_utf_message_topics",
    #     "core_message_topics",
    #
    #     "x_utf_posts",
    #     "forums_posts",
    #     "x_utf_message_posts",
    #     "core_message_posts",
    #
    #     "x_utf_shoutbox_shouts",
    #     "shoutbox_shouts",
    #
    #     "x_utf_polls",
    #     "core_polls",
    #
    #     "core_voters",
    #
    #     "x_utf_profile_friends",
    #     "x_utf_profile_portal"
    #   ]
    #   tables.each do |tablename|
    #     load_table(tablename)
    #   end
    # end
    #
    # def load_table(tablename)
    #   folder_path = "/Users/zoro/code/helpbackups/"
    #   filepath = "#{folder_path}#{tablename}.csv"
    #   puts "File Size: #{File.size(filepath) rescue '?'} bytes"
    # end
    #
    def suppress_output
      original_stdout, original_stderr = $stdout.clone, $stderr.clone
      $stderr.reopen File.new('/dev/null', 'w')
      $stdout.reopen File.new('/dev/null', 'w')
      yield
    ensure
      $stdout.reopen original_stdout
      $stderr.reopen original_stderr
    end

    def clear_sidekiq_queues
      Sidekiq::Queue.new("default").clear
      Sidekiq::RetrySet.new.clear
      Sidekiq::ScheduledSet.new.clear
    end

    def show_time_taken
      @start_time ||= Time.now.to_f
      seconds = Time.now.to_f - @start_time
      seconds_to_humanized_time(seconds)
    end

    def seconds_to_humanized_time(remaining_seconds)
      remaining_seconds = remaining_seconds.round
      seconds_in_hour = 60 * 60
      hours = (remaining_seconds / seconds_in_hour).floor
      remaining_seconds -= (hours * seconds_in_hour)

      seconds_in_minute = 60
      minutes = (remaining_seconds / seconds_in_minute).floor
      remaining_seconds -= (minutes * seconds_in_minute)

      seconds = remaining_seconds.floor
      [
        hours.to_s.presence&.rjust(2, "0"),
        minutes.to_s.presence&.rjust(2, "0"),
        seconds.to_s.presence&.rjust(2, "0")
      ].compact.join(":")
    end

    def show_current_count(current_count_name, *max_counts)
      @previous_string ||= ""
      @previous_counts ||= []
      unless current_count_name == @previous_string
        @current_start_time = Time.now.to_f
        puts ""
        @previous_counts = Array.new(max_counts.length) { 1 }
        @previous_counts[-1] = @previous_counts[-1] - 1
      end
      increment_next = true
      @previous_counts.reverse.each_with_index do |count, ridx|
        original_idx = @previous_counts.length - 1 - ridx
        count += 1 if increment_next
        increment_next = false
        if count > max_counts[original_idx]
          increment_next = true
          @previous_counts[original_idx] = 1
        else
          @previous_counts[original_idx] = count
        end
      end
      @previous_string = current_count_name
      count_strings = Array.new(@previous_counts.length) do |t|
        count_progress = "#{@previous_counts[t]} / #{max_counts[t]}"
        count_percentage = "#{((@previous_counts[t] / max_counts[t].to_f) * 100).round(2)}"
        elapsed_time = Time.now.to_f - @current_start_time
        average_time_per_obj = @previous_counts[t] / elapsed_time.to_f
        remaining = max_counts[t].to_f - @previous_counts[t]
        (remaining / average_time_per_obj)
        ": #{count_progress} (#{count_percentage}%) -- Avg. ~#{average_time_per_obj.round(1)}/sec -- Est ~#{seconds_to_humanized_time(remaining / average_time_per_obj)}"
      end.join("")
      time = @previous_counts.first != max_counts.first ? "#{show_time_taken} " : ""
      print "\r#{' ' * 100}\r#{time}#{current_count_name}#{count_strings}  "
    end

    def restore
      # sed '2,2200000d' "/Users/zoro/code/helpbackups/forums_posts.csv" > "/Users/zoro/code/helpbackups/x1-2200000.csv"
      # sed '2,395000d' "/Users/zoro/code/helpbackups/x1-2200000.csv" > "/Users/zoro/code/helpbackups/x2-395000.csv"
      # sed '2,730000d' "/Users/zoro/code/helpbackups/x2-395000.csv" > "/Users/zoro/code/helpbackups/x3-730000.csv"
      # sed '2,65500d' "/Users/zoro/code/helpbackups/x4-1276000.csv" > "/Users/zoro/code/helpbackups/x5-65500.csv"
      raise "Can only be run in Archive mode" unless Rails.env.archive?
      # require "models/archiver"; Archiver.restore
      old_logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = nil
      # restore_from_keys(restore_users_keys)
      # ActiveRecord::Base.connection.execute("ALTER SEQUENCE users_id_seq RESTART WITH #{User.maximum(:id) + 100000};")
      # restore_from_keys(restore_posts_keys)
      # ActiveRecord::Base.connection.execute("ALTER SEQUENCE posts_id_seq RESTART WITH #{Post.maximum(:id) + 100000};")
      restore_from_keys(restore_replies_keys)
      # ActiveRecord::Base.connection.execute("ALTER SEQUENCE posts_id_seq RESTART WITH #{Reply.maximum(:id) + 100000};")
      # restore_from_keys(restore_shouts_keys)
      # restore_from_keys(restore_shouts_from_message_topics_keys)
      # restore_from_keys(restore_shouts_from_message_posts_keys)
      # ActiveRecord::Base.connection.execute("ALTER SEQUENCE posts_id_seq RESTART WITH #{Shout.maximum(:id) + 100000};")
      # restore_from_keys(restore_user_profiles_keys)
      # restore_from_keys(restore_friendships_keys)
      # ActiveRecord::Base.connection.execute("ALTER SEQUENCE posts_id_seq RESTART WITH #{Friendship.maximum(:id) + 100000};")
      # restore_from_keys(restore_polls_keys)
      # ActiveRecord::Base.connection.execute("ALTER SEQUENCE posts_id_seq RESTART WITH #{Poll.maximum(:id) + 100000};")
      # restore_from_keys(restore_user_poll_votes_keys)

      clear_sidekiq_queues
      ActiveRecord::Base.logger = old_logger
      puts "Success!".colorize(:green)
    end

    def column_val_from_header(columns, header)
      header_idx = @headers.index(header.to_s)
      found_val = columns[header_idx]&.gsub(/^"|"$/, "")
      case found_val
      when "1", "true", true then true
      when "0", "false", false then false
      when "", "NULL" then nil
      else found_val
      end
    end

    def restore_from_keys(keys)
      klass, filename = keys[:table]
      filepath = "/Users/zoro/code/helpbackups/#{filename}.csv"
      filepath = "/Users/zoro/code/helpbackups/x5-65500.csv"
      # total_count = file_rows.count
      total_count = `wc -l "#{filepath}"`.strip.split(' ')[0].to_i
      File.foreach(filepath).with_index do |row, idx|
        next @headers = row.delete("\"").split(",") if idx == 0
        begin
          skip_creation_of_object = false
          indices = []
          inside = false
          row.scan(/[",]/) do |found_char|
            current_idx = Regexp.last_match.offset(0).first
            if found_char == ","
              indices << current_idx unless inside
            else
              inside = !inside
            end
          end
          prev_idx = 0
          cols = indices.map do |idx|
            str = row[prev_idx..idx - 1]
            prev_idx = idx + 1
            str
          end
          converted_attrs = keys[:data].map do |column_key, archive_header|
            column_value = column_val_from_header(cols, archive_header)
            if column_value
              column_value = Time.at(column_value.to_i) if column_key[/_at$/] && column_value.to_i > 0
              [column_key, column_value]
            end
          end.compact.to_h.symbolize_keys
          special_attrs = keys.dig(:special, :data).map do |column_key, (special_functionality, syntax)|
            bad_special_val = false
            column_value = nil
            case special_functionality
            when :birthday
              column_value = syntax.map do |archive_header| #[:bday_month, :bday_day, :bday_year]
                column_val_from_header(cols, archive_header)
              end.compact.join("/")
              bad_special_val = true if column_value.blank? || column_value == "0/0/0" || column_value == "NULL/NULL/NULL"
            when :anonymous
              column_value = !!(column_val_from_header(cols, syntax) =~ /Anonymous\d*/)
            when :fallback_user
              if converted_attrs[:author_id].blank? || converted_attrs[:author_id].to_s == "0"
                starter_name = column_val_from_header(cols, syntax)
                user = User.find_or_initialize_by(username: starter_name.presence || "Guest #{User.maximum(:id) + 100000}")
                user.email = user.email.presence || "placeholder#{User.maximum(:id) + 100000}@email.com"
                user.save(validate: false)
                column_value = user.id
              end
            when :append_post
              # skip_creation_of_object = true if column_val_from_header(cols, syntax) == "1"
              # post_id = column_val_from_header(cols, :topic_id)
              # body = column_val_from_header(cols, :post)
              # post = Post.find(post_id)
              # unless post.body.include?(body)
              #   post.body = "#{post.body} #{body}"
              #   post.save(validate: false)
              # end
              # attach: [:append_post, :new_topic]
            end
            [column_key, column_value] unless bad_special_val || column_value.nil?
          end.compact.to_h.symbolize_keys
          next puts("Skip".colorize(:cyan)) if skip_creation_of_object
          init_attrs = keys.dig(:special, :init) || {}
          special_attrs.reject! { |k,v| v.blank? || v == "0" || v == "NULL" }
          converted_attrs.reject! { |k,v| v.blank? || v == "0" || v == "NULL" }
          obj_attrs = init_attrs.merge(special_attrs.merge(converted_attrs)).symbolize_keys
          obj = klass.find_by(id: obj_attrs[:id]) || klass.new
          obj.assign_attributes(obj_attrs)
          obj.save(validate: false)
          if obj.errors.any?
            puts "#{obj.errors.full_messages} (#{obj.errors.keys.first}: #{obj.send(obj.errors.keys.first)})".colorize(:red)
          end
        rescue => e
          puts "#{e} - #{row}: #{e.backtrace.join("\n")}".colorize(:red)
          binding.pry
        end
        show_current_count("#{klass.name}s", total_count)
      end
    end

    def restore_users_keys
      {
        table: [User, :core_members],
        data: {
          id:              :member_id,
          username:        :name,
          email:           :email,
          created_at:      :joined,
          confirmed_at:    :joined,
          verified_at:     :joined,
          last_sign_in_ip: :ip_address,
          last_seen_at:    :last_visit
        },
        special: {
          init: {
            archived: true,
            password: :password,
            has_updated_username: true,
            completed_signup: true
          },
          data: {
            date_of_birth: [:birthday, [:bday_month, :bday_day, :bday_year]]
          }
        }
      }
    end

    def restore_posts_keys
      {
        table: [Post, :forums_topics],
        data: {
          id:              :tid,
          body:            :title,
          author_id:       :starter_id,
          created_at:      :start_date,
        },
        special: {
          data: {
            posted_anonymously: [:anonymous, :starter_name],
            author_id: [:fallback_user, :starter_name]
          }
        }
      }
    end

    def restore_replies_keys
      {
        table: [Reply, :forums_posts],
        data: {
          id:              :pid,
          updated_at:      :edit_time,
          author_id:       :author_id,
          created_at:      :post_date,
          body:            :post,
          post_id:         :topic_id
        },
        special: {
          data: {
            attach: [:append_post, :new_topic],
            posted_anonymously: [:anonymous, :author_name],
            author_id: [:fallback_user, :author_name]
          }
        }
      }
    end

    def restore_shouts_keys
      {
        table: [Shout, :shoutbox_shouts],
        data: {
          sent_from_id:    :s_id,
          sent_to_id:      :s_mid,
          created_at:      :s_date,
          body:            :s_message
        }
      }
    end

    def restore_shouts_from_message_topics_keys
      {
        table: [Shout, :core_message_topics],
        data: {
          id:              :mt_id,
          created_at:      :mt_date,
          body:            :mt_title,
          user_id:         :mt_starter_id,
          sent_to_id:      :mt_to_member_id
        }
      }
    end

    def restore_shouts_from_message_posts_keys
      {
        table: [Shout, :core_message_posts],
        data: {
          id:              :msg_id,
          created_at:      :msg_date,
          body:            :msg_post,
          sent_from_id:    :msg_author_id
          # msg_is_first_post: :- If "1", merge with Topic
          # msg_topic_id: :-- Map this to the "topic" which is essentially the first of many shouts
        }
      }
    end

    def restore_user_profiles_keys
      {
        table: [UserProfile, :x_utf_profile_portal],
        data: {
          user_id:         :pp_member_id,
          about_me:        :pp_about_me,
          updated_at:      :pp_profile_update
        }
      }
    end

    def restore_friendships_keys
      {
        table: [Friendship, :x_utf_profile_friends],
        data: {
          user_id:         :friends_member_id,
          friend_id:       :friends_friend_id,
          # friends_approved: :- If this is "1" it's accepted, use `friends_added` for the timestamp
        }
      }
    end

    def restore_polls_keys
      {
        table: [Poll, :x_utf_polls],
        data: {
          id:              :pid,
          post_id:         :tid,
          created_at:      :start_date,
          # choices: :-- This needs to be parsed and mapped to "options"
          # poll_question: :- This needs to be appended as text before the poll
        }
      }
    end

    def restore_user_poll_votes_keys
      {
        table: [UserPollVote, :core_voters],
        data: {
          id:              :vid,
          created_at:      :vote_date,
          user_id:         :member_id,
          # member_choices: :-- Maps to poll option
          # poll: :-- Need to use this in collab with `member_choices` to get the poll option id
        }
      }
    end

  end
end
