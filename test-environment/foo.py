from flask import Flask
from flask_restful import Resource, Api
from flask_restful import reqparse
from yelp.client import Client
from yelp.oauth1_authenticator import Oauth1Authenticator
from random import randint

app = Flask(__name__)
api = Api(app)

def getYelpResponse():
	auth = Oauth1Authenticator(
	    consumer_key="836TVgpgYXuyjggygv_T2w",
	    consumer_secret="LzvOSGMWAVv-bgkagkTrnW82QQ0",
	    token="fmu5xYvwO4BCflsWEwXqq5YV4aCMtRHk",
	    token_secret="ji0Aq3aD156PDI0QCT5Q41opWoA"
	)


	client = Client(auth)

	params = {
	    'radius_filter':40000
	    }

	#location = raw_input("Enter your city or state to find the best persian resturant")
	location = 'Troy'
	response = client.search(location, **params)
	businesses = response.businesses
	total = len(businesses)
	randomize = randint(0, total-1)
	#for business in businesses:
	#	if(business.rating > minRating):
	#		minRating = business.rating
	#		bestPershResturant = business.name
	#		pershDescription = business.snippet_text

	return str(businesses[randomize].name) + "-" + str(businesses[randomize].rating) + ": " \
			+ str(businesses[randomize].snippet_text)


class CreateUser(Resource):

	def post(self):
		try:
			parser = reqparse.RequestParser()
			parser.add_argument('restuarant', type=str, help='restaurant')
			args = parser.parse_args()
			args['restaurant'] = getYelpResponse()

			return {'Restaurant': args['restaurant']}

		except Exception as e:
			return {'error': str(e)}

	def get(self):
		return {'hello': 'world'}


api.add_resource(CreateUser, '/')

if __name__ == '__main__':
	app.run(debug=True)