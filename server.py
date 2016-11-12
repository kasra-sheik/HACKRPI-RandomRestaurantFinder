from flask import Flask, request
from flask_restful import Resource, Api
from flask_restful import reqparse
from yelp.client import Client
from yelp.oauth1_authenticator import Oauth1Authenticator
from random import randint

app = Flask(__name__)
api = Api(app)

def getYelpResponse(lat, lon):
	auth = Oauth1Authenticator(
	    consumer_key="836TVgpgYXuyjggygv_T2w",
	    consumer_secret="LzvOSGMWAVv-bgkagkTrnW82QQ0",
	    token="fmu5xYvwO4BCflsWEwXqq5YV4aCMtRHk",
	    token_secret="ji0Aq3aD156PDI0QCT5Q41opWoA"
	)
	#loc1 = float(loc.split(',')[0].strip)
	#loc2 = float(loc.split(',')[1])
	client = Client(auth)

	params = {
	    'radius_filter':2000
	    'term':'food'
	    #'cll':[loc[0],loc[1]]
	    }

	#location = raw_input("Enter your city or state to find the best persian resturant")
	response = client.search_by_coordinates(lat, lon, **params)
	businesses = response.businesses
	total = len(businesses)
	randomize = randint(0, total-1)

	return str(businesses[randomize].name) + '-' + str(businesses[randomize].rating)  \
			+ ':' + str(businesses[randomize].snippet_text)


class CreateUser(Resource):

	def post(self):
		try:
			#location = request.form['location']


			parser = reqparse.RequestParser()
			parser.add_argument('restuarant', type=unicode, help='restaurant')
			parser.add_argument('latitude', type=float, help='lat')
			parser.add_argument('longitude', type=float, help='long')

			args = parser.parse_args()
			lat = request.form['latitude']
			lon = request.form['longitude']
			args['restaurant'] = getYelpResponse(lat, lon)
			
			return {'Restaurant': args['restaurant']}

		except Exception as e:
			return {'error': str(e)}

	def get(self):
		return {'hello': 'world'}


api.add_resource(CreateUser, '/')

if __name__ == '__main__':
	app.run(debug=True)