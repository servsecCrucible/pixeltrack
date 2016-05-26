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

puts 'Database seeded!'
DB.tables.each { |table| puts "#{table} --> #{DB[table].count}" }
