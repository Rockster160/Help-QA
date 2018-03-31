# == Schema Information
#
# Table name: email_blobs
#
#  id                :integer          not null, primary key
#  notification_type :string
#  subject           :string
#  from              :string
#  to                :string
#  spam              :boolean
#  virus             :boolean
#  text              :text
#  blob              :text
#  date              :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  read_at           :datetime
#

class EmailBlob < ApplicationRecord
  include UrlHelper
  include Readable
  after_commit { delay(:parse) if created_at == updated_at }

  validates :blob, presence: true

  def json; @json ||= JSON.parse(blob) rescue {"content": blob}; end
  def message; @message ||= JSON.parse(json["Message"]) rescue {"subject": "Failed to parse"}; end
  def content; @content ||= message["content"]; end

  def headers
    @headers ||= begin
      parse_messages
      @headers
    end
  end

  def messages
    @messages ||= begin
      parse_messages
      @messages
    end
  end

  def parse
    self.notification_type = message["notificationType"]
    self.subject = message.dig("mail", "commonHeaders", "subject")
    self.from = message.dig("mail", "commonHeaders", "from").join(",")
    self.to = message.dig("mail", "commonHeaders", "to").join(",")
    self.date = message.dig("mail", "commonHeaders", "date")
    self.text = messages.first.gsub(/<.*?>/, "").gsub(/(\r\n\>\=20)+/, "\n").gsub("Content-Transfer-Encoding: quoted-printable Content-Type: text/plain; charset=UTF-8 ", "").squish
    self.spam = header_from_content("X-SES-Spam-Verdict") != "PASS"
    self.virus = header_from_content("X-SES-Virus-Verdict") != "PASS"
    save
    path = url_for(Rails.application.routes.url_helpers.admin_email_blob_path(self))
    SlackNotifier.notify("New Email from #{from}\n<#{path}|Click here to view.>" , channel: '#helpqa', username: 'Help-Bot', icon_emoji: ':mailbox:')
  end

  def to_html
    html = messages.join('<hr style="border-color: blue; border-size: 10px;">')
    html.gsub(/(\r\n\>\=20)+/, "<br>").gsub("\r\n", "<br>").gsub(/\<\/?script/, "XscriptX")
  end

  private

  def parse_messages
    found_boundary = content[/boundary=\w+/] rescue nil
    if found_boundary
      boundary = found_boundary[9..-1]
      temp_headers, *temp_messages = content.split("--#{boundary}")
      @headers = temp_headers
      @messages = temp_messages.map { |msg| msg.gsub("=\r\n", "").gsub("=3D\"", "=\"") }
    else
      @headers = ""
      @messages = [content]
    end
  end

  def header_from_content(header_key)
    header = headers[/#{header_key}:.*?[^;]\r\n/]
    header&.gsub(/^#{header_key}: ?|\r\n$/, "")
  end
end
