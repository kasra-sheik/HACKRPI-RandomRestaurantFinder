from flask import Flask, request
from flask_restful import Resource, Api
from urllib2 import Request, urlopen, URLError
import re, urllib
import json
from random import randint


app = Flask(__name__)
api = Api(app)


@app.route('/')
def index():
	return "Let's find some restaurants -test run"







if __name__ == '__main__':
	app.run(debug=True)