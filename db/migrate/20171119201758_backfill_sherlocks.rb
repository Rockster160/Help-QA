class BackfillSherlocks < ActiveRecord::Migration[5.0]
  def change
    reversible do |migration|
      migration.up do
        User.find_each do |user|
          Sherlock.create(
            obj: user,
            changed_attrs: user.attributes.each_with_object({}) {|(k,v), m|m[k] = nil},
            acting_user: user,
            acting_ip: user.try(:ip_address),
            discovery_klass: :user,
            new_attributes: user.attributes,
            created_at: user.created_at
          )
        end
        Post.find_each do |post|
          Sherlock.create(
            obj: post,
            changed_attrs: post.attributes.each_with_object({}) {|(k,v), m|m[k] = nil},
            acting_user: post.author,
            acting_ip: post.author.try(:ip_address),
            discovery_klass: :post,
            new_attributes: post.attributes,
            created_at: post.created_at
          )
        end
        Reply.find_each do |reply|
          Sherlock.create(
            obj: reply,
            changed_attrs: reply.attributes.each_with_object({}) {|(k,v), m|m[k] = nil},
            acting_user: reply.author,
            acting_ip: reply.author.try(:ip_address),
            discovery_klass: :reply,
            new_attributes: reply.attributes,
            created_at: reply.created_at
          )
        end
        Shout.find_each do |shout|
          Sherlock.create(
            obj: shout,
            changed_attrs: shout.attributes.each_with_object({}) {|(k,v), m|m[k] = nil},
            acting_user: shout.sent_from,
            acting_ip: shout.sent_from.try(:ip_address),
            discovery_klass: :shout,
            new_attributes: shout.attributes,
            created_at: shout.created_at
          )
        end
        ChatMessage.find_each do |chat|
          Sherlock.create(
            obj: chat,
            changed_attrs: chat.attributes.each_with_object({}) {|(k,v), m|m[k] = nil},
            acting_user: chat.author,
            acting_ip: chat.author.try(:ip_address),
            discovery_klass: :chat,
            new_attributes: chat.attributes,
            created_at: chat.created_at
          )
        end
      end
    end
  end
end
