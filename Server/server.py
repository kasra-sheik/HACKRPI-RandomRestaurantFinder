from flask import Flask
from flask_restful import Resource, Api
from flask_restful import reqparse
from yelp.client import Client
from yelp.oauth1_authenticator import Oauth1Authenticator


app = Flask(__name__)
api = Api(app)


class CreateUser(Resource):
	#@app.route('/')
	def hello():
		return "Welcome to the Flask App!"

	def post(self):
		try:
			parser = reqparse.RequestParser()
			parser.add_argument('location', type=str, help='Email address')
			parser.add_argument('restaurant', type=str, help='restaurant')
			args = parser.parse_args()
			_location = args['location']
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
			#location = raw_input("Enter your city or state to find the best persian resturant")
			response = client.search(args['location'], **params)
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

			args['restaurant'] = str(bestPershResturant) + "-" + str(minRating) + str(pershDescription)
			return {'location': args['location'], 'restaurant':args['restaurant']}

		except Exception as e:
			return {'error': str(e)}

api.add_resource(CreateUser, '/CreateUser')

if __name__ == '__main__':
	app.run(debug=True)