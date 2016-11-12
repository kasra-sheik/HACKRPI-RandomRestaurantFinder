from yelp.client import Client
from yelp.oauth1_authenticator import Oauth1Authenticator


auth = Oauth1Authenticator(
    consumer_key="836TVgpgYXuyjggygv_T2w",
    consumer_secret="LzvOSGMWAVv-bgkagkTrnW82QQ0",
    token="fmu5xYvwO4BCflsWEwXqq5YV4aCMtRHk",
    token_secret="ji0Aq3aD156PDI0QCT5Q41opWoA"
)


client = Client(auth)


params = {
    'term': 'persian food',
    'radius_filter':40000,
    'limit': 20
    }


location = raw_input("Enter your city or state to find the best persian resturant")

response = client.search(location, **params)
businesses = response.businesses
print len(businesses)
minRating = 1.0
bestPershResturant = ""
pershDescription = ""
for business in businesses:
	if(business.rating > minRating):
		minRating = business.rating
		bestPershResturant = business.name
		pershDescription = business.snippet_text




print str(bestPershResturant) + "-" + str(minRating) + str(pershDescription)