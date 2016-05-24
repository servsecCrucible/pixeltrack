require 'useragent'

# Service object to record a new visit
class RecordVisit
  def self.call(tracker:, environement:)
    user_agent = UserAgent.parse(environement["HTTP_USER_AGENT"])

    new_visit = tracker.add_visit(date: Time.now.to_i)
    new_visit.platform = user_agent.platform
    new_visit.os = user_agent.os
    new_visit.language = environement["HTTP_ACCEPT_LANGUAGE"].split(',').map{|x| x.split(';')[0].split('-')[0]}.uniq.to_s
    new_visit.ip = environement["REMOTE_ADDR"]
    new_visit.isMobile = user_agent.mobile?
    new_visit.isBot = user_agent.bot?
    new_visit.save
  end
end

#"HTTP_USER_AGENT":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/50.0.2661.102 Chrome/50.0.2661.102 Safari/537.36",
#"HTTP_ACCEPT_LANGUAGE":"fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4",
#"REMOTE_ADDR":"127.0.0.1"

#str.split(',').map{|x| x.split(';')[0].split('-')[0]}.uniq
