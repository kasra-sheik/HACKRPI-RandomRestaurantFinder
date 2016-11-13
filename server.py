from flask import Flask, request, render_template
from flask_restful import Resource, Api
from flask_restful import reqparse
from yelp.client import Client
from yelp.oauth1_authenticator import Oauth1Authenticator
from random import randint
import json

app = Flask(__name__)
api = Api(app)

def getYelpResponse(lat, lon, keyword, distance, ratings):
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
	    'radius_filter':distance,
	    'term':keyword
	    }

	#location = raw_input("Enter your city or state to find the best persian resturant")
	response = client.search_by_coordinates(lat, lon, **params)
	businesses = response.businesses
	total = len(businesses)
	business = businesses[randint(0, total-1)]
	while float(business.rating) < float(ratings):
		business = businesses[randint(0, total-1)]

	jsonString = {
	'name': str(business.name),
	'img_url': str(business.image_url),
	'review_count': str(business.review_count),
	'rating': str(business.rating),
	'desc': str(business.snippet_text),
	'location': str(business.location),
	'deals': str(business.deals),
	'phone': str(business.display_phone),
	'rating_img': str(business.rating_img_url_large),
	'url': str(business.url),
	'categories': list(business.categories)
	}

	return jsonString


class CreateUser(Resource):

	def post(self):
		try:
			#location = request.form['location']

			parser = reqparse.RequestParser()
			parser.add_argument('keyword', type=unicode, help='keyword')
			parser.add_argument('latitude', type=float, help='lat')
			parser.add_argument('longitude', type=float, help='long')
			parser.add_argument('distance', type=float, help='distance')
			parser.add_argument('ratings', type=float, help='ratings')

			args = parser.parse_args()

			lat = request.form.get('latitude', None)
			if lat is None:
				lat = 43.2
			lon = request.form.get('longitude', None)
			if lon is None:
				lon = -73.5
			keyword = request.form.get('keyword', None)
			if keyword is None:
				keyword = 'restaurant'
			distance = request.form.get('distance', None)
			if distance is None:
				distance = 5000
			ratings = request.form.get('ratings', None)
			if ratings is None:
				ratings = 1

			#args['restaurant'] = getYelpResponse(lat, lon)
			
			return getYelpResponse(lat, lon, keyword, distance, ratings)

		except Exception as e:
			return {'error': str(e)}

	def get(self):
		return {'hello': 'WORLD'}

	@app.route('/testing')
	def submitQuery():
		return render_template('index.html')

#	@app.route('/testingPOST', methods=['POST'])
#	def submitPOST():
#		food = request.form['food']
#		quality = request.form['quality']


api.add_resource(CreateUser, '/')

if __name__ == '__main__':
	app.run(debug=True)