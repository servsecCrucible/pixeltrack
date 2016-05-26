# Create accounts
jherez = CreateNewAccount.call( username: 'jherez',
                                email: 'jherez@nthu.edu.tw',
                                password: 'jherezpassword')

nicholas = CreateNewAccount.call( username: 'nicholas',
                                  email: 'nicholas@nthu.edu.tw',
                                  password: 'nicholaspassword')

renaud = CreateNewAccount.call( username: 'renaud',
                                email: 'renaud@nthu.edu.tw',
                                password: 'renaudpassword')

campaignJR = CreateCampaignForOwnerWithContributors.call(
  owner: jherez, label: 'Jherez & Renaud campaign', contributors: [renaud])

campaignNJ = CreateCampaignForOwnerWithContributors.call(
  owner: nicholas, label: 'Nicolas & Jherez campaign', contributors: [jherez])

campaignRN = CreateCampaignForOwnerWithContributors.call(
  owner: renaud, label: 'Renaud & Nicolas campaign', contributors: [nicholas])

trackerJR1 = CreateTrackerForCampaign.call(
  campaign: campaignJR, label: 'tracker JR #1')
trackerJR2 = CreateTrackerForCampaign.call(
  campaign: campaignJR, label: 'tracker JR #2')

trackerNJ1 = CreateTrackerForCampaign.call(
  campaign: campaignNJ, label: 'tracker NJ #1')
trackerNJ2 = CreateTrackerForCampaign.call(
  campaign: campaignNJ, label: 'tracker NJ #2')

trackerRN1 = CreateTrackerForCampaign.call(
  campaign: campaignRN, label: 'tracker RN #1')
trackerRN2 = CreateTrackerForCampaign.call(
  campaign: campaignRN, label: 'tracker RN #2')

env1 = {
  "HTTP_USER_AGENT" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/50.0.2661.102 Chrome/50.0.2661.102 Safari/537.36",
  "HTTP_ACCEPT_LANGUAGE" => "fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4",
  "REMOTE_ADDR" => "140.103.76.12"
}

env2 = {
  "HTTP_USER_AGENT" => "Mozilla/5.0 (Linux; U; Android 2.3.3; de-de; HTC Desire Build/GRI40) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
  "HTTP_ACCEPT_LANGUAGE" => "da, en-gb;q=0.8, en;q=0.7",
  "REMOTE_ADDR" => "140.113.76.15"
}

Tracker.all.each do |tracker|
  RecordVisit.call(tracker: tracker, environement: env1)
  RecordVisit.call(tracker: tracker, environement: env2)
end

puts 'Database seeded!'
DB.tables.each { |table| puts "#{table} --> #{DB[table].count}" }
