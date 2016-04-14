# Pixeltrack

The usage of web analytics plays a critical part in the services of many
service providers on the Internet today. Clients often want to see statistics
about the number of users that visit particular pages in order to understand issues
and make operational changes.

## Use Case Example

Consider the case where a merchandiser is not completing the number of sales
that it expects. The typical process of completing a sale is:

1. Searche website for item
2. Select item and go to item page
3. Add item to cart
4. Initiate checkout process
5. Enter shipping and payment information
6. Complete transaction

Customers may abort the purchase of an item for any number of reasons at any one
of these steps. The utility of page view metrics comes from being able to see
at which step the drop off in the number occurs, which may indicate the presence
of bugs or unintuitive UI.

Pixeltrack serves as a way to report these metrics and points clients in the
direction of which processes they need to examine for bugs, UI choices or other
issues.

## Routes

### Application Routes
- GET `/`: root route

### Campaign Routes
- GET `api/v1/campaigns/`: returns a json list of all campaigns
- GET `api/v1/campaigns/[ID]`: returns a json of all information about a campaign
- POST `api/v1/campaigns/`: creates a new campaign

### Tracker Routes
- GET `api/v1/campaigns/[CAMPAIGN_ID]/trackers/`: returns a json of all trackers for a campaign
- GET `api/v1/campaigns/[CAMPAIGN_ID]/trackers/[ID].json`: returns a json of all information about a tracker
- GET `api/v1/campaigns/[CAMPAIGN_ID]/trackers/[ID]/document`: returns a text/plain document with a tracker document
- POST `api/v1/campaigns/[CAMPAIGN_ID]/trackers/`: creates a new tracker for a campaign

## Install

Install this API by cloning the *relevant branch* and installing required gems:

    $ bundle install

## Testing

Test this API by running:

    $ rake db:migrate RACK_ENV=test
    $ bundle exec rake spec

## Execute

Run this API during deployment:

    $ rake db:migrate (If switching from test environment)
    $ bundle exec rackup

or use autoloading during development:

    $ bundle exec rerun rackup
